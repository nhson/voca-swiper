import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/core/quiz/quiz_builder.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';

/// Phones already have a version-1 database (Phase 1). Upgrading must keep
/// every child's progress and add the new tables.
void main() {
  test('v1 → current: progress kept, quiz log added', () async {
    final dir = await Directory.systemTemp.createTemp('voca-mig');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/app.sqlite');
    final now = DateTime.utc(2026, 11, 1, 9);

    // A Phase 1 database: current schema minus quiz_logs, user_version 1.
    var db = AppDatabase(NativeDatabase(file));
    final kid = await ProfileRepository(db).create(
      const ProfileDraft(
        name: 'Bi',
        avatar: '🐯',
        age: 6,
        level: CefrLevel.preA1,
      ),
      now: now,
    );
    await ProgressRepository(
      db,
    ).save(kid, 'cat', WordSchedule.initial(), now: now);
    await db.customStatement('DROP TABLE quiz_logs');
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    expect(db.schemaVersion, greaterThanOrEqualTo(2));
    final repo = ProgressRepository(db);
    expect((await repo.schedules(kid)).keys, ['cat']);
    expect(await repo.quizAnswers(kid), isEmpty);
    await repo.logQuiz(
      profileId: kid,
      wordId: 'cat',
      kind: QuizKind.pickPicture,
      correct: true,
      at: now,
    );
    expect(await repo.quizAnswers(kid), hasLength(1));
  });
}
