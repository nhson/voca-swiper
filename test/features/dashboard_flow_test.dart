import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/quiz/quiz_builder.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

/// feat-017: the parent dashboard shows the numbers behind seeded data.
void main() {
  late AppDatabase db;
  late int bi;
  final now = testNow; // Wednesday 4 Nov 2026

  setUp(() async {
    db = await seededDb([
      w('cat', rank: 1, emoji: '🐱', vi: 'con mèo'),
      w('dog', rank: 2, emoji: '🐶', vi: 'con chó'),
      w('sun', rank: 3, emoji: '☀️', vi: 'mặt trời'),
      w('bird', rank: 4, emoji: '🐦', vi: 'con chim'),
      w('fish', rank: 5, emoji: '🐟', vi: 'con cá'),
      w('apple', cefr: 'A1', rank: 1, emoji: '🍎', vi: 'quả táo'),
    ]);
    await createParent(db);
    bi = await createKid(db);
    final progress = ProgressRepository(db);
    WordSchedule s(WordState state, int wrong, int right) => WordSchedule(
      state: state,
      easeFactor: 2.3,
      intervalDays: state == WordState.mastered ? 30 : 1,
      repetitions: right,
      nextReviewAt: now.add(const Duration(days: 1)),
      lastAnsweredAt: now,
      correctCount: right,
      wrongCount: wrong,
    );
    await progress.save(bi, 'cat', s(WordState.learning, 4, 1), now: now);
    await progress.save(bi, 'dog', s(WordState.review, 2, 3), now: now);
    await progress.save(
      bi,
      'sun',
      s(WordState.mastered, 5, 6),
      now: now.subtract(const Duration(days: 20)),
    );
    await progress.save(
      bi,
      'bird',
      s(WordState.learning, 1, 0),
      now: now.subtract(const Duration(days: 9)),
    );
    for (final (daysAgo, minutes) in [(0, 10), (1, 4), (2, 12), (9, 20)]) {
      await progress.logSession(
        profileId: bi,
        startedAt: now.subtract(Duration(days: daysAgo)),
        durationSec: minutes * 60,
        reviewed: 5,
        newLearned: 1,
        accuracy: 0.7,
      );
    }
    for (final ok in [true, false, true]) {
      await progress.logQuiz(
        profileId: bi,
        wordId: 'sun',
        kind: QuizKind.pickPicture,
        correct: ok,
        at: now,
      );
    }
  });
  tearDown(() => db.close());

  String textOf(WidgetTester t, String key) =>
      t.widget<Text>(find.byKey(Key(key))).data!;

  Future<void> open(WidgetTester t, {Size? size}) async {
    await pumpApp(t, db, size: size ?? const Size(400, 860));
    await unlockParent(t);
    await t.tap(find.byKey(Key('parent-progress-$bi')));
    await t.pumpAndSettle();
  }

  Future<void> expectNumbers(WidgetTester t) async {
    expect(find.text("Bi's progress"), findsOneWidget);
    expect(
      textOf(t, 'dash-level-progress'),
      '1 of 5 Pre-A1 words mastered (20%). Moves up at 80%.',
    );
    expect(
      textOf(t, 'dash-goal'),
      'Practised 3 of 7 days · 2 at the 10-minute goal · about 9 min a day',
    );
    expect(
      textOf(t, 'dash-retention'),
      '67% right (2 of 3 quiz answers, 1 word)',
    );
    // 8 weeks, current (from Mon 2 Nov) last.
    expect(textOf(t, 'dash-words-7'), '2'); // cat, dog
    expect(textOf(t, 'dash-minutes-7'), '26'); // 10 + 4 + 12
    expect(textOf(t, 'dash-words-6'), '1'); // bird, Mon 26 Oct
    expect(textOf(t, 'dash-minutes-6'), '20');
    expect(textOf(t, 'dash-words-4'), '1'); // sun, 15 Oct
    expect(textOf(t, 'dash-minutes-4'), '0');

    // Struggling: cat (4 misses) before dog (2); sun is mastered, bird
    // missed once.
    await t.scrollUntilVisible(
      find.byKey(const Key('dash-struggling-dog')),
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('dashboard')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byKey(const Key('dash-struggling-cat')), findsOneWidget);
    expect(find.byKey(const Key('dash-struggling-sun')), findsNothing);
    expect(find.byKey(const Key('dash-struggling-bird')), findsNothing);
    expect(find.text('con mèo · 4 misses · 1 right'), findsOneWidget);
    expect(
      t.getTopLeft(find.byKey(const Key('dash-struggling-cat'))).dy,
      lessThan(t.getTopLeft(find.byKey(const Key('dash-struggling-dog'))).dy),
    );
  }

  testWidgets('numbers match the seeded data (phone)', (t) async {
    await open(t);
    await expectNumbers(t);
  });

  testWidgets('numbers match the seeded data (tablet)', (t) async {
    await open(t, size: const Size(1024, 1366));
    await expectNumbers(t);
  });

  testWidgets('the parent overrides the level from the dashboard', (t) async {
    await open(t);
    await t.tap(find.byKey(const Key('dash-level')));
    await t.pumpAndSettle();
    await t.tap(find.text('A1').last);
    await t.pumpAndSettle();
    final p = (await ProfileRepository(db).get(bi))!;
    expect(p.currentLevel, 'A1');
    expect(
      textOf(t, 'dash-level-progress'),
      '0 of 1 A1 words mastered (0%). Moves up at 80%.',
    );
  });

  testWidgets('a new child: zeros and no struggling words', (t) async {
    final mi = await createKid(db, name: 'Mi');
    await pumpApp(t, db);
    await unlockParent(t);
    await t.tap(find.byKey(Key('parent-progress-$mi')));
    await t.pumpAndSettle();
    expect(
      textOf(t, 'dash-goal'),
      'Practised 0 of 7 days · 0 at the 10-minute goal · about 0 min a day',
    );
    expect(textOf(t, 'dash-retention'), startsWith('Not enough'));
    await t.scrollUntilVisible(
      find.byKey(const Key('dash-no-struggling')),
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('dashboard')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byKey(const Key('dash-no-struggling')), findsOneWidget);
  });

  testWidgets("the child's view opens from the dashboard", (t) async {
    await open(t);
    await t.tap(find.byKey(const Key('dash-child-view')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('stat-mastered')), findsOneWidget);
  });
}
