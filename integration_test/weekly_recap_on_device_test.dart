// On-device look at feat-019: "This week" on the child home and the weekly
// recap notification on the OS schedule.
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/weekly_recap_on_device_test.dart -d <device>
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
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
import 'package:voca_swiper/core/reminders/reminder_planner.dart';
import 'package:voca_swiper/core/srs/word_schedule.dart';
import 'package:voca_swiper/core/srs/word_state.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/repositories/progress_repository.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/features/reminders/reminder_notifier.dart';
import 'package:voca_swiper/main.dart' show wordBankAsset;
import 'package:voca_swiper/ui/kid_look.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('weekly recap on device', (t) async {
    final size = t.view.physicalSize / t.view.devicePixelRatio;
    final tag = size.shortestSide >= 600 ? 'tablet' : 'phone';
    final now = DateTime.now().toUtc();

    final db = AppDatabase(NativeDatabase.memory());
    await WordBankImporter(
      db,
    ).importIfNewer(await rootBundle.loadString(wordBankAsset));
    await ParentRepository(db).create('1234', now: now);
    final profiles = ProfileRepository(db);
    final progress = ProgressRepository(db);
    final bi = await profiles.create(
      const ProfileDraft(
        name: 'Bi',
        avatar: '🐯',
        age: 6,
        level: CefrLevel.preA1,
      ),
      now: now.subtract(const Duration(days: 60)),
    );
    await profiles.skipPlacement(
      bi,
      now: now.subtract(const Duration(days: 60)),
    );
    final words =
        await (db.select(db.words)
              ..where((w) => w.emoji.isNotNull())
              ..orderBy([(w) => OrderingTerm.asc(w.rank)])
              ..limit(14))
            .get();
    for (final (i, w) in words.indexed) {
      final mastered = i >= 8;
      await progress.save(
        bi,
        w.id,
        WordSchedule(
          state: mastered ? WordState.mastered : WordState.learning,
          easeFactor: 2.5,
          intervalDays: mastered ? 30 : 1,
          repetitions: 3,
          nextReviewAt: now.add(const Duration(days: 2)),
          lastAnsweredAt: now.subtract(Duration(days: mastered ? 20 + i : 1)),
          correctCount: 1 + i % 4,
          wrongCount: 0,
        ),
        now: now.subtract(Duration(days: mastered ? 50 : 1 + i % 6)),
      );
    }
    for (final d in [1, 2, 4, 5]) {
      await progress.logSession(
        profileId: bi,
        startedAt: now.subtract(Duration(days: d)),
        durationSec: 8 * 60,
        reviewed: 6,
        newLearned: 2,
        accuracy: 0.8,
      );
    }

    final plugin = FlutterLocalNotificationsPlugin();
    final notifier = _NoPromptNotifier(plugin);
    await notifier.replace(const []);
    if (Platform.isIOS) {
      // Provisional: granted quietly, no dialog.
      await plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()!
          .requestPermissions(alert: true, sound: true, provisional: true);
    }
    // No quiet hours in the way of the default 18:00.
    await ParentRepository(db).updateReminders(
      reminderMinuteOfDay: null,
      quietStartMinute: 22 * 60,
      quietEndMinute: 7 * 60,
      blockSchoolHours: true,
      schoolStartMinute: 7 * 60 + 30,
      schoolEndMinute: 16 * 60 + 30,
    );

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        reminderNotifierProvider.overrideWithValue(notifier),
        ambientMotionProvider.overrideWithValue(false),
      ],
    );
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocaSwiperApp(),
      ),
    );
    await t.pumpAndSettle();
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await t.pumpAndSettle();
    }

    Future<void> shot(String name) async {
      await t.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await t.pump();
      await binding.takeScreenshot('$tag-f19-$name');
    }

    // 1. Child home: this week's card.
    await t.tap(find.byKey(Key('profile-$bi')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('week-card')), findsOneWidget);
    await t.ensureVisible(find.byKey(const Key('week-card')));
    await shot('1-home');
    final recall = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('recall-'),
    );
    await t.tap(recall.first);
    await shot('2-recall');
    await t.pageBack();
    await t.pumpAndSettle();

    // 2. Parent turns on the weekly recap.
    await t.tap(find.byKey(const Key('open-parent')));
    await t.pumpAndSettle();
    await t.enterText(
      find.descendant(
        of: find.byKey(const Key('pin-field')),
        matching: find.byType(EditableText),
      ),
      '1234',
    );
    await t.pump();
    await t.tap(find.byKey(const Key('unlock')));
    await t.pumpAndSettle();
    await t.tap(find.text('Daily reminder'));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('weekly-toggle')));
    await t.pumpAndSettle();
    await shot('3-setting');

    final pending = await plugin.pendingNotificationRequests();
    expect(pending, hasLength(1));
    expect(pending.single.title, ReminderPlanner.weeklyTitle);
    expect(
      pending.single.body,
      startsWith('Bi learned 8 new words this week!'),
    );

    await notifier.replace(const []);
    await t.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
}

/// Asking for permission would put the OS dialog in front of the test.
class _NoPromptNotifier extends LocalReminderNotifier {
  _NoPromptNotifier(super.plugin);

  @override
  Future<bool> requestPermission() async => true;
}
