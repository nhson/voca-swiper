import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/data/repositories/word_repository.dart';
import 'package:voca_swiper/features/session/session_controller.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

/// feat-016: level-up, next-level preview words, and the step-back
/// suggestion for the parent.
void main() {
  late AppDatabase db;
  setUp(() async {
    db = await seededDb([
      for (var i = 1; i <= 5; i++) w('p$i', rank: i),
      for (var i = 1; i <= 8; i++) w('a$i', cefr: 'A1', rank: i),
    ]);
    await createParent(db);
  });
  tearDown(() => db.close());

  WordSchedule sched(WordState state, int interval, {DateTime? due}) =>
      WordSchedule(
        state: state,
        easeFactor: 2.5,
        intervalDays: interval,
        repetitions: 4,
        nextReviewAt: due ?? testNow.add(Duration(days: interval)),
        lastAnsweredAt: testNow.subtract(Duration(days: interval)),
        correctCount: 4,
        wrongCount: 0,
      );

  /// 3 of 5 Pre-A1 words mastered; p4 is due and becomes mastered with a
  /// "knew it" today (10 days × 2.5 = 25 ≥ 21), making 4 of 5 = 80%.
  Future<void> nearlyThere(int kid) async {
    final progress = ProgressRepository(db);
    for (final id in ['p1', 'p2', 'p3']) {
      await progress.save(kid, id, sched(WordState.mastered, 30), now: testNow);
    }
    await progress.save(
      kid,
      'p4',
      sched(WordState.review, 10, due: testNow),
      now: testNow,
    );
  }

  Future<ProfileRow> profile(int id) =>
      ProfileRepository(db).get(id).then((p) => p!);

  Future<void> playSession(WidgetTester t, int kid) async {
    await t.tap(find.byKey(Key('profile-$kid')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    while (find.byKey(const Key('answer-knew')).evaluate().isNotEmpty) {
      await t.tap(find.byKey(const Key('answer-knew')));
      await t.pumpAndSettle();
    }
  }

  testWidgets('80% of the level mastered → level-up celebration', (t) async {
    final kid = await createKid(db);
    await nearlyThere(kid);
    await pumpApp(t, db);
    await playSession(t, kid);

    expect(find.byKey(const Key('level-up')), findsOneWidget);
    expect(find.text('🏆 Level up!'), findsOneWidget);
    expect(find.textContaining('A1 words'), findsOneWidget);
    expect(find.byKey(const Key('level-up-confetti')), findsOneWidget);
    final p = await profile(kid);
    expect(p.currentLevel, 'A1');
    expect(p.levelChangedAt?.toUtc(), testNow);
  });

  testWidgets('a locked level stays put, no celebration', (t) async {
    final kid = await createKid(db);
    final repo = ProfileRepository(db);
    await repo.update(
      kid,
      ProfileDraft.fromRow(await profile(kid)).copyWith(levelLocked: true),
    );
    await nearlyThere(kid);
    await pumpApp(t, db);
    await playSession(t, kid);

    expect(find.byKey(const Key('stars')), findsOneWidget);
    expect(find.byKey(const Key('level-up')), findsNothing);
    expect((await profile(kid)).currentLevel, 'preA1');
  });

  test('every 5th new word is a next-level preview, unless locked', () async {
    final kid = await createKid(db, age: 8);
    // 10 new words a day: slots 5 and 10 come from A1.
    final repo = ProfileRepository(db);
    final draft = ProfileDraft.fromRow(await profile(kid));
    await repo.update(
      kid,
      ProfileDraft(
        name: draft.name,
        avatar: draft.avatar,
        age: draft.age,
        level: draft.level,
        dailyNewWords: 10,
      ),
    );
    final loader = SessionLoader(
      words: WordRepository(db),
      progress: ProgressRepository(db),
      profiles: repo,
      clock: () => testNow,
    );
    final ids = [
      for (final c in (await loader.load(kid)).session.queue) c.wordId,
    ];
    expect(ids, ['p1', 'p2', 'p3', 'p4', 'a1', 'p5', 'a2', 'a3', 'a4', 'a5']);

    await repo.update(
      kid,
      ProfileDraft.fromRow(await profile(kid)).copyWith(levelLocked: true),
    );
    final locked = [
      for (final c in (await loader.load(kid)).session.queue) c.wordId,
    ];
    expect(locked, ['p1', 'p2', 'p3', 'p4', 'p5']);
  });

  group('step-back suggestion', () {
    final later = testNow.add(const Duration(days: 10));

    /// An A1 child placed 10 days ago who got 30% right on 4 days this
    /// week.
    Future<int> strugglingKid() async {
      final kid = await createKid(db, level: CefrLevel.a1);
      final progress = ProgressRepository(db);
      for (final daysAgo in [6, 4, 2, 1]) {
        await progress.logSession(
          profileId: kid,
          startedAt: later.subtract(Duration(days: daysAgo)),
          durationSec: 300,
          reviewed: 8,
          newLearned: 2,
          accuracy: 0.3,
        );
      }
      return kid;
    }

    testWidgets('the parent sees it and can step back', (t) async {
      final kid = await strugglingKid();
      await pumpApp(t, db, now: later);
      await unlockParent(t);

      expect(find.byKey(Key('step-back-$kid')), findsOneWidget);
      expect(
        find.text(
          'Bi got 30% right this week at A1. Step back to Pre-A1 for a '
          'while?',
        ),
        findsOneWidget,
      );
      await t.tap(find.byKey(Key('step-back-accept-$kid')));
      await t.pumpAndSettle();

      expect(find.byKey(Key('step-back-$kid')), findsNothing);
      final p = await profile(kid);
      expect(p.currentLevel, 'preA1');
      expect(p.levelChangedAt?.toUtc(), later);
    });

    testWidgets('"not now" hides it and keeps the level', (t) async {
      final kid = await strugglingKid();
      await pumpApp(t, db, now: later);
      await unlockParent(t);
      await t.tap(find.byKey(Key('step-back-dismiss-$kid')));
      await t.pumpAndSettle();

      expect(find.byKey(Key('step-back-$kid')), findsNothing);
      final p = await profile(kid);
      expect(p.currentLevel, 'A1');
      expect(p.stepBackDismissedAt?.toUtc(), later);
    });

    testWidgets('no suggestion while the child is doing fine', (t) async {
      final kid = await createKid(db, level: CefrLevel.a1);
      for (final daysAgo in [6, 4, 2]) {
        await ProgressRepository(db).logSession(
          profileId: kid,
          startedAt: later.subtract(Duration(days: daysAgo)),
          durationSec: 300,
          reviewed: 8,
          newLearned: 2,
          accuracy: 0.8,
        );
      }
      await pumpApp(t, db, now: later);
      await unlockParent(t);
      expect(find.byKey(Key('step-back-$kid')), findsNothing);
    });
  });

  testWidgets('parent locks the level in the form', (t) async {
    final kid = await createKid(db);
    await pumpApp(t, db);
    await unlockParent(t);
    await t.tap(find.text('Bi'));
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('level-lock')));
    await t.tap(find.byKey(const Key('level-lock')));
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('save-profile')));
    await t.tap(find.byKey(const Key('save-profile')));
    await t.pumpAndSettle();
    expect((await profile(kid)).levelLocked, isTrue);
  });
}
