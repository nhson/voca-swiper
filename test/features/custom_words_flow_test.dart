import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/custom_word_repository.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

/// feat-018: parents add words from homework; the child meets them first.
void main() {
  late AppDatabase db;
  late int bi, an;
  setUp(() async {
    db = await seededDb([
      w('cat', rank: 1, emoji: '🐱', vi: 'con mèo'),
      w('dog', rank: 2, emoji: '🐶', vi: 'con chó'),
      w('sun', rank: 3, emoji: '☀️', vi: 'mặt trời'),
      w('ice cream', rank: 4, emoji: '🍦', vi: 'kem'),
    ]);
    await createParent(db);
    bi = await createKid(db);
    an = await createKid(db, name: 'An');
  });
  tearDown(() => db.close());

  Future<void> openList(WidgetTester t, String name) async {
    await unlockParent(t);
    await t.tap(find.text(name));
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('open-custom-words')));
    await t.tap(find.byKey(const Key('open-custom-words')));
    await t.pumpAndSettle();
  }

  Future<void> addOwnWord(WidgetTester t) async {
    await t.tap(find.byKey(const Key('cw-add')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('cw-word')), 'Dinosaur');
    await t.pumpAndSettle();
    expect(find.byKey(const Key('cw-match')), findsNothing);
    await t.enterText(
      find.byKey(const Key('cw-definition')),
      'A very big animal from long ago.',
    );
    await t.enterText(find.byKey(const Key('cw-translation')), 'khủng long');
    await t.tap(find.byKey(const Key('cw-emoji-🦖')));
    await t.pump();
    await t.tap(find.byKey(const Key('cw-save')));
    await t.pumpAndSettle();
  }

  testWidgets('add a new word; the child meets it first next session', (
    t,
  ) async {
    final speaker = FakeSpeaker();
    await pumpApp(t, db, speaker: speaker);
    await openList(t, 'Bi');
    expect(find.byKey(const Key('cw-empty')), findsOneWidget);
    await addOwnWord(t);

    expect(find.text('dinosaur'), findsOneWidget);
    expect(find.text('khủng long · your word'), findsOneWidget);

    // Leave the parent area and start Bi's session.
    await t.pageBack();
    await t.pumpAndSettle();
    await t.pageBack();
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('exit-parent')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(Key('profile-$bi')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    expect(speaker.said.first, 'dinosaur');
    expect(find.text('dinosaur'), findsWidgets);
    expect(find.text('🦖'), findsWidgets);
  });

  testWidgets('custom words are per child', (t) async {
    await CustomWordRepository(db).add(bi, text: 'dinosaur', now: testNow);
    final speaker = FakeSpeaker();
    await pumpApp(t, db, speaker: speaker);
    await t.tap(find.byKey(Key('profile-$an')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    expect(speaker.said.first, 'cat');
  });

  testWidgets('a bank word is matched and uses the bank content', (t) async {
    await pumpApp(t, db);
    await openList(t, 'Bi');
    await t.tap(find.byKey(const Key('cw-add')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('cw-word')), ' Ice Cream');
    await t.pumpAndSettle();
    expect(find.byKey(const Key('cw-match')), findsOneWidget);
    expect(find.text('In the word bank: ice cream'), findsOneWidget);
    expect(find.byKey(const Key('cw-definition')), findsNothing);
    await t.tap(find.byKey(const Key('cw-save')));
    await t.pumpAndSettle();
    expect(find.text('kem · from word bank'), findsOneWidget);
    final row = (await CustomWordRepository(db).list(bi)).single;
    expect(row.wordId, 'ice cream');
  });

  testWidgets('edit a word, then remove it', (t) async {
    await pumpApp(t, db);
    await openList(t, 'Bi');
    await addOwnWord(t);
    final row = (await CustomWordRepository(db).list(bi)).single;

    await t.tap(find.byKey(Key('cw-row-${row.id}')));
    await t.pumpAndSettle();
    expect(find.text('Edit word'), findsOneWidget);
    await t.enterText(
      find.byKey(const Key('cw-translation')),
      'con khủng long',
    );
    await t.tap(find.byKey(const Key('cw-save')));
    await t.pumpAndSettle();
    expect(find.text('con khủng long · your word'), findsOneWidget);

    await t.tap(find.byKey(Key('cw-delete-${row.id}')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirm')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('cw-empty')), findsOneWidget);
    expect(await CustomWordRepository(db).list(bi), isEmpty);
  });

  testWidgets('bad input and duplicates are explained', (t) async {
    await pumpApp(t, db);
    await openList(t, 'Bi');
    await addOwnWord(t);
    await t.tap(find.byKey(const Key('cw-add')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('cw-save')));
    await t.pumpAndSettle();
    expect(find.text('Type the word.'), findsOneWidget);
    await t.enterText(find.byKey(const Key('cw-word')), 'dino2');
    await t.tap(find.byKey(const Key('cw-save')));
    await t.pumpAndSettle();
    expect(find.text('Letters only, please.'), findsOneWidget);
    await t.enterText(find.byKey(const Key('cw-word')), 'DINOSAUR');
    await t.tap(find.byKey(const Key('cw-save')));
    await t.pumpAndSettle();
    expect(find.text('Already in the list.'), findsOneWidget);
  });
}
