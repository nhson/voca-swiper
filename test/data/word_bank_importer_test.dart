import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/quiz/quiz_builder.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/data/repositories/word_repository.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

void main() {
  test('imports the bundled bank and records its version', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final importer = WordBankImporter(db);

    expect(await importer.importIfNewer(bundledBankJson()), isTrue);
    expect(await importer.importedVersion(), 2);
    expect(await WordRepository(db).count(), greaterThan(1400));

    final cards = await WordRepository(db).cards(['cat'], language: 'vi');
    expect(cards.single.word.word, 'cat');
    expect(cards.single.word.emoji, '🐱');
    expect(cards.single.translation, 'con mèo');
  });

  test('same or older version is skipped', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final importer = WordBankImporter(db);
    await importer.importIfNewer(bankJson([w('a')], version: 2));
    expect(
      await importer.importIfNewer(bankJson([w('b')], version: 2)),
      isFalse,
    );
    expect(
      await importer.importIfNewer(bankJson([w('b')], version: 1)),
      isFalse,
    );
    expect(await WordRepository(db).count(), 1);
  });

  test('newer version upserts and keeps words it no longer lists', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final importer = WordBankImporter(db);
    await importer.importIfNewer(bankJson([w('a', vi: 'old')], version: 1));
    expect(
      await importer.importIfNewer(
        bankJson([w('a', vi: 'new'), w('b')], version: 2),
      ),
      isTrue,
    );
    final cards = await WordRepository(db).cards(['a', 'b'], language: 'vi');
    expect(cards.map((c) => c.translation), ['new', 'vi']);
    expect(await importer.importedVersion(), 2);
  });

  test('feat-014: the v2 bank installs over v1 and keeps progress', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final importer = WordBankImporter(db);

    // v1 as shipped: the bundled words whose ids were in v1.
    final shipped = File('content_pipeline/source/shipped_ids.txt')
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toSet();
    final v2 = jsonDecode(bundledBankJson()) as Map<String, dynamic>;
    final v1Words = [
      for (final w in v2['words'] as List)
        if (shipped.contains((w as Map)['id'])) w,
    ];
    expect(v1Words, hasLength(shipped.length));
    await importer.importIfNewer(jsonEncode({'version': 1, 'words': v1Words}));

    final kid = await createKid(db, age: 6);
    final progress = ProgressRepository(db);
    final at = DateTime.utc(2026, 10, 1);
    final learned = WordSchedule.initial().copyWith(
      state: WordState.review,
      intervalDays: 6,
      repetitions: 2,
      correctCount: 3,
      nextReviewAt: at.add(const Duration(days: 6)),
      lastAnsweredAt: at,
    );
    await progress.save(kid, 'cat', learned, now: at);
    await progress.logQuiz(
      profileId: kid,
      wordId: 'cat',
      kind: QuizKind.pickPicture,
      correct: true,
      at: at,
    );

    expect(await importer.importIfNewer(bundledBankJson()), isTrue);
    expect(await importer.importedVersion(), 2);
    expect(await WordRepository(db).count(), (v2['words'] as List).length);

    final cat = (await progress.schedules(kid))['cat']!;
    expect(
      [cat.state, cat.intervalDays, cat.correctCount],
      [WordState.review, 6, 3],
    );
    expect((await progress.firstSeen(kid))['cat'], at);
    expect(await progress.quizAnswers(kid), hasLength(1));
  });
}
