import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/core/placement/placement.dart';

/// 60 words per level, ids like `A1-07` (rank 7 at A1).
Map<CefrLevel, List<String>> bank({
  List<CefrLevel> levels = const [
    CefrLevel.preA1,
    CefrLevel.a1,
    CefrLevel.a2,
    CefrLevel.b1,
  ],
  int perLevel = 60,
}) => {
  for (final l in levels)
    l: [
      for (var i = 1; i <= perLevel; i++)
        '${l.code}-${i.toString().padLeft(2, '0')}',
    ],
};

CefrLevel levelOf(String id) => CefrLevel.fromCode(id.split('-').first);

PlacementTest make({
  Map<CefrLevel, List<String>>? pool,
  CefrLevel start = CefrLevel.a1,
  Set<String>? checkable,
  int seed = 1,
}) {
  final p = pool ?? bank();
  return PlacementTest(
    pool: p,
    start: start,
    checkable: checkable ?? {for (final ids in p.values) ...ids},
    random: Random(seed),
  );
}

/// Plays the whole test. [knows] says whether the child taps "I know it";
/// [passesCheck] whether they then pick the right picture.
List<String> play(
  PlacementTest t, {
  required bool Function(String id) knows,
  bool Function(String id)? passesCheck,
}) {
  final asked = <String>[];
  var guard = 0;
  while (!t.isFinished) {
    if (++guard > 200) fail('placement never finished');
    final check = t.pendingCheck;
    if (check != null) {
      t.answerCheck((passesCheck ?? knows)(check));
      continue;
    }
    final id = t.current!;
    asked.add(id);
    t.answer(known: knows(id));
  }
  return asked;
}

bool upTo(CefrLevel max, String id) => levelOf(id).index <= max.index;

