// Usage (from the repo root): dart run content_pipeline/build_word_bank.dart
import 'dart:io';

import 'sources.dart';
import 'word_bank_builder.dart';

const outputPath = 'assets/word_bank/word_bank.json';

void main() {
  final src = WordSources.read();
  final bank = buildWordBank(
    source: src.words,
    version: src.version,
    blocklist: src.blocklist,
  );
  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(encodeWordBank(bank));
  final words = (bank['words']! as List).cast<Map<String, Object?>>();
  final byLevel = <String, int>{};
  for (final w in words) {
    byLevel.update(w['cefr']! as String, (n) => n + 1, ifAbsent: () => 1);
  }
  stdout.writeln(
    'Wrote $outputPath: version ${bank['version']}, ${words.length} words '
    '$byLevel',
  );
}
