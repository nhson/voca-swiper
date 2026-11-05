import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/core/progress/level_progression.dart';
import 'package:voca_swiper/core/progress/progress_stats.dart';

void main() {
  const rules = LevelProgression();

  group('level up', () {
    CefrLevel? up({
      int mastered = 80,
      int total = 100,
      CefrLevel? next = CefrLevel.a2,
      bool locked = false,
    }) => rules.levelUp(
      mastered: mastered,
      total: total,
      next: next,
      locked: locked,
    );

    test('at 80% of the level mastered', () {
      expect(up(mastered: 80), CefrLevel.a2);
      expect(up(mastered: 79), isNull);
      expect(up(mastered: 100), CefrLevel.a2);
    });

    test('not when the parent locked the level', () {
      expect(up(locked: true), isNull);
    });

    test('not when there is no next level for this child', () {
      expect(up(next: null), isNull);
    });

    test('not on an empty level', () {
      expect(up(mastered: 0, total: 0), isNull);
    });
  });

  group('next-level preview', () {
    const cur = ['c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8', 'c9', 'c10'];
    const pre = ['n1', 'n2', 'n3'];

    test('every 5th new word is from the next level', () {
      expect(rules.mixPreview(cur, pre, count: 5), [
        'c1',
        'c2',
        'c3',
        'c4',
        'n1',
      ]);
      expect(rules.mixPreview(cur, pre, count: 10), [
        'c1', 'c2', 'c3', 'c4', 'n1', //
        'c5', 'c6', 'c7', 'c8', 'n2',
      ]);
    });

    test('fewer than 5 new words today → no preview', () {
      expect(rules.mixPreview(cur, pre, count: 4), ['c1', 'c2', 'c3', 'c4']);
    });

    test('no preview words → only current words', () {
      expect(rules.mixPreview(cur, const [], count: 5), cur.take(5));
    });

    test('current level used up → the next level fills in', () {
      expect(rules.mixPreview(const ['c1'], pre, count: 5), [
        'c1',
        'n1',
        'n2',
        'n3',
      ]);
    });

    test('slots for a daily goal', () {
      expect(LevelProgression.previewSlots(4), 0);
      expect(LevelProgression.previewSlots(5), 1);
      expect(LevelProgression.previewSlots(12), 2);
      expect(LevelProgression.previewSlots(15), 3);
    });
  });

  group('step-back suggestion', () {
    final now = DateTime.utc(2026, 11, 20, 12);
    SessionStat s(int daysAgo, double accuracy, {int answered = 10}) =>
        SessionStat(
          startedAt: now.subtract(Duration(days: daysAgo, hours: 1)),
          durationSec: 300,
          answered: answered,
          accuracy: accuracy,
        );
    final hardWeek = [s(6, 0.4), s(4, 0.3), s(2, 0.45), s(0, 0.4)];

    StepBackSuggestion? suggest({
      List<SessionStat>? sessions,
      CefrLevel? lower = CefrLevel.preA1,
      bool locked = false,
      int daysAtLevel = 10,
      DateTime? dismissedAt,
    }) => rules.stepBack(
      lower: lower,
      locked: locked,
      levelSince: now.subtract(Duration(days: daysAtLevel)),
      dismissedAt: dismissedAt,
      sessions: sessions ?? hardWeek,
      now: now,
    );

    test('under 50% right over the last week → suggest one level down', () {
      final r = suggest()!;
      expect(r.to, CefrLevel.preA1);
      expect(r.accuracy, closeTo((0.4 + 0.3 + 0.45 + 0.4) / 4, 1e-9));
    });

    test('accuracy is weighted by answers', () {
      // A plain mean of the three sessions would be 33%; by answers it is
      // (0.4 + 14 + 0.8) / 28 = 54%.
      final r = suggest(
        sessions: [
          s(5, 0.1, answered: 4),
          s(3, 0.7, answered: 20),
          s(1, 0.2, answered: 4),
        ],
      );
      expect(r, isNull);
    });

    test('50% or more → no suggestion', () {
      expect(suggest(sessions: [s(6, 0.5), s(4, 0.5), s(2, 0.5)]), isNull);
    });

    test('needs practice on at least 3 days of the week', () {
      expect(suggest(sessions: [s(2, 0.1), s(2, 0.2), s(0, 0.1)]), isNull);
      expect(suggest(sessions: [s(4, 0.1), s(2, 0.2), s(0, 0.1)]), isNotNull);
    });

    test('only the last 7 days count', () {
      expect(
        suggest(sessions: [s(12, 0.1), s(10, 0.1), s(9, 0.1), s(1, 0.9)]),
        isNull,
      );
    });

    test('not in the first week at a level', () {
      expect(suggest(daysAtLevel: 6), isNull);
      expect(suggest(daysAtLevel: 7), isNotNull);
    });

    test('not at the lowest level or when locked', () {
      expect(suggest(lower: null), isNull);
      expect(suggest(locked: true), isNull);
    });

    test('"not now" quiets it for a week', () {
      expect(
        suggest(dismissedAt: now.subtract(const Duration(days: 3))),
        isNull,
      );
      expect(
        suggest(dismissedAt: now.subtract(const Duration(days: 7))),
        isNotNull,
      );
    });
  });
}
