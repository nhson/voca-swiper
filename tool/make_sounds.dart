// Synthesizes the app's short sound effects into assets/sounds/*.wav.
// Made from plain sine tones here, so there is no third-party license.
//   dart run tool/make_sounds.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _rate = 22050;

/// One tone: [freq] Hz starting at [start] s for [length] s.
typedef Note = ({double freq, double start, double length, double gain});

Note n(double freq, double start, double length, [double gain = 1]) =>
    (freq: freq, start: start, length: length, gain: gain);

Float64List render(List<Note> notes, {double tail = 0.05}) {
  final end = notes.map((x) => x.start + x.length).reduce(math.max) + tail;
  final out = Float64List((end * _rate).ceil());
  for (final note in notes) {
    final from = (note.start * _rate).round();
    final count = (note.length * _rate).round();
    for (var i = 0; i < count && from + i < out.length; i++) {
      final t = i / _rate;
      // Fast attack, exponential decay: a soft "bell" rather than a beep.
      final attack = math.min(1.0, t / 0.006);
      final decay = math.exp(-t * 6 / note.length);
      final v =
          math.sin(2 * math.pi * note.freq * t) +
          0.35 * math.sin(4 * math.pi * note.freq * t) +
          0.12 * math.sin(6 * math.pi * note.freq * t);
      out[from + i] += v * attack * decay * note.gain;
    }
  }
  return out;
}

/// A short pitch sweep, for the card "whoosh/pop".
Float64List sweep(double f0, double f1, double length) {
  final count = (length * _rate).round();
  final out = Float64List(count);
  var phase = 0.0;
  for (var i = 0; i < count; i++) {
    final p = i / count;
    final f = f0 + (f1 - f0) * p;
    phase += 2 * math.pi * f / _rate;
    final env = math.sin(math.pi * p);
    out[i] = math.sin(phase) * env * env;
  }
  return out;
}

void write(String name, Float64List samples, {double volume = 0.5}) {
  final peak = samples.fold<double>(0, (m, v) => math.max(m, v.abs()));
  final pcm = Int16List(samples.length);
  for (var i = 0; i < samples.length; i++) {
    pcm[i] = (samples[i] / peak * volume * 32767).round();
  }
  final data = pcm.buffer.asUint8List();
  final h = ByteData(44)
    ..setUint32(0, 0x52494646) // RIFF
    ..setUint32(4, 36 + data.length, Endian.little)
    ..setUint32(8, 0x57415645) // WAVE
    ..setUint32(12, 0x666d7420) // fmt
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, _rate, Endian.little)
    ..setUint32(28, _rate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461) // data
    ..setUint32(40, data.length, Endian.little);
  final file = File('assets/sounds/$name.wav')..createSync(recursive: true);
  file.writeAsBytesSync([...h.buffer.asUint8List(), ...data]);
  stdout.writeln('${file.path}  ${file.lengthSync()} bytes');
}

void main() {
  // C major: C5 523, E5 659, G5 784, C6 1047.
  write('swipe', sweep(380, 900, 0.12), volume: 0.35);
  write('knew', render([n(784, 0, 0.18), n(1047, 0.09, 0.3)]), volume: 0.45);
  write('almost', render([n(659, 0, 0.18), n(784, 0.09, 0.25)]), volume: 0.4);
  // Gentle, not a "wrong" buzzer: a soft falling pair.
  write('not_yet', render([n(440, 0, 0.16), n(392, 0.1, 0.25)]), volume: 0.3);
  write(
    'cheer',
    render([
      n(523, 0, 0.2),
      n(659, 0.11, 0.2),
      n(784, 0.22, 0.2),
      n(1047, 0.33, 0.6),
      n(784, 0.33, 0.6, 0.5),
    ]),
    volume: 0.5,
  );
  write('tap', render([n(1200, 0, 0.06)], tail: 0.01), volume: 0.25);
}
