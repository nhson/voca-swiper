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

  ProfileDraft copyWith({List<String>? interests}) => ProfileDraft(
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
  );
}

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

  Future<void> update(int id, ProfileDraft d) => (db.update(
    db.profiles,
  )..where((p) => p.id.equals(id))).write(d._companion());

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
    final old = CefrLevel.fromCode(p.currentLevel);
    final mode = p.translationMode == ProfileDraft.defaultTranslationMode(old)
        ? ProfileDraft.defaultTranslationMode(level)
        : p.translationMode;
    await (db.update(db.profiles)..where((r) => r.id.equals(id))).write(
      ProfilesCompanion(
        currentLevel: Value(level.code),
        interests: Value(interests),
        translationMode: Value(mode),
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
