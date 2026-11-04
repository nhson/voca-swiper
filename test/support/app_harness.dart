import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/app/app.dart';
import 'package:voca_swiper/app/providers.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';

final testNow = DateTime.utc(2026, 11, 4, 9);

/// Pumps the full app on [db] with a fixed clock and a phone-sized screen.
Future<void> pumpApp(
  WidgetTester tester,
  AppDatabase db, {
  DateTime? now,
  Size size = const Size(400, 860),
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  // Unmount the app (and its live DB queries) before the test's tearDown
  // closes the database. Without this, a test that fails with a pushed route
  // on screen makes db.close() hang until the runner times out (minutes).
  addTearDown(() => tester.pumpWidget(const SizedBox()));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now ?? testNow),
        parentRepositoryProvider.overrideWithValue(
          ParentRepository(db, run: runInline),
        ),
      ],
      child: const VocaSwiperApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> createParent(AppDatabase db, {String pin = '1234'}) =>
    ParentRepository(db, run: runInline).create(pin, now: testNow);

Future<int> createKid(
  AppDatabase db, {
  String name = 'Bi',
  int age = 6,
  CefrLevel level = CefrLevel.preA1,
}) => ProfileRepository(db).create(
  ProfileDraft(name: name, avatar: '🐯', age: age, level: level),
  now: testNow,
);

Future<void> unlockParent(WidgetTester t, {String pin = '1234'}) async {
  await t.tap(find.byKey(const Key('open-parent')));
  await t.pumpAndSettle();
  await t.enterText(find.byKey(const Key('pin-field')), pin);
  await t.tap(find.byKey(const Key('unlock')));
  await t.pumpAndSettle();
}

/// Scrolls the profile form until [target] is on screen.
Future<void> scrollForm(WidgetTester t, Finder target) async {
  // A focused text field scrolls itself back into view; release it first.
  FocusManager.instance.primaryFocus?.unfocus();
  await t.pumpAndSettle();
  await t.scrollUntilVisible(
    target,
    200,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('profile-form')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await t.ensureVisible(target);
  await t.pumpAndSettle();
}
