import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  late int kid;

  /// A review word that came due an hour ago.
  Future<void> dueReview(String id) => ProgressRepository(db).save(
    kid,
    id,
    WordSchedule(
      state: WordState.review,
      easeFactor: 2.5,
      intervalDays: 3,
      repetitions: 2,
      nextReviewAt: testNow.subtract(const Duration(hours: 1)),
      lastAnsweredAt: null,
      correctCount: 2,
      wrongCount: 0,
    ),
    now: testNow,
  );

  setUp(() async {
    db = await seededDb([w('cat', rank: 1), w('dog', rank: 2)]);
    await createParent(db);
    kid = await createKid(db, name: 'Bi');
  });
  tearDown(() => db.close());

  Future<void> openReminders(WidgetTester t) async {
    await unlockParent(t);
    final tile = find.byKey(const Key('open-reminders'));
    await t.scrollUntilVisible(tile, 100);
    await t.tap(tile);
    await t.pumpAndSettle();
  }

  testWidgets('reminders are off until a parent turns them on', (t) async {
    final n = FakeReminderNotifier();
    await dueReview('cat');
    await pumpApp(t, db, notifier: n);
    expect(n.scheduled, isEmpty, reason: 'planned at start, but off');

    await openReminders(t);
    await t.tap(find.byKey(const Key('reminder-toggle')));
    await t.pumpAndSettle();

    expect(n.permissionAsks, 1);
    final a = await ParentRepository(db).account();
    expect(a!.reminderMinuteOfDay, 18 * 60, reason: 'default 18:00');
    expect(n.scheduled, isNotEmpty);
    expect(n.scheduled!.first.at.hour, 18);
    expect(n.scheduled!.first.body, 'Bi, 1 word is waiting to say hi!');
    expect(
      find.textContaining('Bi, 1 word is waiting to say hi!'),
      findsOneWidget,
    );
  });

  testWidgets('nothing due: no reminder is scheduled', (t) async {
    final n = FakeReminderNotifier();
    await pumpApp(t, db, notifier: n);
    await openReminders(t);
    await t.tap(find.byKey(const Key('reminder-toggle')));
    await t.pumpAndSettle();
    expect(n.scheduled, isEmpty);
    expect(find.textContaining('no reminder is planned'), findsOneWidget);
  });

  testWidgets('turning reminders off cancels them', (t) async {
    final n = FakeReminderNotifier();
    await dueReview('cat');
    await ParentRepository(db).updateReminders(
      reminderMinuteOfDay: 18 * 60,
      quietStartMinute: 21 * 60,
      quietEndMinute: 7 * 60,
      blockSchoolHours: true,
      schoolStartMinute: 7 * 60 + 30,
      schoolEndMinute: 16 * 60 + 30,
    );
    await pumpApp(t, db, notifier: n);
    expect(n.scheduled, isNotEmpty, reason: 'planned at app start');

    await openReminders(t);
    await t.tap(find.byKey(const Key('reminder-toggle')));
    await t.pumpAndSettle();
    expect(n.scheduled, isEmpty);
    expect((await ParentRepository(db).account())!.reminderMinuteOfDay, isNull);
  });

  testWidgets('permission denied: the parent is told how to fix it', (t) async {
    await pumpApp(t, db, notifier: FakeReminderNotifier(allow: false));
    await openReminders(t);
    await t.tap(find.byKey(const Key('reminder-toggle')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('permission-denied')), findsOneWidget);
  });

  testWidgets('finishing a session re-plans: reviewed words stop the nudge', (
    t,
  ) async {
    final n = FakeReminderNotifier();
    await dueReview('cat');
    await dueReview('dog');
    await ParentRepository(db).updateReminders(
      reminderMinuteOfDay: 18 * 60,
      quietStartMinute: 21 * 60,
      quietEndMinute: 7 * 60,
      blockSchoolHours: true,
      schoolStartMinute: 7 * 60 + 30,
      schoolEndMinute: 16 * 60 + 30,
    );
    await pumpApp(t, db, notifier: n);
    expect(n.scheduled!.first.dueCount, 2);

    await t.tap(find.byKey(Key('profile-$kid')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await t.tap(find.byKey(const Key('answer-knew')));
      await t.pumpAndSettle();
    }
    await t.tap(find.byKey(const Key('session-done')));
    await t.pumpAndSettle();

    // Both words moved 8 days out (3 × 2.5): nothing due this week.
    expect(n.scheduled, isEmpty);
  });
}
