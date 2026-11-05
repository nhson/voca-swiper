import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/settings_repository.dart';

import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  test('sound effects are on by default', () async {
    expect(await SettingsRepository(db).soundEffects(), isTrue);
  });

  test('turning sound effects off is remembered and streamed', () async {
    final repo = SettingsRepository(db);
    final seen = <bool>[];
    final sub = repo.watchSoundEffects().listen(seen.add);
    await pumpEventQueue();
    await repo.setSoundEffects(false);
    await pumpEventQueue();
    expect(await SettingsRepository(db).soundEffects(), isFalse);
    expect(seen, [true, false]);
    await repo.setSoundEffects(true);
    expect(await repo.soundEffects(), isTrue);
    await sub.cancel();
  });

  test('does not disturb other app metadata', () async {
    await db
        .into(db.appMeta)
        .insert(AppMetaCompanion.insert(key: 'word_bank_version', value: '3'));
    await SettingsRepository(db).setSoundEffects(false);
    final rows = await db.select(db.appMeta).get();
    expect(rows.map((r) => r.key).toSet(), {
      'word_bank_version',
      'sound_effects',
    });
  });
}
