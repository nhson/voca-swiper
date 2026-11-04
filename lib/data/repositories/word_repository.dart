import 'package:drift/drift.dart';

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
  /// its age, at its level first, then lower levels; teaching order within a
  /// level.
  Future<List<String>> newWordCandidates({
    required int profileId,
    required int levelIndex,
    required int age,
    required int limit,
  }) async {
    final seen = db.selectOnly(db.wordProgress)
      ..addColumns([db.wordProgress.wordId])
      ..where(db.wordProgress.profileId.equals(profileId));
    final q = db.select(db.words)
      ..where(
        (w) =>
            w.minAge.isSmallerOrEqualValue(age) &
            w.levelIndex.isSmallerOrEqualValue(levelIndex) &
            w.id.isNotInQuery(seen),
      )
      ..orderBy([
        (w) => OrderingTerm.desc(w.levelIndex),
        (w) => OrderingTerm.asc(w.rank),
      ])
      ..limit(limit);
    return (await q.get()).map((w) => w.id).toList();
  }

  /// Cards for [ids] in the same order; unknown ids are skipped.
  Future<List<WordCard>> cards(List<String> ids,
      {required String language}) async {
    if (ids.isEmpty) return const [];
    final words =
        await (db.select(db.words)..where((w) => w.id.isIn(ids))).get();
    final translations = await (db.select(db.translations)
          ..where((t) => t.wordId.isIn(ids) & t.languageCode.equals(language)))
        .get();
    final byId = {for (final w in words) w.id: w};
    final tr = {for (final t in translations) t.wordId: t.translation};
    return [
      for (final id in ids)
        if (byId[id] != null) WordCard(byId[id]!, tr[id]),
    ];
  }
}
