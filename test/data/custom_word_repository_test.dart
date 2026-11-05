import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/custom_word_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/data/repositories/word_repository.dart';

import '../support/test_db.dart';

void main() {
  final now = DateTime.utc(2026, 11, 4, 9);
  late AppDatabase db;
  late CustomWordRepository repo;
  late int bi, an;

  setUp(() async {
    db = await seededDb([
      w('cat', rank: 1, emoji: '🐱', vi: 'con mèo'),
      w('ice cream', rank: 2, emoji: '🍦', vi: 'kem'),
    ]);
    repo = CustomWordRepository(db);
    final profiles = ProfileRepository(db);
    const draft = ProfileDraft(
      name: 'Bi',
      avatar: '🐯',
      age: 6,
      level: CefrLevel.preA1,
    );
    bi = await profiles.create(draft, now: now);
    an = await profiles.create(draft, now: now);
  });
  tearDown(() => db.close());

  test('a word in the bank is matched, case and spaces ignored', () async {
    final m = await repo.match('  Ice  Cream ');
    expect(m?.id, 'ice cream');
    expect(await repo.match('dinosaur'), isNull);
  });

  test('add a bank word: uses the bank id and content', () async {
    final row = await repo.add(bi, text: 'CAT', now: now);
    expect(row.wordId, 'cat');
    expect(effectiveWordId(row), 'cat');
    final cards = await WordRepository(db).cards(['cat'], language: 'vi');
    expect(cards.single.translation, 'con mèo');
  });

  test('add a new word: own content, custom id, shown as a card', () async {
    final row = await repo.add(
      bi,
      text: 'Dinosaur',
      definition: 'A very big animal from long ago.',
      translation: 'khủng long',
      emoji: '🦖',
      now: now,
    );
    expect(row.wordId, isNull);
    final id = effectiveWordId(row);
    expect(id, startsWith('custom:'));
    final card = (await WordRepository(
      db,
    ).cards([id, 'cat'], language: 'vi')).first;
    expect(card.word.id, id);
    expect(card.word.word, 'dinosaur');
    expect(card.word.emoji, '🦖');
    expect(card.word.definition, 'A very big animal from long ago.');
    expect(card.translation, 'khủng long');
  });

  test('the same word twice for one child is refused', () async {
    await repo.add(bi, text: 'dinosaur', now: now);
    expect(
      () => repo.add(bi, text: ' Dinosaur', now: now),
      throwsA(isA<DuplicateCustomWord>()),
    );
    await repo.add(bi, text: 'cat', now: now);
    expect(
      () => repo.add(bi, text: 'Cat', now: now),
      throwsA(isA<DuplicateCustomWord>()),
    );
  });

  test('lists are per child', () async {
    await repo.add(bi, text: 'dinosaur', now: now);
    await repo.add(an, text: 'rocket', now: now);
    expect((await repo.list(bi)).map((r) => r.word), ['dinosaur']);
    expect((await repo.list(an)).map((r) => r.word), ['rocket']);
  });

  test('edit a new word', () async {
    final row = await repo.add(bi, text: 'dinosaur', now: now);
    await repo.update(
      row.id,
      text: 'Dino',
      definition: 'Short for dinosaur.',
      translation: 'khủng long',
      emoji: '🦕',
    );
    final back = (await repo.list(bi)).single;
    expect(back.word, 'dino');
    expect(back.emoji, '🦕');
    expect(back.definition, 'Short for dinosaur.');
  });

  test('unseen words in the order added; seen ones drop out', () async {
    await repo.add(bi, text: 'dinosaur', now: now);
    await repo.add(bi, text: 'cat', now: now.add(const Duration(minutes: 1)));
    final ids = await repo.unseenIds(bi);
    expect(ids, [startsWith('custom:'), 'cat']);
    await ProgressRepository(
      db,
    ).save(bi, 'cat', WordSchedule.initial(), now: now);
    expect(await repo.unseenIds(bi), [ids.first]);
    expect(await repo.unseenIds(an), isEmpty);
  });

  test(
    'delete: a new word takes its progress with it; a bank word keeps it',
    () async {
      final dino = await repo.add(bi, text: 'dinosaur', now: now);
      final cat = await repo.add(bi, text: 'cat', now: now);
      final progress = ProgressRepository(db);
      await progress.save(
        bi,
        effectiveWordId(dino),
        WordSchedule.initial(),
        now: now,
      );
      await progress.save(bi, 'cat', WordSchedule.initial(), now: now);

      await repo.delete(dino.id);
      await repo.delete(cat.id);
      expect(await repo.list(bi), isEmpty);
      expect((await progress.schedules(bi)).keys, ['cat']);
    },
  );

  test('deleting the child deletes their list', () async {
    await repo.add(bi, text: 'dinosaur', now: now);
    await ProfileRepository(db).delete(bi);
    expect(await db.select(db.customWords).get(), isEmpty);
  });
}
