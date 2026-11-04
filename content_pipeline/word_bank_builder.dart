/// Builds the bundled word bank from content_pipeline/source/.
///
/// Pure Dart (no Flutter) so it runs with `dart run` and inside tests.
library;

import 'dart:convert';

const cefrLevels = ['preA1', 'A1', 'A2', 'B1', 'B2'];
const partsOfSpeech = {'noun', 'verb', 'adjective', 'number', 'adverb'};

class WordBankBuildException implements Exception {
  WordBankBuildException(this.errors);
  final List<String> errors;
  @override
  String toString() => 'Word bank has ${errors.length} error(s):\n'
      '${errors.map((e) => '  - $e').join('\n')}';
}

/// Parses [source] (words.psv) into the JSON bank. Throws
/// [WordBankBuildException] listing every problem found.
Map<String, Object?> buildWordBank({
  required String source,
  required int version,
  Set<String> blocklist = const {},
}) {
  final errors = <String>[];
  final rows = <({int line, List<String> f})>[];
  final lines = const LineSplitter().convert(source);
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final f = line.split('|').map((s) => s.trim()).toList();
    if (f.length != 10) {
      errors.add('line ${i + 1}: expected 10 fields, got ${f.length}');
      continue;
    }
    rows.add((line: i + 1, f: f));
  }

  final textCounts = <String, int>{};
  for (final r in rows) {
    textCounts.update(r.f[0].toLowerCase(), (n) => n + 1, ifAbsent: () => 1);
  }

  final ids = <String>{};
  final words = <Map<String, Object?>>[];
  final rankByLevel = <String, int>{};
  for (final r in rows) {
    final [
      text,
      pos,
      cefr,
      minAgeRaw,
      themes,
      emoji,
      definition,
      example,
      vi,
      forms
    ] = r.f;
    final where = 'line ${r.line} ($text)';

    if (text.isEmpty) errors.add('$where: empty word');
    if (!partsOfSpeech.contains(pos)) {
      errors.add('$where: unknown part of speech "$pos"');
    }
    if (!cefrLevels.contains(cefr)) {
      errors.add('$where: unknown CEFR level "$cefr"');
    }
    final minAge = int.tryParse(minAgeRaw);
    if (minAge == null || minAge < 4 || minAge > 15) {
      errors.add('$where: minAge must be 4–15');
    }
    if (definition.isEmpty) errors.add('$where: missing definition');
    if (example.isEmpty) errors.add('$where: missing example');
    if (vi.isEmpty) errors.add('$where: missing Vietnamese translation');
    for (final token in RegExp(r"[a-z']+").allMatches(
      '$text $definition $example'.toLowerCase(),
    )) {
      if (blocklist.contains(token.group(0))) {
        errors.add('$where: blocked word "${token.group(0)}"');
      }
    }

    final formMap = <String, String>{};
    if (forms.isNotEmpty) {
      for (final kv in forms.split(',')) {
        final parts = kv.split('=');
        if (parts.length != 2 ||
            parts[0].trim().isEmpty ||
            parts[1].trim().isEmpty) {
          errors.add('$where: bad form "$kv" (use key=value)');
        } else {
          formMap[parts[0].trim()] = parts[1].trim();
        }
      }
    }

    final slug = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final id = textCounts[text.toLowerCase()]! > 1 ? '$slug-$pos' : slug;
    if (!ids.add(id)) errors.add('$where: duplicate id "$id"');

    final rank = rankByLevel.update(cefr, (n) => n + 1, ifAbsent: () => 1);
    words.add({
      'id': id,
      'text': text,
      'pos': pos,
      'cefr': cefr,
      'minAge': minAge,
      'themes': themes
          .split(';')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      'emoji': emoji.isEmpty ? null : emoji,
      'definition': definition,
      'examples': [example],
      'translations': {'vi': vi},
      'forms': formMap,
      'rank': rank,
    });
  }

  if (errors.isNotEmpty) throw WordBankBuildException(errors);
  return {'version': version, 'words': words};
}

Set<String> parseBlocklist(String source) => const LineSplitter()
    .convert(source)
    .map((l) => l.trim().toLowerCase())
    .where((l) => l.isNotEmpty && !l.startsWith('#'))
    .toSet();

String encodeWordBank(Map<String, Object?> bank) =>
    '${const JsonEncoder.withIndent(' ').convert(bank)}\n';
