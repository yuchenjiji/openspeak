#!/usr/bin/env python3
"""Test all OpenSpeak backend services."""

import json
import math
import os
import struct
import urllib.error
import urllib.request
import wave
from pathlib import Path


def load_env(path=".env"):
    env = {}
    for line in Path(path).read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        k, _, v = line.partition("=")
        env[k.strip()] = v.strip()
    return env


def make_wav(duration_s=1, freq=440, samplerate=16000) -> bytes:
    samples = [int(32767 * math.sin(2 * math.pi * freq * t / samplerate))
               for t in range(samplerate * duration_s)]
    import io
    buf = io.BytesIO()
    with wave.open(buf, "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(samplerate)
        f.writeframes(struct.pack("<" + "h" * len(samples), *samples))
    return buf.getvalue()


def post_json(url, body, headers):
    data = json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, headers={
        "Content-Type": "application/json", **headers}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def post_raw(url, body, headers):
    req = urllib.request.Request(url, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def ok(label):  print(f"  \033[32m✓\033[0m {label}")
def fail(label, detail=""): print(f"  \033[31m✗\033[0m {label}{': ' + str(detail) if detail else ''}")
def section(title): print(f"\n\033[1m{title}\033[0m")


def test_azure_openai(env):
    section("1. Azure OpenAI (chat)")
    endpoint = env.get("AZURE_OPENAI_ENDPOINT", "")
    key      = env.get("AZURE_OPENAI_API_KEY", "")
    model    = env.get("AZURE_OPENAI_DEPLOYMENT_ID", "gpt-4o")
    version  = env.get("AZURE_OPENAI_API_VERSION", "2024-12-01-preview")

    base = endpoint.rstrip("/")
    for suffix in ("/responses", "/chat/completions"):
        if base.endswith(suffix):
            base = base[:-len(suffix)]
    if not base.endswith("/v1"):
        base += "/v1"
    # /v1 path (AI Foundry) doesn't accept api-version query param
    url = f"{base}/chat/completions"

    status, resp = post_json(url, {
        "model": model,
        "messages": [{"role": "user", "content": "Reply with one word: hello"}],
        "max_completion_tokens": 2000,
    }, {"api-key": key})

    if status == 200 and isinstance(resp, dict):
        text = resp.get("choices", [{}])[0].get("message", {}).get("content", "")
        ok(f"response: {text!r}")
    else:
        fail(f"HTTP {status}", resp)


def test_azure_tts(env):
    section("2. Azure TTS")
    key    = env.get("AZURE_SPEECH_KEY", "")
    region = env.get("AZURE_SPEECH_REGION", "eastus")
    url    = f"https://{region}.tts.speech.microsoft.com/cognitiveservices/v1"
    ssml   = ("<speak version='1.0' xml:lang='en-US'>"
              "<voice name='en-US-JennyNeural'>Hello</voice></speak>")

    status, resp = post_raw(url, ssml.encode(), {
        "Ocp-Apim-Subscription-Key": key,
        "Content-Type": "application/ssml+xml",
        "X-Microsoft-OutputFormat": "audio-16khz-32kbitrate-mono-mp3",
    })

    if status == 200 and isinstance(resp, bytes) and len(resp) > 100:
        ok(f"received {len(resp)} bytes of audio")
    else:
        fail(f"HTTP {status}", resp if isinstance(resp, str) else resp[:200])


def test_azure_stt(env):
    section("3. Azure STT")
    key    = env.get("AZURE_SPEECH_KEY", "")
    region = env.get("AZURE_SPEECH_REGION", "eastus")
    url    = (f"https://{region}.stt.speech.microsoft.com"
              "/speech/recognition/conversation/cognitiveservices/v1"
              "?language=en-US&format=detailed")
    wav = make_wav()

    status, resp = post_raw(url, wav, {
        "Ocp-Apim-Subscription-Key": key,
        "Content-Type": "audio/wav; codecs=audio/pcm; samplerate=16000",
        "Accept": "application/json",
    })

    if status == 200:
        try:
            data = json.loads(resp)
            recognition = data.get("RecognitionStatus", "")
            ok(f"RecognitionStatus: {recognition}")
        except Exception:
            fail("bad JSON", resp[:200])
    else:
        fail(f"HTTP {status}", resp if isinstance(resp, str) else resp[:200])


def test_cloudflare_whisper(env):
    section("4. Cloudflare Whisper STT")
    account_id = env.get("CLOUDFLARE_ACCOUNT_ID", "")
    token      = env.get("CLOUDFLARE_AI_API_TOKEN", "")
    model      = env.get("WHISPER_MODEL", "@cf/openai/whisper-large-v3-turbo")
    url        = f"https://api.cloudflare.com/client/v4/accounts/{account_id}/ai/run/{model}"
    wav        = make_wav()

    status, resp = post_raw(url, wav, {
        "Authorization": f"Bearer {token}",
        "Content-Type": "audio/wav",
    })

    if status == 200:
        try:
            data = json.loads(resp)
            text = data.get("result", {}).get("text", "")
            ok(f"transcription: {text!r}")
        except Exception:
            fail("bad JSON", resp[:200])
    else:
        fail(f"HTTP {status}", resp if isinstance(resp, str) else resp[:200])


def test_cloudflare_grammar(env):
    section("5. Cloudflare Grammar (Llama)")
    account_id = env.get("CLOUDFLARE_ACCOUNT_ID", "")
    token      = env.get("CLOUDFLARE_AI_API_TOKEN", "")
    url        = (f"https://api.cloudflare.com/client/v4/accounts/{account_id}"
                  "/ai/run/@cf/meta/llama-3.1-8b-instruct")

    status, resp = post_json(url, {
        "messages": [
            {"role": "system", "content": 'Reply with JSON only: {"correct": true} or {"correct": false, "errors": []}'},
            {"role": "user", "content": "She go to school yesterday."},
        ],
    }, {"Authorization": f"Bearer {token}"})

    if status == 200 and isinstance(resp, dict):
        raw = resp.get("result", {}).get("response", "")
        ok(f"response: {raw[:120]!r}")
    else:
        fail(f"HTTP {status}", resp)


if __name__ == "__main__":
    print("\033[1mOpenSpeak Service Tests\033[0m")
    env = load_env(".env")

    test_azure_openai(env)
    test_azure_tts(env)
    test_azure_stt(env)
    test_cloudflare_whisper(env)
    test_cloudflare_grammar(env)

    print()
