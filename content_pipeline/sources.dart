/// Reads content_pipeline/source/: one word file per level in
/// source/words/ (read in file-name order), version.txt and blocklist.txt.
library;

import 'dart:io';

import 'word_bank_builder.dart';

class WordSources {
  const WordSources({
    required this.words,
    required this.version,
    required this.blocklist,
  });

  static const root = 'content_pipeline/source';

  /// All rows, the level files joined in order.
  final String words;
  final int version;
  final Set<String> blocklist;

  static List<File> files() =>
      Directory('$root/words')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.psv'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  static WordSources read() => WordSources(
    words: [for (final f in files()) f.readAsStringSync()].join('\n'),
    version: int.parse(File('$root/version.txt').readAsStringSync().trim()),
    blocklist: parseBlocklist(File('$root/blocklist.txt').readAsStringSync()),
  );
}
