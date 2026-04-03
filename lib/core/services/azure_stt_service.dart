import "dart:async";
import "dart:io";

import "package:path_provider/path_provider.dart";
import "package:record/record.dart";
import "package:dio/dio.dart";

import "../config/env_config.dart";
import "stt_service.dart";

/// Azure Speech Services STT implementation.
///
/// Strategy:
///  1. Record microphone to a temp WAV file using [record] package.
///  2. While recording, emit periodic partial STTResult to show the UI is active.
///  3. On stopListening(), send the WAV to Azure Speech REST API and emit final result.
class AzureSTTService implements STTService {
  final _recorder = AudioRecorder();
  late final Dio _dio;

  bool _isListening = false;
  StreamController<STTResult>? _controller;
  Timer? _partialTimer;
  String? _tempFilePath;

  AzureSTTService() {
    final key = EnvConfig.azureSpeechKey;
    final region = EnvConfig.azureSpeechRegion;
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://$region.stt.speech.microsoft.com",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Ocp-Apim-Subscription-Key": key,
          "Content-Type": "audio/wav; codecs=audio/pcm; samplerate=16000",
          "Accept": "application/json",
        },
      ),
    );
  }

  @override
  bool get isListening => _isListening;

  @override
  Stream<STTResult> startListening({String language = "en-US"}) {
    _controller = StreamController<STTResult>.broadcast();
    _isListening = true;
    _startRecording(language);
    return _controller!.stream;
  }

  Future<void> _startRecording(String language) async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _controller?.addError("Microphone permission denied");
        return;
      }

      // Save to a temp file
      final dir = await getTemporaryDirectory();
      _tempFilePath =
          "${dir.path}/openspeak_stt_${DateTime.now().millisecondsSinceEpoch}.wav";

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _tempFilePath!,
      );

      // Emit "listening..." partial results so UI shows activity
      int dots = 0;
      _partialTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
        if (!_isListening) return;
        dots++;
        final indicator = "Listening" + ("." * (dots % 4));
        _controller?.add(
          STTResult(text: indicator, isFinal: false, confidence: 0.0),
        );
      });
    } catch (e) {
      _controller?.addError(e);
    }
  }

  @override
  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;
    _partialTimer?.cancel();
    _partialTimer = null;

    try {
      await _recorder.stop();

      final file = _tempFilePath != null ? File(_tempFilePath!) : null;
      if (file != null && await file.exists()) {
        final text = await _transcribeFile(file);
        if (text != null && text.isNotEmpty) {
          _controller?.add(
            STTResult(text: text, isFinal: true, confidence: 0.95),
          );
        }
        // Cleanup temp file
        await file.delete();
      }
    } catch (e) {
      _controller?.addError(e);
    } finally {
      await _controller?.close();
      _controller = null;
      _tempFilePath = null;
    }
  }

  Future<String?> _transcribeFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final response = await _dio.post<Map<String, dynamic>>(
        "/speech/recognition/conversation/cognitiveservices/v1",
        queryParameters: {"language": "en-US", "format": "detailed"},
        data: bytes,
        options: Options(
          headers: {
            "Content-Type": "audio/wav; codecs=audio/pcm; samplerate=16000",
          },
          responseType: ResponseType.json,
        ),
      );

      final status = response.data?["RecognitionStatus"];
      if (status == "Success") {
        return response.data?["DisplayText"] as String?;
      }
      return null;
    } on DioException catch (_) {
      // Non-fatal: just return null so the user can try again
      return null;
    }
  }
}
