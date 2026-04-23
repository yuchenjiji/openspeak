import 'dart:math';

import 'package:flutter/material.dart';

class VoiceInputBar extends StatelessWidget {
  final bool isListening;
  final bool isAIResponding;
  final String partialText;
  final VoidCallback onMicPressed;
  final VoidCallback onSendPressed;
  final ValueChanged<String> onTextSubmitted;

  const VoiceInputBar({
    super.key,
    required this.isListening,
    required this.isAIResponding,
    required this.partialText,
    required this.onMicPressed,
    required this.onSendPressed,
    required this.onTextSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isListening && partialText.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    partialText,
                    style: textTheme.bodyLarge
                        ?.copyWith(color: colorScheme.onSurface),
                  ),
                ),
              if (isListening)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WaveformAnimation(colorScheme: colorScheme),
                ),
              Row(
                children: [
                  Expanded(
                    child: _ChatTextField(
                      isListening: isListening,
                      isAIResponding: isAIResponding,
                      onSubmitted: onTextSubmitted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isListening && partialText.isNotEmpty)
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size(56, 56),
                      ),
                      icon: const Icon(Icons.send_rounded),
                      tooltip: 'Send',
                      onPressed: onSendPressed,
                    )
                  else
                    _MicButton(
                      isListening: isListening,
                      isDisabled: isAIResponding,
                      onTap: onMicPressed,
                      colorScheme: colorScheme,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatTextField extends StatefulWidget {
  final bool isListening;
  final bool isAIResponding;
  final ValueChanged<String> onSubmitted;

  const _ChatTextField({
    required this.isListening,
    required this.isAIResponding,
    required this.onSubmitted,
  });

  @override
  State<_ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<_ChatTextField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmitted(text);
      _controller.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: _controller,
      enabled: !widget.isListening && !widget.isAIResponding,
      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: widget.isListening
            ? 'Listening...'
            : widget.isAIResponding
                ? 'AI is thinking...'
                : 'Type or tap mic to speak...',
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                onPressed: _submit,
                icon: Icon(Icons.send_rounded, color: colorScheme.primary),
              )
            : null,
      ),
      textInputAction: TextInputAction.send,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _submit(),
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool isListening;
  final bool isDisabled;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _MicButton({
    required this.isListening,
    required this.isDisabled,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isListening ? 'Stop recording' : 'Start recording',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: isListening ? 64 : 56,
        height: isListening ? 64 : 56,
        decoration: BoxDecoration(
          color: isListening
              ? colorScheme.error
              : isDisabled
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: isListening
              ? [
                  BoxShadow(
                    color: colorScheme.error.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isDisabled ? null : onTap,
            child: Center(
              child: Icon(
                isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: isListening
                    ? colorScheme.onError
                    : isDisabled
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onPrimary,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveformAnimation extends StatefulWidget {
  final ColorScheme colorScheme;
  const _WaveformAnimation({required this.colorScheme});

  @override
  State<_WaveformAnimation> createState() => _WaveformAnimationState();
}

class _WaveformAnimationState extends State<_WaveformAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => SizedBox(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (i) {
            final phase = (_controller.value * 2 * pi) + (i * 0.3);
            final h = 8 + sin(phase).abs() * 20;
            return Container(
              width: 3,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: widget.colorScheme.primary
                    .withValues(alpha: 0.4 + sin(phase).abs() * 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
    );
  }
}
