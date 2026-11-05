// On-device look at the 6-box PIN: first-run setup and the parent gate.
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/pin_on_device_test.dart -d <device>
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voca_swiper/app/app.dart';
import 'package:voca_swiper/app/providers.dart';
import 'package:voca_swiper/data/db/app_database.dart';
import 'package:voca_swiper/data/repositories/parent_repository.dart';
import 'package:voca_swiper/data/word_bank_importer.dart';
import 'package:voca_swiper/features/parent/parent_providers.dart';
import 'package:voca_swiper/main.dart' show wordBankAsset;
import 'package:voca_swiper/ui/kid_look.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder input(String key) => find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(EditableText),
  );

  testWidgets('6-box PIN: setup and unlock', (t) async {
    final size = t.view.physicalSize / t.view.devicePixelRatio;
    final tag = size.shortestSide >= 600 ? 'tablet' : 'phone';

    final db = AppDatabase(NativeDatabase.memory());
    await WordBankImporter(
      db,
    ).importIfNewer(await rootBundle.loadString(wordBankAsset));
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

    // First run: half-typed PIN.
    await t.enterText(input('setup-pin'), '123');
    await t.pumpAndSettle();
    // iOS can hand back the previous frame; give it a moment.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await t.pump();
    await binding.takeScreenshot('$tag-p1-setup');
    await t.enterText(input('setup-pin'), '246810');
    await t.enterText(input('setup-confirm'), '246810');
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('setup-create')));
    await t.pumpAndSettle();
    expect(await ParentRepository(db).verifyPin('246810'), isTrue);

    // Gate: wrong PIN, then the right one unlocks on the 6th digit.
    container.read(parentUnlockedProvider.notifier).lock();
    await t.pumpAndSettle();
    expect(find.byKey(const Key('pin-field')), findsOneWidget);
    await t.enterText(input('pin-field'), '000000');
    await t.pumpAndSettle();
    expect(find.text('Wrong PIN. Try again.'), findsOneWidget);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await t.pump();
    await binding.takeScreenshot('$tag-p2-gate-error');
    await t.enterText(input('pin-field'), '24');
    await t.pumpAndSettle();
    expect(find.text('Wrong PIN. Try again.'), findsNothing);
    await t.enterText(input('pin-field'), '246810');
    await t.pumpAndSettle();
    expect(find.byKey(const Key('pin-field')), findsNothing);

    await t.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
}
