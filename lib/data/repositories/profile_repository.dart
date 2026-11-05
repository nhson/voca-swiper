import 'package:drift/drift.dart';

import '../../core/levels.dart';
import '../db/app_database.dart';

/// Editable profile fields (create and update).
class ProfileDraft {
  const ProfileDraft({
    required this.name,
    required this.avatar,
    required this.age,
    required this.level,
    this.nativeLanguage = 'vi',
    this.dailyNewWords = 5,
    this.dailyMinutes = 10,
    TranslationMode? translationMode,
    this.swipeKnownRight = true,
    this.interests = const [],
    this.levelLocked = false,
  }) : translationMode = translationMode ?? TranslationMode.always;

  final String name;
  final String avatar;
  final int age;
  final CefrLevel level;
  final String nativeLanguage;
  final int dailyNewWords;
  final int dailyMinutes;
  final TranslationMode translationMode;
  final bool swipeKnownRight;

  /// Favourite themes (feat-015).
  final List<String> interests;

  /// No automatic level changes (feat-016).
  final bool levelLocked;

  ProfileDraft copyWithLevel(CefrLevel level) => ProfileDraft(
    name: name,
    avatar: avatar,
    age: age,
    level: level,
    nativeLanguage: nativeLanguage,
    dailyNewWords: dailyNewWords,
    dailyMinutes: dailyMinutes,
    translationMode: translationMode,
    swipeKnownRight: swipeKnownRight,
    interests: interests,
    levelLocked: levelLocked,
  );

  ProfileDraft copyWith({List<String>? interests, bool? levelLocked}) =>
      ProfileDraft(
        name: name,
        avatar: avatar,
        age: age,
        level: level,
        nativeLanguage: nativeLanguage,
        dailyNewWords: dailyNewWords,
        dailyMinutes: dailyMinutes,
        translationMode: translationMode,
        swipeKnownRight: swipeKnownRight,
        interests: interests ?? this.interests,
        levelLocked: levelLocked ?? this.levelLocked,
      );

  factory ProfileDraft.fromRow(ProfileRow r) => ProfileDraft(
    name: r.name,
    avatar: r.avatar,
    age: r.age,
    level: CefrLevel.fromCode(r.currentLevel),
    nativeLanguage: r.nativeLanguage,
    dailyNewWords: r.dailyNewWords,
    dailyMinutes: r.dailyMinutes,
    translationMode: r.translationMode,
    swipeKnownRight: r.swipeKnownRight,
    interests: r.interests,
    levelLocked: r.levelLocked,
  );

  /// Translation visibility default by level (docs/SPEC.md — Fading
  /// translation): shown at Pre-A1/A1, tap at A2/B1, hidden at B2.
  static TranslationMode defaultTranslationMode(CefrLevel level) =>
      switch (level) {
        CefrLevel.preA1 || CefrLevel.a1 => TranslationMode.always,
        CefrLevel.a2 || CefrLevel.b1 => TranslationMode.tap,
        CefrLevel.b2 => TranslationMode.hidden,
      };

  ProfilesCompanion _companion() => ProfilesCompanion(
    name: Value(name.trim()),
    avatar: Value(avatar),
    age: Value(age),
    currentLevel: Value(level.code),
    nativeLanguage: Value(nativeLanguage),
    dailyNewWords: Value(dailyNewWords),
    dailyMinutes: Value(dailyMinutes),
    translationMode: Value(translationMode),
    swipeKnownRight: Value(swipeKnownRight),
    interests: Value(interests),
    levelLocked: Value(levelLocked),
  );
}

/// Since when the profile has been at its current level.
DateTime levelSince(ProfileRow p) =>
    p.levelChangedAt ?? p.onboardedAt ?? p.createdAt;

class ProfileRepository {
  ProfileRepository(this.db);

  final AppDatabase db;

  Stream<List<ProfileRow>> watchAll() => (db.select(
    db.profiles,
  )..orderBy([(p) => OrderingTerm.asc(p.id)])).watch();

