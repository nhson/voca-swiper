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
