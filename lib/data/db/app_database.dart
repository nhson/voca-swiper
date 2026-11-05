import 'package:drift/drift.dart';

import '../../core/srs/word_state.dart';
import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Words,
    Translations,
    ParentAccounts,
    Profiles,
    WordProgress,
    SessionLogs,
    QuizLogs,
    AppMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  /// 1: Phase 1. 2: QuizLogs (feat-013).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(quizLogs);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
