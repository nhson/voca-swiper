// On-device check of the daily reminder (feat-007): nothing is scheduled
// when no reviews are due; when they are, the OS really delivers the
// notification at the chosen time.
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/reminder_on_device_test.dart -d <device>
// iOS simulators can't pre-grant notification permission, so the test asks
// for *provisional* permission, which iOS grants without a dialog. On
// Android, grant POST_NOTIFICATIONS with adb while the test waits.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voca_swiper/app/app.dart';
import 'package:voca_swiper/app/providers.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/features/reminders/reminder_notifier.dart';
import 'package:voca_swiper/features/reminders/reminder_service.dart';
import 'package:voca_swiper/main.dart' show wordBankAsset;
import 'package:voca_swiper/ui/kid_look.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reminder: skipped with nothing due, fires when due', (t) async {
    final size = t.view.physicalSize / t.view.devicePixelRatio;
    final tag = size.shortestSide >= 600 ? 'tablet' : 'phone';
    final now = DateTime.now().toUtc();

    final db = AppDatabase(NativeDatabase.memory());
    await WordBankImporter(
      db,
    ).importIfNewer(await rootBundle.loadString(wordBankAsset));
    await ParentRepository(db).create('1234', now: now);
    final kid = await ProfileRepository(db).create(
      const ProfileDraft(
        name: 'Bi',
        avatar: '🐯',
        age: 6,
        level: CefrLevel.preA1,
      ),
      now: now,
    );

    final plugin = FlutterLocalNotificationsPlugin();
    final notifier = LocalReminderNotifier(plugin);
    await notifier.replace(const []); // initializes the plugin, clears all
    final ios = plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        sound: true,
        provisional: true,
      );
      expect(granted, isTrue);
    } else {
      // Android: POST_NOTIFICATIONS is granted from outside with
      // `adb shell pm grant <app> android.permission.POST_NOTIFICATIONS`.
      var enabled = false;
      for (var i = 0; i < 60 && !enabled; i++) {
        enabled = await android!.areNotificationsEnabled() ?? false;
        if (!enabled) await Future<void>.delayed(const Duration(seconds: 2));
      }
      expect(enabled, isTrue, reason: 'grant POST_NOTIFICATIONS via adb');
    }

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        reminderNotifierProvider.overrideWithValue(notifier),
        ambientMotionProvider.overrideWithValue(false),
      ],
    );
    final service = container.read(reminderServiceProvider);

    // Two minutes from now; no quiet hours or school block in the way.
    final local = DateTime.now().add(const Duration(minutes: 2));
    final minute = local.hour * 60 + local.minute;
    await ParentRepository(db).updateReminders(
      reminderMinuteOfDay: minute,
      quietStartMinute: 0,
      quietEndMinute: 0,
      blockSchoolHours: false,
      schoolStartMinute: 0,
      schoolEndMinute: 0,
    );

    // 1. Nothing due → nothing on the OS schedule.
    await service.refresh();
    expect(await plugin.pendingNotificationRequests(), isEmpty);

    // 2. A review comes due → one reminder a day for the week.
    await ProgressRepository(db).save(
      kid,
      'cat',
      WordSchedule(
        state: WordState.review,
        easeFactor: 2.5,
        intervalDays: 3,
        repetitions: 2,
        nextReviewAt: now.subtract(const Duration(hours: 1)),
        lastAnsweredAt: now.subtract(const Duration(days: 3)),
        correctCount: 2,
        wrongCount: 0,
      ),
      now: now,
    );
    final plan = await service.refresh();
    var pending = await plugin.pendingNotificationRequests();
    expect(pending, hasLength(7));
    expect(pending.map((p) => p.body).toSet(), {
      'Bi, 1 word is waiting to say hi!',
    });

    // The parent's view of it.
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocaSwiperApp(),
      ),
    );
    await t.pumpAndSettle();
    // Android renders to a texture; it must be switched to an image surface
    // once before screenshots.
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await t.pumpAndSettle();
    }
    await t.tap(find.byKey(const Key('open-parent')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('pin-field')), '1234');
    await t.tap(find.byKey(const Key('unlock')));
    await t.pumpAndSettle();
    final tile = find.byKey(const Key('open-reminders'));
    await t.scrollUntilVisible(tile, 100);
    await binding.takeScreenshot('$tag-r1-parent-area');
    await t.tap(tile);
    await t.pumpAndSettle();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await t.pump();
    await binding.takeScreenshot('$tag-r2-reminders');
    expect(find.byKey(const Key('next-reminder')), findsOneWidget);

    // 3. Wait for the first one to fire, then ask the OS what it delivered.
    // Android alarms are inexact (no exact-alarm permission), so keep
    // checking for a while after the planned time.
    final wait =
        plan.first.at.difference(DateTime.now()) + const Duration(seconds: 20);
    debugPrint('waiting ${wait.inSeconds}s for the reminder to fire');
    await Future<void>.delayed(wait);
    var delivered = await plugin.getActiveNotifications();
    for (var i = 0; i < 60 && delivered.isEmpty; i++) {
      await Future<void>.delayed(const Duration(seconds: 10));
      delivered = await plugin.getActiveNotifications();
    }
    final late = DateTime.now().difference(plan.first.at);
    debugPrint('delivered ${late.inSeconds}s after the planned time');
    await t.pump();
    expect(
      delivered.map((n) => n.body),
      contains('Bi, 1 word is waiting to say hi!'),
    );
    pending = await plugin.pendingNotificationRequests();
    expect(pending, hasLength(6), reason: 'the first one was delivered');

    await plugin.cancelAll();
    await t.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  }, timeout: const Timeout(Duration(minutes: 16)));
}
