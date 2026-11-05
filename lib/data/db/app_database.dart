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

  /// 1: Phase 1. 2: QuizLogs (feat-013). 3: profile interests and
  /// onboardedAt (feat-015). 4: levelLocked, levelChangedAt,
  /// stepBackDismissedAt (feat-016).
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(quizLogs);
      if (from < 3) {
        await m.addColumn(profiles, profiles.interests);
        await m.addColumn(profiles, profiles.onboardedAt);
        // Children set up before placement existed keep their level.
        await customStatement('UPDATE profiles SET onboarded_at = created_at');
      }
      if (from < 4) {
        await m.addColumn(profiles, profiles.levelLocked);
        await m.addColumn(profiles, profiles.levelChangedAt);
        await m.addColumn(profiles, profiles.stepBackDismissedAt);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
