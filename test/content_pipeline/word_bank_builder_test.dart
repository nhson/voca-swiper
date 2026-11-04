import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../content_pipeline/word_bank_builder.dart';

const header = '# comment\n';

String row(
  String text, {
  String pos = 'noun',
  String cefr = 'preA1',
  String age = '4',
  String def = 'A thing.',
  String ex = 'A thing is here.',
  String vi = 'cái',
  String forms = '',
}) => '$text|$pos|$cefr|$age|things|📦|$def|$ex|$vi|$forms';

void main() {
  test('bundled asset is up to date with content_pipeline/source', () {
    final rebuilt = encodeWordBank(
      buildWordBank(
        source: File('content_pipeline/source/words.psv').readAsStringSync(),
        version: int.parse(
          File('content_pipeline/source/version.txt').readAsStringSync().trim(),
        ),
        blocklist: parseBlocklist(
          File('content_pipeline/source/blocklist.txt').readAsStringSync(),
        ),
      ),
    );
    expect(
      File('assets/word_bank/word_bank.json').readAsStringSync(),
      rebuilt,
      reason: 'Run: dart run content_pipeline/build_word_bank.dart',
    );
  });

  test('bundled bank has Pre-A1 and A1 words, each with Vietnamese', () {
    final bank = buildWordBank(
      source: File('content_pipeline/source/words.psv').readAsStringSync(),
      version: 1,
    );
    final words = (bank['words']! as List).cast<Map<String, Object?>>();
    expect(words.where((w) => w['cefr'] == 'preA1').length, greaterThan(150));
    expect(words.where((w) => w['cefr'] == 'A1').length, greaterThan(150));
    for (final w in words) {
      expect(
        (w['translations']! as Map)['vi'],
        isNotEmpty,
        reason: '${w['id']}',
      );
    }
  });

  test('parses fields, forms and ranks per level', () {
    final bank = buildWordBank(
      source:
          '$header${row('mouse', forms: 'plural=mice')}\n'
          '${row('cat')}\n${row('owl', cefr: 'A1')}',
      version: 3,
    );
    expect(bank['version'], 3);
    final words = (bank['words']! as List).cast<Map<String, Object?>>();
    expect(words[0]['id'], 'mouse');
    expect(words[0]['forms'], {'plural': 'mice'});
    expect(words.map((w) => w['rank']), [1, 2, 1]);
    expect(words[0]['examples'], ['A thing is here.']);
  });

  test('same text with different part of speech gets distinct ids', () {
    final bank = buildWordBank(
      source: '${row('orange', pos: 'adjective')}\n${row('orange')}',
      version: 1,
    );
    final ids = (bank['words']! as List).map((w) => (w as Map)['id']);
    expect(ids, ['orange-adjective', 'orange-noun']);
  });

  test('ids are slugs', () {
    final bank = buildWordBank(source: row('ice cream'), version: 1);
    expect(((bank['words']! as List).single as Map)['id'], 'ice-cream');
  });

  group('rejects', () {
    void expectError(
      String source,
      String fragment, {
      Set<String> block = const {},
    }) {
      expect(
        () => buildWordBank(source: source, version: 1, blocklist: block),
        throwsA(
          isA<WordBankBuildException>().having(
            (e) => e.errors.join('\n'),
            'errors',
            contains(fragment),
          ),
        ),
      );
    }

    test('unknown CEFR level', () => expectError(row('x', cefr: 'C2'), 'CEFR'));
    test(
      'unknown part of speech',
      () => expectError(row('x', pos: 'thing'), 'part of speech'),
    );
    test('bad age', () => expectError(row('x', age: '2'), 'minAge'));
    test(
      'missing translation',
      () => expectError(row('x', vi: ''), 'Vietnamese'),
    );
    test('wrong field count', () => expectError('a|b|c', '10 fields'));
    test(
      'duplicate word',
      () => expectError('${row('x')}\n${row('x')}', 'duplicate'),
    );
    test('bad form', () => expectError(row('x', forms: 'plural'), 'bad form'));
    test(
      'blocked word in example',
      () => expectError(
        row('x', ex: 'A bad word here.'),
        'blocked',
        block: {'bad'},
      ),
    );
  });
}
