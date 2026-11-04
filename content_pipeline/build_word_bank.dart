// Usage (from the repo root): dart run content_pipeline/build_word_bank.dart
import 'dart:io';

import 'word_bank_builder.dart';

const outputPath = 'assets/word_bank/word_bank.json';

void main() {
  final bank = buildWordBank(
    source: File('content_pipeline/source/words.psv').readAsStringSync(),
    version: int.parse(
      File('content_pipeline/source/version.txt').readAsStringSync().trim(),
    ),
    blocklist: parseBlocklist(
      File('content_pipeline/source/blocklist.txt').readAsStringSync(),
    ),
  );
  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(encodeWordBank(bank));
  final words = bank['words']! as List;
  stdout.writeln(
    'Wrote $outputPath: version ${bank['version']}, '
    '${words.length} words',
  );
}
