import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../content_pipeline/sources.dart';
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
    final src = WordSources.read();
    final rebuilt = encodeWordBank(
      buildWordBank(
        source: src.words,
        version: src.version,
        blocklist: src.blocklist,
      ),
    );
    expect(
      File('assets/word_bank/word_bank.json').readAsStringSync(),
      rebuilt,
      reason: 'Run: dart run content_pipeline/build_word_bank.dart',
    );
  });

  test('shipped word ids never change (progress points at them)', () {
    final src = WordSources.read();
    final ids = {
      for (final w
          in buildWordBank(source: src.words, version: 1)['words']! as List)
        (w as Map)['id'],
    };
    final shipped = File(
      '${WordSources.root}/shipped_ids.txt',
    ).readAsLinesSync().where((l) => l.isNotEmpty && !l.startsWith('#'));
    expect(shipped.length, greaterThanOrEqualTo(392));
    for (final id in shipped) {
      expect(ids, contains(id), reason: 'shipped id "$id" was renamed/removed');
    }
  });

  test('source is one file per level, read in order', () {
    final files = WordSources.files().map((f) => f.uri.pathSegments.last);
    expect(files, ['01-preA1.psv', '02-A1.psv', '03-A2.psv', '04-B1.psv']);
  });

  group('bundled bank (feat-014)', () {
    final src = WordSources.read();
    final words =
        (buildWordBank(source: src.words, version: 1)['words']! as List)
            .cast<Map<String, Object?>>();
    int count(String cefr) => words.where((w) => w['cefr'] == cefr).length;

    test('about 1,000 Pre-A1 + A1 words, and A2 and B1 levels', () {
      expect(count('preA1') + count('A1'), greaterThanOrEqualTo(950));
      expect(count('preA1'), greaterThan(300));
      expect(count('A2'), greaterThanOrEqualTo(250));
      expect(count('B1'), greaterThanOrEqualTo(250));
    });

    test('every word has Vietnamese, a definition and an example', () {
      for (final w in words) {
        final id = w['id'];
        expect((w['translations']! as Map)['vi'], isNotEmpty, reason: '$id');
        expect(w['definition'], isNotEmpty, reason: '$id');
        expect(w['examples'], isNotEmpty, reason: '$id');
      }
    });

    test('Pre-A1 is picture-led: most words have a picture', () {
      final pre = words.where((w) => w['cefr'] == 'preA1');
      final pictured = pre.where((w) => w['emoji'] != null).length;
      expect(pictured / pre.length, greaterThan(0.8));
    });

    test('A2 and B1 words are for ages 7+', () {
      for (final w in words.where(
        (w) => w['cefr'] == 'A2' || w['cefr'] == 'B1',
      )) {
        expect(
          w['minAge']! as int,
          greaterThanOrEqualTo(7),
          reason: '${w['id']}',
        );
      }
    });

    test('A2/B1 pictures show on older Android (Emoji 12, no ZWJ)', () {
      // Emoji 12 code points in U+1FA70–1FAFF; anything else there is newer.
      const emoji12 = {
        0x1FA70, 0x1FA71, 0x1FA72, 0x1FA73, 0x1FA78, 0x1FA79, 0x1FA7A, //
        0x1FA80, 0x1FA81, 0x1FA82, 0x1FA90, 0x1FA91, 0x1FA92, 0x1FA93,
        0x1FA94, 0x1FA95,
      };
      // Emoji 13+ outside that block, e.g. 🥲 🛟 🛝 🛞 🛻 🛼 🦬 🦣 🦫 🦭.
      const newer = {
        0x1F972, 0x1F977, 0x1F978, 0x1F979, 0x1F6DD, 0x1F6DE, 0x1F6DF, //
        0x1F6FB, 0x1F6FC, 0x1F6D6, 0x1F6D7, 0x1F9AC, 0x1F9AD, 0x1F9AB,
        0x1F9A3, 0x1F9A4, 0x1F90C, 0x1F9CC,
      };
      for (final w in words.where(
        (w) => w['cefr'] == 'A2' || w['cefr'] == 'B1',
      )) {
        final e = w['emoji'] as String?;
        if (e == null) continue;
        final tooNew = e.runes.where(
          (r) =>
              (r >= 0x1FA70 && r <= 0x1FAFF && !emoji12.contains(r)) ||
              newer.contains(r),
        );
        expect(tooNew, isEmpty, reason: '${w['id']} $e');
        expect(e.contains('‍'), isFalse, reason: '${w['id']} $e (ZWJ)');
      }
    });

    test('grammar forms on A2/B1 verbs and nouns', () {
      final upper = words.where((w) => w['cefr'] == 'A2' || w['cefr'] == 'B1');
      final withForms = upper.where((w) => (w['forms']! as Map).isNotEmpty);
      expect(withForms.length, greaterThan(100));
    });
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

  test('more parts of speech and grammar forms (feat-014)', () {
    final bank = buildWordBank(
      source:
          '${row('under', pos: 'preposition')}\n'
          '${row('they', pos: 'pronoun')}\n'
          '${row('because', pos: 'conjunction')}\n'
          '${row('every', pos: 'determiner')}\n'
          '${row('go', pos: 'verb', forms: 'past=went,past participle=gone')}\n'
          '${row('good', pos: 'adjective', forms: 'comparative=better,superlative=best')}',
      version: 1,
    );
    final words = (bank['words']! as List).cast<Map<String, Object?>>();
    expect(words[4]['forms'], {'past': 'went', 'past participle': 'gone'});
    expect(words[5]['forms'], {'comparative': 'better', 'superlative': 'best'});
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
      'unknown form name',
      () => expectError(row('x', forms: 'tense=went'), 'unknown form'),
    );
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
