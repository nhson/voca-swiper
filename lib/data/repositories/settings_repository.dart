import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// App-wide settings kept in the AppMeta key–value table.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const _soundKey = 'sound_effects';

  SimpleSelectStatement<$AppMetaTable, AppMetaRow> _sound() =>
      _db.select(_db.appMeta)..where((m) => m.key.equals(_soundKey));

  /// Short UI sound effects (not word audio). On unless a parent turns
  /// them off.
  Future<bool> soundEffects() async =>
      (await _sound().getSingleOrNull())?.value != 'off';

  Stream<bool> watchSoundEffects() =>
      _sound().watchSingleOrNull().map((r) => r?.value != 'off');

  Future<void> setSoundEffects(bool on) => _db
      .into(_db.appMeta)
      .insertOnConflictUpdate(
        AppMetaCompanion.insert(key: _soundKey, value: on ? 'on' : 'off'),
      );
}
