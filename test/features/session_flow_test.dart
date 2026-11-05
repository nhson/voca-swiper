import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  setUp(() async {
    db = await seededDb([
      w('cat', rank: 1, vi: 'con mèo'),
      w('dog', rank: 2, vi: 'con chó'),
      w('sun', rank: 3, vi: 'mặt trời'),
    ]);
    await createParent(db);
  });
  tearDown(() => db.close());

  Future<void> openSession(WidgetTester t, int kid) async {
    await t.tap(find.byKey(Key('profile-$kid')));
    await t.pumpAndSettle();
    expect(find.text('3 words are waiting to say hi!'), findsOneWidget);
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
  }

  Future<void> swipe(WidgetTester t, Offset by) async {
    await t.drag(find.byKey(const Key('flash-card')), by);
    await t.pumpAndSettle();
  }

  testWidgets('full session with buttons updates progress and shows stars', (
    t,
  ) async {
    final kid = await createKid(db);
    final speaker = FakeSpeaker();
    await pumpApp(t, db, speaker: speaker);
    await openSession(t, kid);

    expect(find.text('cat'), findsOneWidget);
    expect(speaker.said, ['cat'], reason: 'word is spoken when shown');
    expect(find.text('1/3'), findsOneWidget);

    await t.tap(find.byKey(const Key('answer-knew'))); // cat
    await t.pumpAndSettle();
    expect(
      t.getCenter(find.byKey(const Key('flash-card'))).dx,
      closeTo(200, 1),
      reason: 'next card is centred, not left off-screen',
    );
    await t.tap(find.byKey(const Key('answer-not-yet'))); // dog → retry
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('answer-almost'))); // sun
    await t.pumpAndSettle();
    expect(find.text('One more try! 💪'), findsOneWidget);
    expect(find.text('dog'), findsOneWidget);
    await t.tap(find.byKey(const Key('answer-knew'))); // dog retry
    await t.pumpAndSettle();

    expect(find.byKey(const Key('stars')), findsOneWidget);
    expect(find.text('Great job!'), findsOneWidget); // 2/3 → 2 stars
    expect(find.text('3 new words'), findsOneWidget);
    expect(speaker.said, ['cat', 'dog', 'sun', 'dog']);

    final p = await ProgressRepository(db).schedules(kid);
    expect(p['cat']!.state, WordState.learning);
    expect(p['cat']!.correctCount, 1);
    expect(p['dog']!.wrongCount, 1);
    expect(p['dog']!.correctCount, 0);
    expect(p['sun']!.correctCount, 1);
    final log = await db.select(db.sessionLogs).getSingle();
    expect([log.newLearned, log.reviewed], [3, 0]);

    await t.tap(find.byKey(const Key('session-done')));
    await t.pumpAndSettle();
    expect(find.text('All done for today! 🎉'), findsOneWidget);
    expect(find.byKey(const Key('start-session')), findsOneWidget);
  });

  testWidgets('swipe right = knew, left = didn\'t know, up = almost', (
    t,
  ) async {
    final kid = await createKid(db);
    await pumpApp(t, db);
    await openSession(t, kid);

    await swipe(t, const Offset(300, 0)); // cat: knew
    await swipe(t, const Offset(-300, 0)); // dog: didn't know
    await swipe(t, const Offset(0, -400)); // sun: almost
    final p = await ProgressRepository(db).schedules(kid);
    expect(p['cat']!.correctCount, 1);
    expect(p['dog']!.wrongCount, 1);
    expect(p['sun']!.easeFactor, closeTo(2.35, 1e-9));
  });

  testWidgets('a short drag springs back and does not answer', (t) async {
    final kid = await createKid(db);
    await pumpApp(t, db);
    await openSession(t, kid);
    await t.timedDrag(
      find.byKey(const Key('flash-card')),
      const Offset(40, 0),
      const Duration(milliseconds: 600),
    );
    await t.pumpAndSettle();
    expect(find.text('cat'), findsOneWidget);
    expect(await ProgressRepository(db).schedules(kid), isEmpty);
  });

  testWidgets('flipped swipe direction: right means didn\'t know', (t) async {
    final kid = await createKid(db, swipeKnownRight: false);
    await pumpApp(t, db);
    await openSession(t, kid);
    await swipe(t, const Offset(300, 0)); // cat
    final p = await ProgressRepository(db).schedules(kid);
    expect(p['cat']!.wrongCount, 1);
    expect(p['cat']!.correctCount, 0);
  });

  testWidgets('tap flips the card to meaning and translation', (t) async {
    final kid = await createKid(db);
    await pumpApp(t, db);
    await openSession(t, kid);
    expect(find.text('def cat'), findsNothing);
    await t.tap(find.byKey(const Key('flash-card')));
    await t.pumpAndSettle();
    expect(find.text('def cat'), findsOneWidget);
    expect(find.text('“ex cat”'), findsOneWidget);
    expect(find.text('con mèo'), findsOneWidget);
  });

  testWidgets('"tap" translation mode hides Vietnamese until asked', (t) async {
    final kid = await createKid(db, translationMode: TranslationMode.tap);
    await pumpApp(t, db);
    await openSession(t, kid);
    await t.tap(find.byKey(const Key('flash-card')));
    await t.pumpAndSettle();
    expect(find.text('con mèo'), findsNothing);
    await t.tap(find.byKey(const Key('show-translation')));
    await t.pumpAndSettle();
    expect(find.text('con mèo'), findsOneWidget);
  });

  testWidgets('quitting keeps answered words', (t) async {
    final kid = await createKid(db);
    await pumpApp(t, db);
    await openSession(t, kid);
    await t.tap(find.byKey(const Key('answer-knew')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('quit-session')));
    await t.pumpAndSettle();
    expect((await ProgressRepository(db).schedules(kid)).keys, ['cat']);
    expect(find.text('2 words are waiting to say hi!'), findsOneWidget);
  });

  testWidgets('tablet layout fits the card and buttons', (t) async {
    final kid = await createKid(db);
    await pumpApp(t, db, size: const Size(1024, 1366));
    await openSession(t, kid);
    expect(find.byKey(const Key('answer-knew')), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