  Future<List<ProfileRow>> all() =>
      (db.select(db.profiles)..orderBy([(p) => OrderingTerm.asc(p.id)])).get();

  Future<ProfileRow?> get(int id) =>
      (db.select(db.profiles)..where((p) => p.id.equals(id))).getSingleOrNull();

  Stream<ProfileRow?> watch(int id) => (db.select(
    db.profiles,
  )..where((p) => p.id.equals(id))).watchSingleOrNull();

  Future<int> create(ProfileDraft d, {required DateTime now}) => db
      .into(db.profiles)
      .insert(d._companion().copyWith(createdAt: Value(now)));

  /// Saves the form. A different level than stored counts as a level change
  /// at [now] (defaults to the current time).
  Future<void> update(int id, ProfileDraft d, {DateTime? now}) async {
    final old = await get(id);
    var c = d._companion();
    if (old != null && old.currentLevel != d.level.code) {
      c = c.copyWith(levelChangedAt: Value(now ?? DateTime.now().toUtc()));
    }
    await (db.update(db.profiles)..where((p) => p.id.equals(id))).write(c);
  }

  /// Moves to [level] (level-up or step back, feat-016). A translation mode
  /// still at the old level's default follows the new level.
  Future<void> changeLevel(
    int id,
    CefrLevel level, {
    required DateTime now,
  }) async {
    final p = await get(id);
    if (p == null) return;
    await (db.update(db.profiles)..where((r) => r.id.equals(id))).write(
      ProfilesCompanion(
        currentLevel: Value(level.code),
        translationMode: Value(_followLevel(p, level)),
        levelChangedAt: Value(now),
      ),
    );
  }

  /// The parent's "not now" on a step-back suggestion.
  Future<void> dismissStepBack(int id, {required DateTime now}) =>
      (db.update(db.profiles)..where((r) => r.id.equals(id))).write(
        ProfilesCompanion(stepBackDismissedAt: Value(now)),
      );

  static TranslationMode _followLevel(ProfileRow p, CefrLevel level) {
    final old = CefrLevel.fromCode(p.currentLevel);
    return p.translationMode == ProfileDraft.defaultTranslationMode(old)
        ? ProfileDraft.defaultTranslationMode(level)
        : p.translationMode;
  }

  /// Placement done (feat-015): sets the starting level and favourites.
  /// A translation mode still at the old level's default follows the new
  /// level; one the parent chose is kept.
  Future<void> finishPlacement(
    int id, {
    required CefrLevel level,
    required List<String> interests,
    required DateTime now,
  }) async {
    final p = await get(id);
    if (p == null) return;
    await (db.update(db.profiles)..where((r) => r.id.equals(id))).write(
      ProfilesCompanion(
        currentLevel: Value(level.code),
        interests: Value(interests),
        translationMode: Value(_followLevel(p, level)),
        onboardedAt: Value(now),
      ),
    );
  }

  /// The parent skips placement: the level set in the form stays.
  Future<void> skipPlacement(int id, {required DateTime now}) =>
      (db.update(db.profiles)..where((r) => r.id.equals(id))).write(
        ProfilesCompanion(onboardedAt: Value(now)),
      );

  /// The child takes placement again on next open.
  Future<void> redoPlacement(int id) =>
      (db.update(db.profiles)..where((r) => r.id.equals(id))).write(
        const ProfilesCompanion(onboardedAt: Value(null)),
      );

  /// Deletes the profile and (by cascade) all its progress and logs.
  Future<void> delete(int id) =>
      (db.delete(db.profiles)..where((p) => p.id.equals(id))).go();

  /// Clears progress and logs but keeps the profile and its settings.
  Future<void> resetProgress(int id) => db.transaction(() async {
    await (db.delete(
      db.wordProgress,
    )..where((p) => p.profileId.equals(id))).go();
    await (db.delete(
      db.sessionLogs,
    )..where((p) => p.profileId.equals(id))).go();
    await (db.delete(db.quizLogs)..where((q) => q.profileId.equals(id))).go();
  });
}
