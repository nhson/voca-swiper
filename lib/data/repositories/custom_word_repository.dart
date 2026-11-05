import 'package:drift/drift.dart';

import '../../core/custom_words.dart';
import '../db/app_database.dart';

/// The parent tried to add a word the child already has in their list.
class DuplicateCustomWord implements Exception {
  const DuplicateCustomWord(this.text);
  final String text;
  @override
  String toString() => 'DuplicateCustomWord($text)';
}

/// The word id sessions and progress use for a custom word.
String effectiveWordId(CustomWordRow r) => r.wordId ?? customWordId(r.id);

/// Per-child custom words (feat-018).
class CustomWordRepository {
  CustomWordRepository(this.db);

  final AppDatabase db;

  /// The bank word with this text (case and spaces ignored), easiest first
  /// when the bank has more than one.
  Future<WordRow?> match(String text) async {
    final t = normalizeWord(text);
    if (t.isEmpty) return null;
    final rows =
        await (db.select(db.words)
              ..where((w) => w.word.lower().equals(t))
              ..orderBy([
                (w) => OrderingTerm.asc(w.levelIndex),
                (w) => OrderingTerm.asc(w.rank),
              ])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<CustomWordRow>> list(int profileId) =>
      (db.select(db.customWords)
            ..where((c) => c.profileId.equals(profileId))
            ..orderBy([
              (c) => OrderingTerm.asc(c.addedAt),
              (c) => OrderingTerm.asc(c.id),
            ]))
          .get();

  Stream<List<CustomWordRow>> watch(int profileId) =>
      (db.select(db.customWords)
            ..where((c) => c.profileId.equals(profileId))
            ..orderBy([
              (c) => OrderingTerm.asc(c.addedAt),
              (c) => OrderingTerm.asc(c.id),
            ]))
          .watch();

  Future<CustomWordRow?> get(int id) => (db.select(
    db.customWords,
  )..where((c) => c.id.equals(id))).getSingleOrNull();

  /// Adds [text] for the child: matched to the bank when it is there (the
  /// bank's content is used and the other fields are ignored), otherwise
  /// stored with the parent's [definition], [translation] and [emoji].
  Future<CustomWordRow> add(
    int profileId, {
    required String text,
    String definition = '',
    String? translation,
    String? emoji,
    required DateTime now,
  }) async {
    final t = normalizeWord(text);
    final bank = await match(t);
    final existing = await list(profileId);
    final clash = existing.any(
      (r) => bank != null ? r.wordId == bank.id : r.word == t,
    );
    if (clash) throw DuplicateCustomWord(t);
    final id = await db
        .into(db.customWords)
        .insert(
          CustomWordsCompanion.insert(
            profileId: profileId,
            wordId: Value(bank?.id),
            word: bank == null ? t : normalizeWord(bank.word),
            definition: Value(bank == null ? definition.trim() : ''),
            translation: Value(bank == null ? _blankToNull(translation) : null),
            emoji: Value(bank == null ? _blankToNull(emoji) : null),
            addedAt: now,
          ),
        );
    return (await get(id))!;
  }

  /// Edits the parent's own word (bank words are read-only).
  Future<void> update(
    int id, {
    required String text,
    required String definition,
    String? translation,
    String? emoji,
  }) =>
      (db.update(
        db.customWords,
      )..where((c) => c.id.equals(id) & c.wordId.isNull())).write(
        CustomWordsCompanion(
          word: Value(normalizeWord(text)),
          definition: Value(definition.trim()),
          translation: Value(_blankToNull(translation)),
          emoji: Value(_blankToNull(emoji)),
        ),
      );

  /// Removes the word from the child's list. The parent's own word also
  /// loses its progress (nothing else refers to it); a bank word keeps its
  /// progress, as the child may meet it again in the bank.
  Future<void> delete(int id) => db.transaction(() async {
    final row = await get(id);
    if (row == null) return;
    if (row.wordId == null) {
      final wid = customWordId(row.id);
      await (db.delete(db.wordProgress)..where(
            (p) => p.profileId.equals(row.profileId) & p.wordId.equals(wid),
          ))
          .go();
      await (db.delete(db.quizLogs)..where(
            (q) => q.profileId.equals(row.profileId) & q.wordId.equals(wid),
          ))
          .go();
    }
    await (db.delete(db.customWords)..where((c) => c.id.equals(id))).go();
  });

  /// The child's custom words not seen yet, in the order added: they come
  /// first among new words.
  Future<List<String>> unseenIds(int profileId) async {
    final seen = {
      for (final r
          in await (db.selectOnly(db.wordProgress)
                ..addColumns([db.wordProgress.wordId])
                ..where(db.wordProgress.profileId.equals(profileId)))
              .get())
        r.read(db.wordProgress.wordId)!,
    };
    return [
      for (final r in await list(profileId))
        if (!seen.contains(effectiveWordId(r))) effectiveWordId(r),
    ];
  }

  static String? _blankToNull(String? s) =>
      s == null || s.trim().isEmpty ? null : s.trim();
}