void main() {
  group('sampling', () {
    test('first block is at the start level, spread across the level', () {
      final t = make(start: CefrLevel.a1);
      final block = <String>[];
      for (var i = 0; i < PlacementTest.defaultBlockSize; i++) {
        block.add(t.current!);
        t.answer(known: false); // no checks after "not yet"
      }
      expect(block.map(levelOf).toSet(), {CefrLevel.a1});
      // One word from each sixth of the level (ranks 1–10, 11–20, …).
      final ranks = [for (final id in block) int.parse(id.split('-')[1])];
      for (var i = 0; i < ranks.length; i++) {
        expect(ranks[i], inInclusiveRange(i * 10 + 1, i * 10 + 10));
      }
    });

    test('24 words, never the same word twice', () {
      final asked = play(make(), knows: (id) => upTo(CefrLevel.a1, id));
      expect(asked, hasLength(24));
      expect(asked.toSet(), hasLength(24));
    });

    test('prefers words that can be checked within each slice', () {
      final p = bank();
      final checkable = {
        for (final ids in p.values)
          for (var i = 0; i < ids.length; i += 10) ids[i], // ranks 1, 11, …
      };
      final t = make(pool: p, checkable: checkable);
      final block = <String>[];
      for (var i = 0; i < 6; i++) {
        block.add(t.current!);
        t.answer(known: false);
      }
      expect(block.every(checkable.contains), isTrue);
    });

    test('a start level with no words falls back to the nearest lower one', () {
      final t = make(
        pool: bank(levels: [CefrLevel.preA1, CefrLevel.a1]),
        start: CefrLevel.b1,
      );
      expect(levelOf(t.current!), CefrLevel.a1);
    });

    test('a tiny bank finishes once it runs out of words', () {
      final t = make(pool: bank(levels: [CefrLevel.preA1], perLevel: 8));
      final asked = play(t, knows: (_) => true);
      expect(asked.toSet(), hasLength(8));
      expect(t.result.level, CefrLevel.preA1);
    });
  });

  group('level choice', () {
    test('knows everything → climbs to the top level', () {
      final t = make(start: CefrLevel.a1);
      final asked = play(t, knows: (_) => true);
      expect(asked.take(6).map(levelOf).toSet(), {CefrLevel.a1});
      expect(asked.skip(6).take(6).map(levelOf).toSet(), {CefrLevel.a2});
      expect(asked.skip(12).map(levelOf).toSet(), {CefrLevel.b1});
      expect(t.result.level, CefrLevel.b1);
    });

    test('knows nothing → steps down to the lowest level', () {
      final t = make(start: CefrLevel.a2);
      play(t, knows: (_) => false);
      expect(t.result.level, CefrLevel.preA1);
    });

    test('knows Pre-A1 and A1 but not A2 → A1', () {
      final t = make(start: CefrLevel.a1);
      play(t, knows: (id) => upTo(CefrLevel.a1, id));
      expect(t.result.level, CefrLevel.a1);
    });

    test('starting high, knows only Pre-A1 → Pre-A1', () {
      final t = make(start: CefrLevel.a2);
      final asked = play(t, knows: (id) => upTo(CefrLevel.preA1, id));
      expect(asked.first, startsWith('A2'));
      expect(t.result.level, CefrLevel.preA1);
    });

    test('a level passes at 70%: 5 of 6 passes, 4 of 6 does not', () {
      // Only A1 and A2 in the bank; every A1 word known. The child knows
      // the first [n] A2 words they are shown.
      CefrLevel placeWith(int n) {
        final t = make(
          pool: bank(levels: [CefrLevel.a1, CefrLevel.a2]),
          start: CefrLevel.a2,
          checkable: const {},
        );
        var seenA2 = 0;
        play(
          t,
          knows: (id) {
            if (levelOf(id) == CefrLevel.a1) return true;
            return seenA2++ % 6 < n;
          },
        );
        return t.result.level;
      }

      expect(placeWith(5), CefrLevel.a2);
      expect(placeWith(4), CefrLevel.a1);
    });

    test('score per level counts every block at that level', () {
      final t = make(
        pool: bank(levels: [CefrLevel.a1]),
        start: CefrLevel.a1,
        checkable: const {},
      );
      var n = 0;
      // 4 blocks at A1 (nowhere to move): 17 of 24 known = 71%.
      play(t, knows: (_) => n++ < 17);
      expect(t.result.scores[CefrLevel.a1], closeTo(17 / 24, 1e-9));
      expect(t.result.level, CefrLevel.a1);
    });
  });

  group('anti-guessing', () {
    test('the first checkable "I know it" is checked straight away', () {
      final t = make();
      t.answer(known: true);
      expect(t.pendingCheck, isNotNull);
      expect(t.current, isNull);
    });

    test('then at most one check every 4 words', () {
      final t = make();
      final checkedAt = <int>[];
      var answered = 0;
      while (!t.isFinished) {
        if (t.pendingCheck != null) {
          checkedAt.add(answered);
          t.answerCheck(true);
        } else {
          answered++;
          t.answer(known: true);
        }
      }
      expect(checkedAt.first, 1);
      for (var i = 1; i < checkedAt.length; i++) {
        expect(checkedAt[i] - checkedAt[i - 1], greaterThanOrEqualTo(4));
      }
      expect(checkedAt.length, greaterThanOrEqualTo(5));
    });

    test('no check after "not yet" or on a word that cannot be checked', () {
      final t = make(checkable: const {});
      t.answer(known: true);
      expect(t.pendingCheck, isNull);
      final u = make();
      u.answer(known: false);
      expect(u.pendingCheck, isNull);
    });

    test('a failed check makes that word unknown', () {
      final t = make(pool: bank(levels: [CefrLevel.a1]));
      t.answer(known: true);
      final checked = t.pendingCheck!;
      t.answerCheck(false);
      expect(t.result.knownWords, isNot(contains(checked)));
    });

    test('taps "I know it" on everything but fails the checks → lowest', () {
      final t = make(start: CefrLevel.a2);
      play(t, knows: (_) => true, passesCheck: (_) => false);
      expect(t.result.level, CefrLevel.preA1);
      expect(t.result.scores.values.every((s) => s < 0.7), isTrue);
    });

    test('failed checks discount the unchecked "I know it" answers', () {
      // Knows A1 for real, but pretends to know everything at A2: checks
      // at A2 fail, so unchecked A2 "knows" are not trusted.
      final t = make(start: CefrLevel.a1);
      play(t, knows: (_) => true, passesCheck: (id) => upTo(CefrLevel.a1, id));
      expect(t.result.level, CefrLevel.a1);
    });

    test('cannotCheck skips the check without counting it', () {
      final t = make();
      t.answer(known: true);
      final id = t.pendingCheck!;
      t.cannotCheck();
      expect(t.pendingCheck, isNull);
      expect(t.current, isNotNull);
      expect(t.result.knownWords, contains(id));
      // The next checkable "know" is checked instead.
      t.answer(known: true);
      expect(t.pendingCheck, isNotNull);
    });
  });

  group('result', () {
    test('known words are the trusted "I know it" answers, in order', () {
      final t = make(start: CefrLevel.preA1);
      final asked = play(t, knows: (id) => upTo(CefrLevel.preA1, id));
      expect(t.result.knownWords.keys.toList(), [
        for (final id in asked)
          if (levelOf(id) == CefrLevel.preA1) id,
      ]);
    });

    test('firstSessionWords: known words at or below the level first', () {
      final r = PlacementResult(
        level: CefrLevel.a1,
        scores: const {},
        knownWords: {
          for (final id in ['A2-01', 'A1-03', 'preA1-02', 'A1-09'])
            id: levelOf(id),
        },
      );
      expect(r.firstSessionWords(fill: const ['A1-01', 'A1-03', 'A1-02']), [
        'A1-03',
        'preA1-02',
        'A1-09',
        'A1-01',
        'A1-02',
      ]);
      expect(r.firstSessionWords(fill: const [], count: 2), [
        'A1-03',
        'preA1-02',
      ]);
    });
  });
}
