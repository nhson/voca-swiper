import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/app/app.dart';
import 'package:voca_swiper/app/providers.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/core/reminders/reminder_planner.dart';
import 'package:voca_swiper/features/reminders/reminder_notifier.dart';
import 'package:voca_swiper/features/session/speaker.dart';
import 'package:voca_swiper/ui/kid_look.dart';
import 'package:voca_swiper/ui/sfx.dart';

final testNow = DateTime.utc(2026, 11, 4, 9);

/// Records what the app asked to say.
class FakeSpeaker implements Speaker {
  final said = <String>[];
  @override
  Future<void> say(String text) async => said.add(text);
  @override
  Future<void> stop() async {}
}

/// Records the UI sounds the app played.
class FakeSfx implements Sfx {
  final played = <Sound>[];
  @override
  void play(Sound sound) => played.add(sound);
}

/// Records what would be put on the device's notification schedule.
class FakeReminderNotifier implements ReminderNotifier {
  FakeReminderNotifier({this.allow = true});
  bool allow;
  int permissionAsks = 0;
  List<PlannedReminder>? scheduled;
  @override
  Future<bool> requestPermission() async {
    permissionAsks++;
    return allow;
  }

  @override
  Future<void> replace(List<PlannedReminder> plan) async => scheduled = plan;
}

/// Pumps the full app on [db] with a fixed clock and a phone-sized screen.
Future<void> pumpApp(
  WidgetTester tester,
  AppDatabase db, {
  DateTime? now,
  Size size = const Size(400, 860),
  FakeSpeaker? speaker,
  Sfx? sfx,
  FakeReminderNotifier? notifier,
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
        speakerProvider.overrideWithValue(speaker ?? FakeSpeaker()),
        sfxProvider.overrideWithValue(sfx ?? FakeSfx()),
        reminderNotifierProvider.overrideWithValue(
          notifier ?? FakeReminderNotifier(),
        ),
        // Endless idle loops would keep pumpAndSettle from settling.
        ambientMotionProvider.overrideWithValue(false),
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
  bool swipeKnownRight = true,
  TranslationMode translationMode = TranslationMode.always,
  int dailyMinutes = 10,
}) => ProfileRepository(db).create(
  ProfileDraft(
    name: name,
    avatar: '🐯',
    age: age,
    level: level,
    swipeKnownRight: swipeKnownRight,
    translationMode: translationMode,
    dailyMinutes: dailyMinutes,
  ),
  now: testNow,
);

/// The text input inside a [PinBoxes] with the given key.
Finder pinInput(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(EditableText),
);

Future<void> unlockParent(WidgetTester t, {String pin = '1234'}) async {
  await t.tap(find.byKey(const Key('open-parent')));
  await t.pumpAndSettle();
  await t.enterText(pinInput('pin-field'), pin);
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
