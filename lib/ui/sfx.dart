import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';

/// Short UI sounds, synthesized by tool/make_sounds.dart.
enum Sound { swipe, knew, almost, notYet, cheer, tap }

abstract class Sfx {
  void play(Sound sound);
}

/// Plays bundled WAVs. Mixes with other audio so it never cuts off the
/// spoken word, and stays quiet when a parent turns sound effects off.
class AudioSfx implements Sfx {
  AudioSfx({required this.enabled});

  final bool Function() enabled;
  final _players = <Sound, AudioPlayer>{};
  bool _configured = false;

  static String _file(Sound s) => switch (s) {
    Sound.notYet => 'sounds/not_yet.wav',
    _ => 'sounds/${s.name}.wav',
  };

  @override
  void play(Sound sound) {
    if (!enabled()) return;
    _play(sound).catchError((Object e) {
      // A missing audio device must never break a session.
      debugPrint('sfx $sound failed: $e');
    });
  }

  Future<void> _play(Sound sound) async {
    if (!_configured) {
      _configured = true;
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
      );
    }
    final p = _players[sound] ??= AudioPlayer()
      // No position stream: by default it asks for a frame on every frame
      // while "playing", and Android's low-latency mode never reports the
      // end, so the app would redraw forever (battery drain).
      ..positionUpdater = null
      ..setPlayerMode(PlayerMode.lowLatency)
      ..setReleaseMode(ReleaseMode.stop);
    await p.stop();
    await p.play(AssetSource(_file(sound)));
  }
}

final soundEffectsOnProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).watchSoundEffects(),
);

final sfxProvider = Provider<Sfx>((ref) {
  // Keep the setting stream alive so the check below is always current.
  ref.listen(soundEffectsOnProvider, (_, _) {});
  return AudioSfx(
    enabled: () => ref.read(soundEffectsOnProvider).value ?? true,
  );
});
