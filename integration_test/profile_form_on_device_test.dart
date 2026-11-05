// On-device look at the parent's profile form, including the session-size
// hint under "Minutes per day" (feat-011).
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/profile_form_on_device_test.dart -d <device>
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voca_swiper/app/app.dart';
import 'package:voca_swiper/app/providers.dart';
import 'package:voca_swiper/core/levels.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/repositories/profile_repository.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/main.dart' show wordBankAsset;
import 'package:voca_swiper/ui/kid_look.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profile form shows the session size', (t) async {
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

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
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
    await t.tap(find.byKey(Key('parent-profile-$kid')));
    await t.pumpAndSettle();

    final hint = find.byKey(const Key('minutes-hint'));
    await t.scrollUntilVisible(
      hint,
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('profile-form')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    // Lift the hint and slider to the middle of the screen for the shot.
    await t.drag(find.byKey(const Key('daily-new')), const Offset(0, -150));
    await t.pumpAndSettle();
    expect(t.widget<Text>(hint).data, contains('up to 25 cards'));
    await binding.takeScreenshot('$tag-f1-profile-form');

    await t.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
}
