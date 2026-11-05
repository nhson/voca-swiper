import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/reminders/reminder_planner.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

/// feat-019: "This week" on the child home and the weekly notification.
void main() {
  late AppDatabase db;
  late int bi;
  final now = testNow; // Wed 4 Nov 2026

  setUp(() async {
    db = await seededDb([
      w('cat', rank: 1, emoji: '🐱', vi: 'con mèo'),
      w('dog', rank: 2, emoji: '🐶', vi: 'con chó'),
      w('the', rank: 3, vi: 'cái'),
      w('sun', rank: 4, emoji: '☀️', vi: 'mặt trời'),
      w('moon', rank: 5, emoji: '🌙', vi: 'mặt trăng'),
      w('star', rank: 6, emoji: '⭐', vi: 'ngôi sao'),
    ]);
    await createParent(db);
    bi = await createKid(db);
  });
  tearDown(() => db.close());

  Future<void> seedWeek() async {
    final progress = ProgressRepository(db);
    WordSchedule s(WordState st, int right, DateTime last) => WordSchedule(
      state: st,
      easeFactor: 2.5,
      intervalDays: st == WordState.mastered ? 30 : 1,
      repetitions: right,
      // Not due today: the session has nothing waiting but the card shows.
      nextReviewAt: now.add(const Duration(days: 3)),
      lastAnsweredAt: last,
      correctCount: right,
      wrongCount: 0,
    );
    DateTime ago(int d) => now.subtract(Duration(days: d));
    await progress.save(
      bi,
      'cat',
      s(WordState.learning, 2, ago(1)),
      now: ago(2),
    );
    await progress.save(
      bi,
      'dog',
      s(WordState.learning, 3, ago(1)),
      now: ago(3),
    );
    await progress.save(
      bi,
      'the',
      s(WordState.learning, 5, ago(1)),
      now: ago(1),
    );
    await progress.save(
      bi,
      'sun',
      s(WordState.mastered, 6, ago(30)),
      now: ago(80),
    );
    await progress.save(
      bi,
      'moon',
      s(WordState.mastered, 6, ago(12)),
      now: ago(80),
    );
    await progress.save(
      bi,
      'star',
      s(WordState.mastered, 6, ago(20)),
      now: ago(80),
    );
    for (final (d, m) in [(1, 9), (3, 6), (9, 30)]) {
      await progress.logSession(
        profileId: bi,
        startedAt: ago(d),
        durationSec: m * 60,
        reviewed: 4,
        newLearned: 1,
        accuracy: 0.8,
      );
    }
  }

  String textOf(WidgetTester t, String key) => t
      .widget<Text>(
        find.descendant(of: find.byKey(Key(key)), matching: find.byType(Text)),
      )
      .data!;

  testWidgets('the child home shows this week, the word of the week and '
      'words to recall', (t) async {
    await seedWeek();
    final speaker = FakeSpeaker();
    await pumpApp(t, db, speaker: speaker);
    await t.tap(find.byKey(Key('profile-$bi')));
    await t.pumpAndSettle();

    expect(find.byKey(const Key('week-card')), findsOneWidget);
    expect(textOf(t, 'week-new'), '🆕 3 new words');
    expect(textOf(t, 'week-minutes'), '⏱ 15 min'); // 9 + 6; 9 days ago out
    // dog: most right answers among pictured new words ("the" has none).
    await t.ensureVisible(find.byKey(const Key('week-word')));
    await t.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('week-word')),
        matching: find.text('dog'),
      ),
      findsOneWidget,
    );
    await t.tap(find.byKey(const Key('week-word')));
    expect(speaker.said.last, 'dog');

    // Recall: the mastered words answered longest ago (sun, then star).
    expect(find.byKey(const Key('recall-sun')), findsOneWidget);
    expect(find.byKey(const Key('recall-star')), findsOneWidget);
    expect(find.byKey(const Key('recall-moon')), findsNothing);
    expect(find.byKey(const Key('recall-meaning-sun')), findsNothing);
    await t.ensureVisible(find.byKey(const Key('recall-sun')));
    await t.tap(find.byKey(const Key('recall-sun')));
    await t.pumpAndSettle();
    expect(speaker.said.last, 'sun');
    expect(find.text('mặt trời'), findsOneWidget);
  });

  testWidgets('a child with nothing yet sees no card', (t) async {
    await pumpApp(t, db);
    await t.tap(find.byKey(Key('profile-$bi')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('week-card')), findsNothing);
  });

  testWidgets('tablet: the card fits', (t) async {
    await seedWeek();
    await pumpApp(t, db, size: const Size(1024, 1366));
    await t.tap(find.byKey(Key('profile-$bi')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('week-card')), findsOneWidget);
  });

  testWidgets('parent turns on the weekly recap: one Sunday notification', (
    t,
  ) async {
    await seedWeek();
    final notifier = FakeReminderNotifier();
    await pumpApp(t, db, notifier: notifier);
    await unlockParent(t);
    await t.tap(find.text('Daily reminder'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('weekly-toggle')));
    await t.pumpAndSettle();

    final weekly = notifier.scheduled!
        .where((r) => r.title == ReminderPlanner.weeklyTitle)
        .toList();
    expect(weekly, hasLength(1));
    final at = weekly.single.at;
    expect(at.weekday, DateTime.sunday);
    expect(at.hour * 60 + at.minute, 18 * 60); // daily reminder is off
    expect(
      weekly.single.body,
      'Bi learned 3 new words this week! Word of the week: dog 🐶',
    );
    expect(find.byKey(const Key('next-weekly')), findsOneWidget);
    expect(find.textContaining('Word of the week: dog'), findsOneWidget);

    await t.tap(find.byKey(const Key('weekly-toggle')));
    await t.pumpAndSettle();
    expect(
      notifier.scheduled!.where((r) => r.title == ReminderPlanner.weeklyTitle),
      isEmpty,
    );
  });
}
