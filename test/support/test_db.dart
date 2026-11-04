import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';

AppDatabase memoryDb() => AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

/// The real bundled bank, read from disk.
String bundledBankJson() =>
    File('assets/word_bank/word_bank.json').readAsStringSync();

/// A tiny bank for focused tests.
String bankJson(List<Map<String, Object?>> words, {int version = 1}) =>
    jsonEncode({'version': version, 'words': words});

Map<String, Object?> w(
  String id, {
  String cefr = 'preA1',
  int rank = 1,
  int minAge = 4,
  String vi = 'vi',
}) =>
    {
      'id': id,
      'text': id,
      'pos': 'noun',
      'cefr': cefr,
      'minAge': minAge,
      'themes': ['test'],
      'emoji': null,
      'definition': 'def $id',
      'examples': ['ex $id'],
      'translations': {'vi': vi},
      'forms': <String, String>{},
      'rank': rank,
    };

Future<AppDatabase> seededDb(List<Map<String, Object?>> words) async {
  final db = memoryDb();
  await WordBankImporter(db).importIfNewer(bankJson(words));
  return db;
}
