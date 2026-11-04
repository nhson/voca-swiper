import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/levels.dart';
import 'db/app_database.dart';

/// Loads the bundled word bank (assets/word_bank/word_bank.json) into the
/// local database when it is missing or older than the bundled version.
///
/// Upserts only: words removed from a newer bank stay in the database so a
/// child's progress on them is never orphaned.
class WordBankImporter {
  WordBankImporter(this.db);

  final AppDatabase db;

  static const versionKey = 'wordBankVersion';

  Future<int?> importedVersion() async {
    final row = await (db.select(
      db.appMeta,
    )..where((m) => m.key.equals(versionKey))).getSingleOrNull();
    return row == null ? null : int.parse(row.value);
  }

  /// Returns true when the bank was (re)imported.
  Future<bool> importIfNewer(String json) async {
    final bank = jsonDecode(json) as Map<String, dynamic>;
    final version = bank['version'] as int;
    final current = await importedVersion();
    if (current != null && current >= version) return false;

    final words = (bank['words'] as List).cast<Map<String, dynamic>>();
    await db.transaction(() async {
      await db.batch((b) {
        b.insertAllOnConflictUpdate(db.words, [
          for (final w in words)
            WordsCompanion.insert(
              id: w['id'] as String,
              word: w['text'] as String,
              partOfSpeech: w['pos'] as String,
              cefrLevel: w['cefr'] as String,
              levelIndex: CefrLevel.fromCode(w['cefr'] as String).index,
              rank: w['rank'] as int,
              minAge: w['minAge'] as int,
              themes: (w['themes'] as List).cast<String>(),
              emoji: Value(w['emoji'] as String?),
              definition: w['definition'] as String,
              examples: (w['examples'] as List).cast<String>(),
              forms: (w['forms'] as Map).cast<String, String>(),
            ),
        ]);
        b.insertAllOnConflictUpdate(db.translations, [
          for (final w in words)
            for (final t in (w['translations'] as Map).entries)
              TranslationsCompanion.insert(
                wordId: w['id'] as String,
                languageCode: t.key as String,
                translation: t.value as String,
              ),
        ]);
        b.insertAllOnConflictUpdate(db.appMeta, [
          AppMetaCompanion.insert(key: versionKey, value: '$version'),
        ]);
      });
    });
    return true;
  }
}
