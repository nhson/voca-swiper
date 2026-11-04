import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the AGENTS.md rule: lib/core is pure Dart and imports nothing from
/// Flutter, lib/data or lib/features.
void main() {
  test('lib/core has no Flutter, data or feature imports', () {
    final forbidden = RegExp(
      r'''import\s+['"](package:flutter/|package:voca_swiper/(data|features|app)/|\.\./(data|features|app)/)''',
    );
    final offenders = <String>[];
    for (final f in Directory('lib/core').listSync(recursive: true)) {
      if (f is File && f.path.endsWith('.dart')) {
        if (forbidden.hasMatch(f.readAsStringSync())) offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
