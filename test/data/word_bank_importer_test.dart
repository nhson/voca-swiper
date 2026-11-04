import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/data/repositories/word_repository.dart';

import '../support/test_db.dart';

void main() {
  test('imports the bundled bank and records its version', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final importer = WordBankImporter(db);

    expect(await importer.importIfNewer(bundledBankJson()), isTrue);
    expect(await importer.importedVersion(), 1);
    expect(await WordRepository(db).count(), greaterThan(300));

    final cards = await WordRepository(db).cards(['cat'], language: 'vi');
    expect(cards.single.word.word, 'cat');
    expect(cards.single.word.emoji, '🐱');
    expect(cards.single.translation, 'con mèo');
  });

  test('same or older version is skipped', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final importer = WordBankImporter(db);
    await importer.importIfNewer(bankJson([w('a')], version: 2));
    expect(
      await importer.importIfNewer(bankJson([w('b')], version: 2)),
      isFalse,
    );
    expect(
      await importer.importIfNewer(bankJson([w('b')], version: 1)),
      isFalse,
    );
    expect(await WordRepository(db).count(), 1);
  });

  test('newer version upserts and keeps words it no longer lists', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final importer = WordBankImporter(db);
    await importer.importIfNewer(bankJson([w('a', vi: 'old')], version: 1));
    expect(
      await importer.importIfNewer(
        bankJson([w('a', vi: 'new'), w('b')], version: 2),
      ),
      isTrue,
    );
    final cards = await WordRepository(db).cards(['a', 'b'], language: 'vi');
    expect(cards.map((c) => c.translation), ['new', 'vi']);
    expect(await importer.importedVersion(), 2);
  });
}
