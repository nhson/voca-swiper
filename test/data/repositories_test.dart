import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/core/quiz/quiz_builder.dart';
import 'package:voca_swiper/core/security/pin_hasher.dart';
import 'package:voca_swiper/core/srs/sm2_scheduler.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/data/repositories/word_repository.dart';

import '../support/test_db.dart';

void main() {
  final now = DateTime.utc(2026, 11, 4, 9);
  const kid = ProfileDraft(
    name: 'Bi',
    avatar: '🐯',
    age: 6,
    level: CefrLevel.preA1,
  );

  group('WordRepository.newWordCandidates', () {
    late AppDatabase db;
    late int profile;
    setUp(() async {
      db = await seededDb([
        w('p1', rank: 1),
        w('p2', rank: 2),
        w('p3', rank: 3, minAge: 10),
        w('a1', cefr: 'A1', rank: 1),
        w('a2', cefr: 'A1', rank: 2),
      ]);
      profile = await ProfileRepository(db).create(kid, now: now);
    });
    tearDown(() => db.close());

    test('current level first, then lower levels, in teaching order', () async {
      final ids = await WordRepository(db).newWordCandidates(
        profileId: profile,
        levelIndex: CefrLevel.a1.index,
        age: 12,
        limit: 10,
      );
      expect(ids, ['a1', 'a2', 'p1', 'p2', 'p3']);
    });

    test(
      'excludes higher levels, words above the age, and seen words',
      () async {
        await ProgressRepository(db).save(
          profile,
          'p1',
          const Sm2Scheduler().schedule(
            WordSchedule.initial(),
            AnswerQuality.knew,
            now: now,
          ),
          now: now,
        );
        final ids = await WordRepository(db).newWordCandidates(
          profileId: profile,
          levelIndex: CefrLevel.preA1.index,
          age: 6,
          limit: 10,
        );
        expect(ids, ['p2']);
      },
    );

    test('respects the limit', () async {
      final ids = await WordRepository(db).newWordCandidates(
        profileId: profile,
        levelIndex: CefrLevel.a1.index,
        age: 12,
        limit: 2,
      );
      expect(ids, ['a1', 'a2']);
    });
  });

  group('favourite themes and placement (feat-015)', () {
    late AppDatabase db;
    setUp(() async {
      db = await seededDb([
        w('p1', rank: 1, themes: ['food']),
        w('p2', rank: 2, themes: ['animals'], emoji: '🐶'),
        w('p3', rank: 3, themes: ['toys', 'animals']),
        w('p4', rank: 4, minAge: 10, themes: ['animals']),
        w('a1', cefr: 'A1', rank: 1, themes: ['food']),
        w('a2', cefr: 'A1', rank: 2, themes: ['sports']),
        w('b1', cefr: 'B1', rank: 1, minAge: 7, themes: ['animals']),
      ]);
    });
    tearDown(() => db.close());

    test('favourite-theme words come first within each level', () async {
      final repo = ProfileRepository(db);
      final id = await repo.create(
        const ProfileDraft(
          name: 'Bi',
          avatar: '🐯',
          age: 12,
          level: CefrLevel.a1,
          interests: ['animals', 'sports'],
        ),
        now: now,
      );
      final ids = await WordRepository(db).newWordCandidates(
        profileId: id,
        levelIndex: CefrLevel.a1.index,
        age: 12,
        limit: 10,
        interests: const ['animals', 'sports'],
      );
      expect(ids, ['a2', 'a1', 'p2', 'p3', 'p4', 'p1']);
    });

    test('a theme name inside another is not a match', () async {
      final ids = await WordRepository(db).newWordCandidates(
        profileId: await ProfileRepository(db).create(kid, now: now),
        levelIndex: CefrLevel.preA1.index,
        age: 6,
        limit: 10,
        interests: const ['toy', 'anim'],
      );
      expect(ids, ['p1', 'p2', 'p3']);
    });

    test('placement words: allowed for the age, by level then rank', () async {
      final repo = WordRepository(db);
      final young = await repo.placementWords(age: 6, language: 'vi');
      expect(young.map((c) => c.word.id), ['p1', 'p2', 'p3', 'a1', 'a2']);
      expect(young[1].word.emoji, '🐶');
      expect(young[1].translation, 'vi');
      final older = await repo.placementWords(age: 10, language: 'vi');
      expect(older.map((c) => c.word.id), contains('b1'));
    });

    test('theme counts up to a level, for the age', () async {
      final counts = await WordRepository(
        db,
      ).themeCounts(levelIndex: CefrLevel.a1.index, age: 6);
      expect(counts, {'food': 2, 'animals': 2, 'toys': 1, 'sports': 1});
    });

    test('a new profile has no placement yet; finish, skip and redo', () async {
      final repo = ProfileRepository(db);
      final id = await repo.create(kid, now: now);
      var p = (await repo.get(id))!;
      expect(p.onboardedAt, isNull);
      expect(p.interests, isEmpty);

      final later = now.add(const Duration(minutes: 3));
      await repo.finishPlacement(
        id,
        level: CefrLevel.a1,
        interests: const ['animals'],
        now: later,
      );
      p = (await repo.get(id))!;
      expect(p.currentLevel, 'A1');
      expect(p.interests, ['animals']);
      expect(p.onboardedAt?.toUtc(), later);
      expect(p.translationMode, TranslationMode.always);

      await repo.redoPlacement(id);
      expect((await repo.get(id))!.onboardedAt, isNull);
      await repo.skipPlacement(id, now: later);
      p = (await repo.get(id))!;
      expect(p.onboardedAt?.toUtc(), later);
      expect(p.currentLevel, 'A1');
    });

    test('placing at A2 moves a default translation to "tap"', () async {
      final repo = ProfileRepository(db);
      final id = await repo.create(kid, now: now);
      await repo.finishPlacement(
        id,
        level: CefrLevel.a2,
        interests: const [],
        now: now,
      );
      expect((await repo.get(id))!.translationMode, TranslationMode.tap);

      // A translation the parent chose is left alone.
      final hidden = await repo.create(
        const ProfileDraft(
          name: 'An',
          avatar: '🐼',
          age: 8,
          level: CefrLevel.a1,
          translationMode: TranslationMode.hidden,
        ),
        now: now,
      );
      await repo.finishPlacement(
        hidden,
        level: CefrLevel.a2,
        interests: const [],
        now: now,
      );
      expect((await repo.get(hidden))!.translationMode, TranslationMode.hidden);
    });

    test('editing a profile keeps its placement', () async {
      final repo = ProfileRepository(db);
      final id = await repo.create(kid, now: now);
      await repo.skipPlacement(id, now: now);
      final row = (await repo.get(id))!;
      await repo.update(
        id,
        ProfileDraft.fromRow(row).copyWith(interests: const ['food']),
      );
      final p = (await repo.get(id))!;
      expect(p.onboardedAt?.toUtc(), now);
      expect(p.interests, ['food']);
    });
  });

  group('level progression data (feat-016)', () {
    late AppDatabase db;
    late int kidId;
    setUp(() async {
      db = await seededDb([
        w('p1', rank: 1),
        w('p2', rank: 2),
        w('p3', rank: 3, minAge: 10),
        w('a1', cefr: 'A1', rank: 1),
        w('a2', cefr: 'A1', rank: 2),
        w('x1', cefr: 'A2', rank: 1, minAge: 7),
      ]);
      kidId = await ProfileRepository(db).create(kid, now: now);
    });
    tearDown(() => db.close());

    test('words per level for an age', () async {
      final repo = WordRepository(db);
      expect(await repo.levelCounts(age: 6), {
        CefrLevel.preA1: 2,
        CefrLevel.a1: 2,
      });
      expect(await repo.levelCounts(age: 12), {
        CefrLevel.preA1: 3,
        CefrLevel.a1: 2,
        CefrLevel.a2: 1,
      });
    });

    test('mastered words at one level, for the age', () async {
      final progress = ProgressRepository(db);
      Future<void> master(String id) => progress.save(
        kidId,
        id,
        WordSchedule(
          state: WordState.mastered,
          easeFactor: 2.5,
          intervalDays: 30,
          repetitions: 5,
          nextReviewAt: now.add(const Duration(days: 30)),
          lastAnsweredAt: now,
          correctCount: 5,
          wrongCount: 0,
        ),
        now: now,
      );
      await master('p1');
      await master('p3'); // above the age
      await master('a1');
      await progress.save(kidId, 'p2', WordSchedule.initial(), now: now);
      expect(
        await progress.masteredAt(kidId, level: CefrLevel.preA1, age: 6),
        1,
      );
      expect(
        await progress.masteredAt(kidId, level: CefrLevel.preA1, age: 12),
        2,
      );
      expect(await progress.masteredAt(kidId, level: CefrLevel.a1, age: 6), 1);
    });

    test('candidates from exactly one level (next-level preview)', () async {
      final ids = await WordRepository(db).newWordCandidates(
        profileId: kidId,
        levelIndex: CefrLevel.a1.index,
        age: 6,
        limit: 10,
        exactLevel: true,
      );
      expect(ids, ['a1', 'a2']);
    });

    test('changing level records when; lock and "not now" persist', () async {
      final repo = ProfileRepository(db);
      final later = now.add(const Duration(days: 9));
      await repo.changeLevel(kidId, CefrLevel.a1, now: later);
      var p = (await repo.get(kidId))!;
      expect(p.currentLevel, 'A1');
      expect(p.levelChangedAt?.toUtc(), later);
      expect(levelSince(p).toUtc(), later);

      await repo.dismissStepBack(kidId, now: later);
      p = (await repo.get(kidId))!;
      expect(p.stepBackDismissedAt?.toUtc(), later);

      await repo.update(
        kidId,
        ProfileDraft.fromRow(p).copyWith(levelLocked: true),
        now: later,
      );
      p = (await repo.get(kidId))!;
      expect(p.levelLocked, isTrue);
      // Same level in the form: not a level change.
      expect(p.levelChangedAt?.toUtc(), later);

      final again = later.add(const Duration(days: 1));
      await repo.update(
        kidId,
        ProfileDraft.fromRow(p).copyWithLevel(CefrLevel.preA1),
        now: again,
      );
      expect((await repo.get(kidId))!.levelChangedAt?.toUtc(), again);
    });

    test(
      'a level never changed counts from placement, else creation',
      () async {
        final repo = ProfileRepository(db);
        var p = (await repo.get(kidId))!;
        expect(levelSince(p).toUtc(), now);
        final placed = now.add(const Duration(hours: 1));
        await repo.skipPlacement(kidId, now: placed);
        p = (await repo.get(kidId))!;
        expect(levelSince(p).toUtc(), placed);
      },
    );
  });

  group('ProgressRepository', () {
    late AppDatabase db;
    late ProgressRepository repo;
    late int profile;
    setUp(() async {
      db = await seededDb([w('cat'), w('dog')]);
      repo = ProgressRepository(db);
      profile = await ProfileRepository(db).create(kid, now: now);
    });
    tearDown(() => db.close());

    test('save and read back a schedule', () async {
      final s = const Sm2Scheduler().schedule(
        WordSchedule.initial(),
        AnswerQuality.almost,
        now: now,
      );
      await repo.save(profile, 'cat', s, now: now);
      final back = (await repo.schedules(profile))['cat']!;
      expect(back.state, WordState.learning);
      expect(back.easeFactor, s.easeFactor);
      expect(back.intervalDays, 1);
      expect(back.nextReviewAt, s.nextReviewAt);
      expect(back.correctCount, 1);
    });

    test('firstSeenAt is kept on later saves', () async {
      const sch = Sm2Scheduler();
      var s = sch.schedule(
        WordSchedule.initial(),
        AnswerQuality.knew,
        now: now,
      );
      await repo.save(profile, 'cat', s, now: now);
      final later = now.add(const Duration(days: 1));
      s = sch.schedule(s, AnswerQuality.knew, now: later);
      await repo.save(profile, 'cat', s, now: later);

      expect(await repo.newIntroducedSince(profile, now), 1);
      expect(await repo.newIntroducedSince(profile, later), 0);
      expect((await repo.schedules(profile))['cat']!.repetitions, 2);
    });

    test('progress is per profile', () async {
      final other = await ProfileRepository(db).create(kid, now: now);
      await repo.save(
        profile,
        'cat',
        const Sm2Scheduler().schedule(
          WordSchedule.initial(),
          AnswerQuality.knew,
          now: now,
        ),
        now: now,
      );
      expect(await repo.schedules(other), isEmpty);
    });

    test('deleting a profile deletes its progress and logs', () async {
      await repo.save(profile, 'cat', WordSchedule.initial(), now: now);
      await repo.logSession(
        profileId: profile,
        startedAt: now,
        durationSec: 60,
        reviewed: 1,
        newLearned: 1,
        accuracy: 1,
      );
      await ProfileRepository(db).delete(profile);
      expect(await db.select(db.wordProgress).get(), isEmpty);
      expect(await db.select(db.sessionLogs).get(), isEmpty);
    });

    group('quiz log (feat-013)', () {
      Future<void> seedQuiz() async {
        await repo.save(profile, 'cat', WordSchedule.initial(), now: now);
        await repo.logQuiz(
          profileId: profile,
          wordId: 'cat',
          kind: QuizKind.pickPicture,
          correct: true,
          at: now.add(const Duration(days: 15)),
        );
        await repo.logQuiz(
          profileId: profile,
          wordId: 'cat',
          kind: QuizKind.spell,
          correct: false,
          at: now.add(const Duration(days: 20)),
        );
      }

      test('answers are stored per profile, oldest first', () async {
        await seedQuiz();
        final other = await ProfileRepository(db).create(kid, now: now);
        final back = await repo.quizAnswers(profile);
        expect(back.map((a) => (a.wordId, a.correct)), [
          ('cat', true),
          ('cat', false),
        ]);
        expect(back.first.answeredAt, now.add(const Duration(days: 15)));
        expect(await repo.quizAnswers(other), isEmpty);
        final rows = await db.select(db.quizLogs).get();
        expect(rows.map((r) => r.kind), ['pickPicture', 'spell']);
      });

      test('first-seen dates for the retention metric', () async {
        await seedQuiz();
        expect(await repo.firstSeen(profile), {'cat': now});
      });

      test('retention reads both together', () async {
        await seedQuiz();
        final r = await repo.retention(profile);
        expect((r.asked, r.correct), (2, 1));
      });

      test('deleting a profile deletes its quiz log', () async {
        await seedQuiz();
        await ProfileRepository(db).delete(profile);
        expect(await db.select(db.quizLogs).get(), isEmpty);
      });

      test('reset clears the quiz log too', () async {
        await seedQuiz();
        await ProfileRepository(db).resetProgress(profile);
        expect(await repo.quizAnswers(profile), isEmpty);
      });
    });

    test('reset keeps the profile but clears progress', () async {
      await repo.save(profile, 'cat', WordSchedule.initial(), now: now);
      await ProfileRepository(db).resetProgress(profile);
      expect(await repo.schedules(profile), isEmpty);
      expect(await ProfileRepository(db).get(profile), isNotNull);
    });
  });

  group('ProfileRepository + ParentRepository persistence', () {
    test(
      'two profiles keep independent settings across restarts; PIN is hashed',
      () async {
        final dir = await Directory.systemTemp.createTemp('voca');
        addTearDown(() => dir.delete(recursive: true));
        final file = File('${dir.path}/app.sqlite');

        var db = AppDatabase(NativeDatabase(file));
        final profiles = ProfileRepository(db);
        final a = await profiles.create(kid, now: now);
        final b = await profiles.create(
          const ProfileDraft(
            name: 'Na',
            avatar: '🦄',
            age: 9,
            level: CefrLevel.a1,
            dailyNewWords: 12,
            translationMode: TranslationMode.tap,
            swipeKnownRight: false,
          ),
          now: now,
        );
        await ParentRepository(
          db,
          hasher: const PinHasher(iterations: 10),
        ).create('2468', now: now);
        await db.close();

        db = AppDatabase(NativeDatabase(file)); // "restart"
        addTearDown(db.close);
        final ra = (await ProfileRepository(db).get(a))!;
        final rb = (await ProfileRepository(db).get(b))!;
        expect(
          [
            ra.name,
            ra.age,
            ra.currentLevel,
            ra.dailyNewWords,
            ra.swipeKnownRight,
          ],
          ['Bi', 6, 'preA1', 5, true],
        );
        expect(
          [
            rb.name,
            rb.age,
            rb.currentLevel,
            rb.dailyNewWords,
            rb.swipeKnownRight,
          ],
          ['Na', 9, 'A1', 12, false],
        );
        expect(rb.translationMode, TranslationMode.tap);

        final parent = ParentRepository(
          db,
          hasher: const PinHasher(iterations: 10),
        );
        final account = (await parent.account())!;
        expect(account.pinHash, isNot(contains('2468')));
        expect(await parent.verifyPin('2468'), isTrue);
        expect(await parent.verifyPin('0000'), isFalse);
      },
    );

    test('update changes only that profile', () async {
      final db = memoryDb();
      addTearDown(db.close);
      final repo = ProfileRepository(db);
      final a = await repo.create(kid, now: now);
      final b = await repo.create(kid, now: now);
      await repo.update(
        a,
        ProfileDraft.fromRow((await repo.get(a))!).copyWithName('Bo'),
      );
      expect((await repo.get(a))!.name, 'Bo');
      expect((await repo.get(b))!.name, 'Bi');
    });
  });

  group('ParentRepository', () {
    test('rejects bad PINs and a second account', () async {
      final db = memoryDb();
      addTearDown(db.close);
      final repo = ParentRepository(
        db,
        hasher: const PinHasher(iterations: 10),
      );
      expect(() => repo.create('12', now: now), throwsArgumentError);
      await repo.create('1234', now: now);
      expect(() => repo.create('5678', now: now), throwsStateError);
    });

    test('changePin replaces the PIN', () async {
      final db = memoryDb();
      addTearDown(db.close);
      final repo = ParentRepository(
        db,
        hasher: const PinHasher(iterations: 10),
      );
      await repo.create('1234', now: now);
      await repo.changePin('9999');
      expect(await repo.verifyPin('1234'), isFalse);
      expect(await repo.verifyPin('9999'), isTrue);
    });
  });
}

extension on ProfileDraft {
  ProfileDraft copyWithName(String name) => ProfileDraft(
    name: name,
    avatar: avatar,
    age: age,
    level: level,
    nativeLanguage: nativeLanguage,
    dailyNewWords: dailyNewWords,
    dailyMinutes: dailyMinutes,
    translationMode: translationMode,
    swipeKnownRight: swipeKnownRight,
  );
}
