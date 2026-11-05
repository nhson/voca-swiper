import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/quiz/quiz_builder.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/data/repositories/word_repository.dart';
import 'package:voca_swiper/features/session/session_controller.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  late int kid;
  var now = testNow;

  SessionController controller() => SessionController(
    profileId: kid,
    words: WordRepository(db),
    progress: ProgressRepository(db),
    profiles: ProfileRepository(db),
    clock: () => now,
  );

  setUp(() async {
    now = testNow;
    db = await seededDb([
      w('cat', rank: 1, vi: 'con mèo'),
      w('dog', rank: 2),
      w('sun', rank: 3),
    ]);
    kid = await createKid(db); // daily goal 5
  });
  tearDown(() => db.close());

  test('loads new words in teaching order with their cards', () async {
    final c = controller();
    await c.start();
    expect(c.session!.queue.map((x) => x.wordId), ['cat', 'dog', 'sun']);
    expect(c.currentCard!.word.word, 'cat');
    expect(c.currentCard!.translation, 'con mèo');
    expect(c.profile!.name, 'Bi');
  });

  test('a full session saves progress and a session log', () async {
    final c = controller();
    await c.start();
    await c.answer(AnswerQuality.knew); // cat
    await c.answer(AnswerQuality.didntKnow); // dog → retry
    await c.answer(AnswerQuality.almost); // sun
    expect(c.isFinished, isFalse);
    await c.answer(AnswerQuality.knew); // dog retry: practice only
    expect(c.isFinished, isTrue);

    final p = await ProgressRepository(db).schedules(kid);
    expect(p['cat']!.state, WordState.learning);
    expect(p['cat']!.correctCount, 1);
    expect(p['dog']!.wrongCount, 1);
    expect(p['dog']!.correctCount, 0, reason: 'retry is not scheduled');
    expect(p['dog']!.easeFactor, closeTo(2.3, 1e-9));
    expect(p['sun']!.easeFactor, closeTo(2.35, 1e-9));

    final log = await db.select(db.sessionLogs).getSingle();
    expect(log.profileId, kid);
    expect(log.newLearned, 3);
    expect(log.reviewed, 0);
    expect(log.accuracy, closeTo(2 / 3, 1e-9));
    expect(c.summary!.stars, 2);
  });

  test(
    'progress is saved after each answer, even if the child quits',
    () async {
      final c = controller();
      await c.start();
      await c.answer(AnswerQuality.knew);
      await c.quit();
      expect((await ProgressRepository(db).schedules(kid)).keys, ['cat']);
      final log = await db.select(db.sessionLogs).getSingle();
      expect(log.newLearned, 1);
    },
  );

  test('quitting before any answer writes no log', () async {
    final c = controller();
    await c.start();
    await c.quit();
    expect(await db.select(db.sessionLogs).get(), isEmpty);
  });

  test('next day: due reviews come first, daily goal resets', () async {
    var c = controller();
    await c.start();
    for (var i = 0; i < 3; i++) {
      await c.answer(AnswerQuality.knew);
    }

    now = testNow.add(const Duration(days: 1));
    c = controller();
    await c.start();
    expect(c.session!.queue.map((x) => (x.wordId, x.isNew)), [
      ('cat', false),
      ('dog', false),
      ('sun', false),
    ]);
  });

  test('same day: a second session gets no extra new words', () async {
    final seeded = await seededDb([
      for (var i = 0; i < 8; i++) w('w$i', rank: i + 1),
    ]);
    await db.close();
    db = seeded;
    kid = await createKid(db); // daily goal 5

    var c = controller();
    await c.start();
    expect(c.session!.queue, hasLength(5));
    for (var i = 0; i < 5; i++) {
      await c.answer(AnswerQuality.knew);
    }

    now = testNow.add(const Duration(hours: 2));
    c = controller();
    await c.start();
    expect(c.session!.queue, isEmpty);
    expect(c.isFinished, isTrue);
  });

  test('a review answer reschedules from its stored state', () async {
    final s = const WordSchedule(
      state: WordState.review,
      easeFactor: 2.5,
      intervalDays: 3,
      repetitions: 2,
      nextReviewAt: null,
      lastAnsweredAt: null,
      correctCount: 2,
      wrongCount: 0,
    ).copyWith(nextReviewAt: testNow.subtract(const Duration(hours: 1)));
    await ProgressRepository(db).save(kid, 'cat', s, now: testNow);

    final c = controller();
    await c.start();
    expect(c.session!.current!.wordId, 'cat');
    expect(c.session!.current!.isNew, isFalse);
    await c.answer(AnswerQuality.knew);
    final p = await ProgressRepository(db).schedules(kid);
    expect(p['cat']!.intervalDays, 8); // 3 × 2.5
  });

  test('a review pile is capped by the minutes per day (feat-011)', () async {
    final seeded = await seededDb([
      for (var i = 0; i < 40; i++)
        w('w${i.toString().padLeft(2, '0')}', rank: i + 1),
    ]);
    await db.close();
    db = seeded;
    kid = await createKid(db, dailyMinutes: 5); // 12 cards
    final progress = ProgressRepository(db);
    for (var i = 0; i < 30; i++) {
      await progress.save(
        kid,
        'w${i.toString().padLeft(2, '0')}',
        WordSchedule.initial().copyWith(
          state: WordState.review,
          intervalDays: 3,
          repetitions: 2,
          nextReviewAt: testNow.subtract(Duration(days: i + 1)),
          lastAnsweredAt: testNow.subtract(Duration(days: i + 4)),
        ),
        now: testNow,
      );
    }

    final c = controller();
    await c.start();
    final q = c.session!.queue;
    expect(q, hasLength(12));
    expect(q.where((x) => x.isNew), isEmpty, reason: 'catch-up day');
    expect(q.first.wordId, 'w29', reason: 'most overdue first');

    final preview = await SessionLoader(
      words: WordRepository(db),
      progress: progress,
      profiles: ProfileRepository(db),
      clock: () => now,
    ).preview(kid);
    expect((preview.reviews, preview.newWords), (12, 0));
  });

  group('quiz round (feat-012)', () {
    const animals = [
      ('cat', '🐱'),
      ('dog', '🐶'),
      ('fish', '🐟'),
      ('bird', '🐦'),
      ('frog', '🐸'),
      ('duck', '🦆'),
    ];

    Future<void> seedAnimals({int age = 6}) async {
      await db.close();
      db = await seededDb([
        for (final (i, (id, e)) in animals.indexed)
          w(id, rank: i + 1, emoji: e, vi: 'vi-$id'),
      ]);
      kid = await createKid(db, age: age); // 5 new words a day
    }

    Future<SessionController> swipeAll(AnswerQuality q) async {
      final c = controller();
      await c.start();
      while (!c.session!.isFinished) {
        await c.answer(q);
      }
      return c;
    }

    String wrongOption(QuizItem item) =>
        item.options.firstWhere((o) => o != item.wordId);

    test(
      'follows the swipe cards for words the child said they knew',
      () async {
        await seedAnimals();
        final c = await swipeAll(AnswerQuality.knew);
        expect(c.inQuiz, isTrue);
        expect(c.isFinished, isFalse);
        expect(c.quiz.map((i) => i.wordId), [
          'cat',
          'dog',
          'fish',
          'bird',
          'frog',
        ]);
        expect(c.quiz.map((i) => i.kind).toSet(), {QuizKind.pickPicture});
        for (final id in c.currentQuiz!.options) {
          expect(c.cardFor(id), isNotNull, reason: 'option $id has a card');
        }
      },
    );

    test('a wrong quiz answer reschedules the word as a miss', () async {
      await seedAnimals();
      final c = await swipeAll(AnswerQuality.knew);
      final before = (await ProgressRepository(db).schedules(kid))['cat']!;
      expect(before.wrongCount, 0);

      expect(await c.answerQuiz(wrongOption(c.currentQuiz!)), isFalse); // cat
      expect(await c.answerQuiz('dog'), isTrue);

      final after = await ProgressRepository(db).schedules(kid);
      expect(after['cat']!.wrongCount, 1);
      expect(after['cat']!.correctCount, 0, reason: 'swipe overridden');
      expect(after['cat']!.state, WordState.learning);
      expect(after['dog']!.correctCount, 1, reason: 'right answer keeps it');
    });

    test('summary and session log count the quiz', () async {
      await seedAnimals();
      final c = await swipeAll(AnswerQuality.knew);
      await c.answerQuiz(wrongOption(c.currentQuiz!)); // cat ✗
      while (c.inQuiz) {
        await c.answerQuiz(c.currentQuiz!.wordId);
      }
      expect(c.isFinished, isTrue);
      expect(c.summary!.quizAsked, 5);
      expect(c.summary!.quizCorrect, 4);
      expect(c.summary!.correct, 4);
      final log = await db.select(db.sessionLogs).getSingle();
      expect(log.accuracy, closeTo(4 / 5, 1e-9));
    });

    test('words the child missed are not quizzed', () async {
      await seedAnimals();
      final c = await swipeAll(AnswerQuality.didntKnow);
      expect(c.inQuiz, isFalse);
      expect(c.isFinished, isTrue);
      expect(c.summary!.quizAsked, 0);
    });

    test('quitting during the quiz keeps the answers so far', () async {
      await seedAnimals();
      final c = await swipeAll(AnswerQuality.knew);
      await c.answerQuiz(wrongOption(c.currentQuiz!));
      await c.quit();
      expect(c.summary!.quizAsked, 1);
      final log = await db.select(db.sessionLogs).getSingle();
      expect(log.newLearned, 5);
      expect(log.accuracy, closeTo(4 / 5, 1e-9));
    });

    test('ages 7+ get meaning and spelling questions too', () async {
      await seedAnimals(age: 8);
      final c = await swipeAll(AnswerQuality.knew);
      expect(c.quiz.map((i) => i.kind).toSet(), {
        QuizKind.pickPicture,
        QuizKind.chooseMeaning,
        QuizKind.spell,
      });
    });
  });
}
