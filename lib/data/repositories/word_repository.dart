import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/custom_words.dart';
import '../../core/levels.dart';
import '../db/app_database.dart';

/// A word with the translation for one native language.
class WordCard {
  const WordCard(this.word, this.translation);
  final WordRow word;
  final String? translation;
}

class WordRepository {
  WordRepository(this.db);

  final AppDatabase db;

  Future<int> count() => db.words.count().getSingle();

  /// Candidate new words for a profile: never seen by the profile, allowed for
  /// its age, at its level first, then lower levels; within a level, words in
  /// a favourite theme ([interests]) first (feat-015), then teaching order.
  Future<List<String>> newWordCandidates({
    required int profileId,
    required int levelIndex,
    required int age,
    required int limit,
    List<String> interests = const [],
    bool exactLevel = false,
  }) async {
    final seen = db.selectOnly(db.wordProgress)
      ..addColumns([db.wordProgress.wordId])
      ..where(db.wordProgress.profileId.equals(profileId));
    final q = db.select(db.words)
      ..where(
        (w) =>
            w.minAge.isSmallerOrEqualValue(age) &
            (exactLevel
                ? w.levelIndex.equals(levelIndex)
                : w.levelIndex.isSmallerOrEqualValue(levelIndex)) &
            w.id.isNotInQuery(seen),
      )
      ..orderBy([
        (w) => OrderingTerm.desc(w.levelIndex),
        if (interests.isNotEmpty)
          (w) => OrderingTerm.desc(_inAnyTheme(w, interests)),
        (w) => OrderingTerm.asc(w.rank),
      ])
      ..limit(limit);
    return (await q.get()).map((w) => w.id).toList();
  }

  /// Themes are stored as a JSON list, e.g. `["toys","animals"]`; match the
  /// quoted id so "toy" does not match "toys".
  static Expression<bool> _inAnyTheme($WordsTable w, List<String> themes) =>
      themes
          .map((t) => w.themes.like('%${jsonEncode(t)}%'))
          .reduce((a, b) => a | b);

  /// Every word allowed for [age], by level then teaching order, with its
  /// translation: the placement test's pool and check options (feat-015).
  Future<List<WordCard>> placementWords({
    required int age,
    required String language,
  }) async {
    final words =
        await (db.select(db.words)
              ..where((w) => w.minAge.isSmallerOrEqualValue(age))
              ..orderBy([
                (w) => OrderingTerm.asc(w.levelIndex),
                (w) => OrderingTerm.asc(w.rank),
              ]))
            .get();
    final tr = {
      for (final t in await (db.select(
        db.translations,
      )..where((t) => t.languageCode.equals(language))).get())
        t.wordId: t.translation,
    };
    return [for (final w in words) WordCard(w, tr[w.id])];
  }

  /// Words per level allowed for [age] (levels with none are left out).
  Future<Map<CefrLevel, int>> levelCounts({required int age}) async {
    final n = db.words.id.count();
    final q = db.selectOnly(db.words)
      ..addColumns([db.words.levelIndex, n])
      ..where(db.words.minAge.isSmallerOrEqualValue(age))
      ..groupBy([db.words.levelIndex])
      ..orderBy([OrderingTerm.asc(db.words.levelIndex)]);
    return {
      for (final r in await q.get())
        CefrLevel.values[r.read(db.words.levelIndex)!]: r.read(n)!,
    };
  }

  /// Words per theme up to [levelIndex], allowed for [age].
  Future<Map<String, int>> themeCounts({
    required int levelIndex,
    required int age,
  }) async {
    final words =
        await (db.select(db.words)..where(
              (w) =>
                  w.minAge.isSmallerOrEqualValue(age) &
                  w.levelIndex.isSmallerOrEqualValue(levelIndex),
            ))
            .get();
    final counts = <String, int>{};
    for (final w in words) {
      for (final t in w.themes) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Words to draw wrong quiz options from: allowed for the age, up to the
  /// profile's level, in teaching order (feat-012).
  Future<List<WordCard>> quizPool({
    required int levelIndex,
    required int age,
    required String language,
    int limit = 60,
  }) async {
    final q = db.select(db.words)
      ..where(
        (w) =>
            w.minAge.isSmallerOrEqualValue(age) &
            w.levelIndex.isSmallerOrEqualValue(levelIndex),
      )
      ..orderBy([
        (w) => OrderingTerm.asc(w.levelIndex),
        (w) => OrderingTerm.asc(w.rank),
      ])
      ..limit(limit);
    final ids = (await q.get()).map((w) => w.id).toList();
    return cards(ids, language: language);
  }

  /// Cards for [ids] in the same order; unknown ids are skipped. Custom
  /// words (`custom:<n>`, feat-018) are built from the parent's content.
  Future<List<WordCard>> cards(
    List<String> ids, {
    required String language,
  }) async {
    if (ids.isEmpty) return const [];
    final customIds = [for (final id in ids) ?parseCustomWordId(id)];
    final custom = customIds.isEmpty
        ? const <String, WordCard>{}
        : {
            for (final c in await (db.select(
              db.customWords,
            )..where((c) => c.id.isIn(customIds))).get())
              customWordId(c.id): _customCard(c),
          };
    final words = await (db.select(
      db.words,
    )..where((w) => w.id.isIn(ids))).get();
    final translations =
        await (db.select(db.translations)..where(
              (t) => t.wordId.isIn(ids) & t.languageCode.equals(language),
            ))
            .get();
    final byId = {for (final w in words) w.id: w};
    final tr = {for (final t in translations) t.wordId: t.translation};
    return [
      for (final id in ids)
        if (byId[id] != null)
          WordCard(byId[id]!, tr[id])
        else if (custom[id] != null)
          custom[id]!,
    ];
  }

  static WordCard _customCard(CustomWordRow c) => WordCard(
    WordRow(
      id: customWordId(c.id),
      word: c.word,
      partOfSpeech: 'my word',
      cefrLevel: 'custom',
      levelIndex: 0,
      rank: 0,
      minAge: 0,
      themes: const [],
      emoji: c.emoji,
      definition: c.definition,
      examples: const [],
      forms: const {},
    ),
    c.translation,
  );
}
