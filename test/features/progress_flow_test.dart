import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  late int bi;
  late int an;

  Future<void> word(int kid, String id, WordState state) =>
      ProgressRepository(db).save(
        kid,
        id,
        WordSchedule.initial().copyWith(
          state: state,
          nextReviewAt: testNow.add(const Duration(days: 30)),
        ),
        now: testNow,
      );

  Future<void> log(
    int kid,
    Duration ago,
    int sec,
    int rev,
    int fresh,
    double acc,
  ) => ProgressRepository(db).logSession(
    profileId: kid,
    startedAt: testNow.subtract(ago),
    durationSec: sec,
    reviewed: rev,
    newLearned: fresh,
    accuracy: acc,
  );

  String textOf(WidgetTester t, String key) =>
      (t.widget<Text>(find.byKey(Key(key)))).data!;

  setUp(() async {
    db = await seededDb([for (var i = 0; i < 8; i++) w('w$i', rank: i + 1)]);
    await createParent(db);
    bi = await createKid(db, name: 'Bi');
    an = await createKid(db, name: 'An', age: 9);

    // Bi: 2 mastered, 1 review, 3 learning.
    await word(bi, 'w0', WordState.mastered);
    await word(bi, 'w1', WordState.mastered);
    await word(bi, 'w2', WordState.review);
    for (final id in ['w3', 'w4', 'w5']) {
      await word(bi, id, WordState.learning);
    }
    // Bi's sessions: today 5 min (8 of 10 right), 2 days ago 3 min (1 of 2).
    await log(bi, const Duration(hours: 1), 300, 4, 6, 0.8);
    await log(bi, const Duration(days: 2), 180, 2, 0, 0.5);
    // An has other data that must not leak into Bi's screen.
    await word(an, 'w6', WordState.mastered);
    await log(an, const Duration(hours: 2), 900, 5, 5, 0.1);
  });
  tearDown(() => db.close());

  Future<void> expectBiNumbers(WidgetTester t) async {
    expect(find.text("Bi's words"), findsOneWidget);
    expect(textOf(t, 'stat-mastered'), '2');
    expect(textOf(t, 'stat-review'), '1');
    expect(textOf(t, 'stat-learning'), '3');
    // (8 + 1) right out of 12 answers.
    expect(textOf(t, 'stat-accuracy'), '${(9 / 12 * 100).round()}%');
    expect(find.text('out of 12 answers'), findsOneWidget);
    expect(textOf(t, 'minutes-week'), '8');
    expect(textOf(t, 'minutes-day-6'), '5', reason: 'today');
    expect(textOf(t, 'minutes-day-4'), '3', reason: '2 days ago');
    expect(textOf(t, 'minutes-day-5'), '', reason: 'no practice');
  }

  testWidgets('child home "My words" shows numbers from the database', (
    t,
  ) async {
    await pumpApp(t, db);
    await t.tap(find.byKey(Key('profile-$bi')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('open-progress')));
    await t.pumpAndSettle();
    await expectBiNumbers(t);
  });

  testWidgets('parents open the same screen per profile', (t) async {
    await pumpApp(t, db);
    await unlockParent(t);
    await t.tap(find.byKey(Key('parent-progress-$bi')));
    await t.pumpAndSettle();
    await expectBiNumbers(t);
  });

  testWidgets('a new child sees zeros, not errors', (t) async {
    final mi = await createKid(db, name: 'Mi');
    await pumpApp(t, db);
    await t.tap(find.byKey(Key('profile-$mi')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('open-progress')));
    await t.pumpAndSettle();
    expect(textOf(t, 'stat-mastered'), '0');
    expect(textOf(t, 'stat-accuracy'), '–');
    expect(textOf(t, 'minutes-week'), '0');
  });

  testWidgets('numbers update after a session', (t) async {
    final mi = await createKid(db, name: 'Mi');
    await pumpApp(t, db);
    await t.tap(find.byKey(Key('profile-$mi')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await t.tap(find.byKey(const Key('answer-knew')));
      await t.pumpAndSettle();
    }
    await t.tap(find.byKey(const Key('session-done')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('open-progress')));
    await t.pumpAndSettle();
    expect(textOf(t, 'stat-learning'), '5');
    expect(textOf(t, 'stat-accuracy'), '100%');
  });

  testWidgets('tablet layout fits', (t) async {
    await pumpApp(t, db, size: const Size(1024, 1366));
    await t.tap(find.byKey(Key('profile-$bi')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('open-progress')));
    await t.pumpAndSettle();
    await expectBiNumbers(t);
    expect(t.takeException(), isNull);
  });
}
