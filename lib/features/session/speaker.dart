import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Says English words aloud. Device TTS for MVP (docs/SPEC.md — Decisions).
abstract class Speaker {
  Future<void> say(String text);
  Future<void> stop();
}

class DeviceSpeaker implements Speaker {
  DeviceSpeaker() : _tts = FlutterTts();

  final FlutterTts _tts;
  Future<void>? _ready;

  Future<void> _init() async {
    await _tts.setLanguage('en-US');
    // Slow and clear for young learners (0.5 ≈ normal on both platforms).
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.05);
  }

  @override
  Future<void> say(String text) async {
    try {
      await (_ready ??= _init());
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // No TTS engine on the device: the card still works without audio.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

final speakerProvider = Provider<Speaker>((ref) => DeviceSpeaker());
