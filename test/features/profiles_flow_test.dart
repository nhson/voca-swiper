import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';

import '../support/app_harness.dart';
import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  setUp(() async => db = await seededDb([w('cat')]));
  tearDown(() => db.close());

  testWidgets('first run: create PIN, add a child, see the picker', (t) async {
    await pumpApp(t, db);
    expect(find.text('Welcome to Voca Swiper'), findsOneWidget);

    await t.enterText(find.byKey(const Key('setup-pin')), '1234');
    await t.enterText(find.byKey(const Key('setup-confirm')), '1243');
    await t.tap(find.byKey(const Key('setup-create')));
    await t.pumpAndSettle();
    expect(find.text('The two PINs are different.'), findsOneWidget);

    await t.enterText(find.byKey(const Key('setup-confirm')), '1234');
    await t.tap(find.byKey(const Key('setup-create')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('name-field')), findsOneWidget);

    await t.enterText(find.byKey(const Key('name-field')), 'Bi');
    await scrollForm(t, find.byKey(const Key('save-profile')));
    await t.tap(find.byKey(const Key('save-profile')));
    await t.pumpAndSettle();

    final rows = await db.select(db.profiles).get();
    expect(rows.single.name, 'Bi');
    expect(rows.single.currentLevel, 'preA1'); // age 6 default
    final account = await db.select(db.parentAccounts).getSingle();
    expect(account.pinHash, isNot(contains('1234')));
  });

  testWidgets('parent area needs the PIN and locks on exit', (t) async {
    await createParent(db);
    await createKid(db);
    await pumpApp(t, db);
    expect(find.text("Who's learning today?"), findsOneWidget);
    expect(find.text('Bi'), findsOneWidget);

    await unlockParent(t, pin: '0000');
    expect(find.text('Wrong PIN. Try again.'), findsOneWidget);
    expect(find.text('Parent area'), findsNothing);

    await t.enterText(find.byKey(const Key('pin-field')), '1234');
    await t.tap(find.byKey(const Key('unlock')));
    await t.pumpAndSettle();
    expect(find.text('Parent area'), findsOneWidget);

    await t.tap(find.byKey(const Key('exit-parent')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('open-parent')));
    await t.pumpAndSettle();
    expect(find.text('Parents only'), findsOneWidget);
  });

  testWidgets('editing one profile leaves the other unchanged', (t) async {
    await createParent(db);
    final a = await createKid(db, name: 'Bi');
    final b = await createKid(db, name: 'Na', age: 9);
    await pumpApp(t, db);
    await unlockParent(t);

    await t.tap(find.byKey(Key('parent-profile-$a')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('name-field')), 'Bo');
    await scrollForm(t, find.byKey(const Key('swipe-direction')));
    await t.tap(find.byKey(const Key('swipe-direction')));
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('save-profile')));
    await t.tap(find.byKey(const Key('save-profile')));
    await t.pumpAndSettle();

    final repo = ProfileRepository(db);
    final ra = (await repo.get(a))!;
    final rb = (await repo.get(b))!;
    expect([ra.name, ra.swipeKnownRight], ['Bo', false]);
    expect([rb.name, rb.swipeKnownRight], ['Na', true]);
  });

  testWidgets('delete a profile after confirming', (t) async {
    await createParent(db);
    final a = await createKid(db);
    await pumpApp(t, db);
    await unlockParent(t);
    await t.tap(find.byKey(Key('parent-profile-$a')));
    await t.pumpAndSettle();
    await scrollForm(t, find.byKey(const Key('delete-profile')));
    await t.tap(find.byKey(const Key('delete-profile')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirm')));
    await t.pumpAndSettle();
    expect(await db.select(db.profiles).get(), isEmpty);
  });

  testWidgets('tapping a profile opens the child home', (t) async {
    await createParent(db);
    final a = await createKid(db, name: 'Bi');
    await pumpApp(t, db);
    await t.tap(find.byKey(Key('profile-$a')));
    await t.pumpAndSettle();
    expect(find.text('Hi Bi!'), findsOneWidget);
  });
}
