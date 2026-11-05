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
    await _dropPlacementColumns(db);
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

  test('v2 → v3: existing children count as placed, no favourites', () async {
    final dir = await Directory.systemTemp.createTemp('voca-mig');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/app.sqlite');
    final created = DateTime.utc(2026, 11, 1, 9);

    var db = AppDatabase(NativeDatabase(file));
    final kid = await ProfileRepository(db).create(
      const ProfileDraft(
        name: 'Bi',
        avatar: '🐯',
        age: 6,
        level: CefrLevel.preA1,
      ),
      now: created,
    );
    await _dropPlacementColumns(db);
    await db.customStatement('PRAGMA user_version = 2');
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final p = (await ProfileRepository(db).get(kid))!;
    // The trial child is not sent through placement after the update.
    expect(p.onboardedAt?.toUtc(), created);
    expect(p.interests, isEmpty);
    expect(p.currentLevel, 'preA1');
  });

  test('v3 → v4: level unlocked, no level change or dismissal yet', () async {
    final dir = await Directory.systemTemp.createTemp('voca-mig');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/app.sqlite');
    final created = DateTime.utc(2026, 11, 1, 9);

    var db = AppDatabase(NativeDatabase(file));
    final repo = ProfileRepository(db);
    final kid = await repo.create(
      const ProfileDraft(name: 'Bi', avatar: '🐯', age: 6, level: CefrLevel.a1),
      now: created,
    );
    await repo.skipPlacement(kid, now: created);
    await _dropLevelColumns(db);
    await db.customStatement('PRAGMA user_version = 3');
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final p = (await ProfileRepository(db).get(kid))!;
    expect(p.levelLocked, isFalse);
    expect(p.levelChangedAt, isNull);
    expect(p.stepBackDismissedAt, isNull);
    expect(p.currentLevel, 'A1');
    expect(levelSince(p).toUtc(), created);
  });
}

/// Makes the profiles table look like schema 1–2 (before feat-015).
Future<void> _dropPlacementColumns(AppDatabase db) async {
  await _dropLevelColumns(db);
  await db.customStatement('ALTER TABLE profiles DROP COLUMN interests');
  await db.customStatement('ALTER TABLE profiles DROP COLUMN onboarded_at');
}

/// Makes the profiles table look like schema 3 (before feat-016).
Future<void> _dropLevelColumns(AppDatabase db) async {
  await db.customStatement('ALTER TABLE profiles DROP COLUMN level_locked');
  await db.customStatement('ALTER TABLE profiles DROP COLUMN level_changed_at');
  await db.customStatement(
    'ALTER TABLE profiles DROP COLUMN step_back_dismissed_at',
  );
}
