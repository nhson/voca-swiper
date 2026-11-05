// On-device look at feat-014: the four-level picker and an upper-level card
// (grammar forms, Vietnamese behind a tap).
//   flutter drive --driver test_driver/integration_test.dart \
//     --target integration_test/levels_on_device_test.dart -d <device>
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

  testWidgets('A2/B1 levels on device', (t) async {
    final size = t.view.physicalSize / t.view.devicePixelRatio;
    final tag = size.shortestSide >= 600 ? 'tablet' : 'phone';
    final now = DateTime.now().toUtc();

    final db = AppDatabase(NativeDatabase.memory());
    await WordBankImporter(
      db,
    ).importIfNewer(await rootBundle.loadString(wordBankAsset));
    await ParentRepository(db).create('1234', now: now);
    final kid = await ProfileRepository(db).create(
      ProfileDraft(
        name: 'Tom',
        avatar: '🦊',
        age: 10,
        level: CefrLevel.b1,
        translationMode: ProfileDraft.defaultTranslationMode(CefrLevel.b1),
      ),
      now: now,
    );
    await ProfileRepository(db).skipPlacement(kid, now: now);

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

    Future<void> shot(String name) async {
      await t.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await t.pump();
      await binding.takeScreenshot('$tag-f14-$name');
    }

    // 1. Parent: a new profile offers all four levels.
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
    await t.tap(find.byKey(const Key('add-child')));
    await t.pumpAndSettle();
    final level = find.byKey(const Key('level'));
    await t.scrollUntilVisible(
      level,
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('profile-form')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    for (final l in ['Pre-A1', 'A1', 'A2', 'B1']) {
      expect(find.descendant(of: level, matching: find.text(l)), findsOne);
    }
    await shot('1-levels');
    await t.pageBack();
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('exit-parent')));
    await t.pumpAndSettle();

    // 2. The B1 child's first card: forms on the back, Vietnamese on tap.
    await t.tap(find.byKey(Key('profile-$kid')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('start-session')));
    await t.pumpAndSettle();
    expect(find.text('achieve'), findsOneWidget);
    await shot('2-b1-front');
    await t.tap(find.byKey(const Key('flash-card')));
    await t.pumpAndSettle();
    expect(find.textContaining('past: achieved'), findsOneWidget);
    expect(find.byKey(const Key('translation')), findsNothing);
    await shot('3-b1-back');
    await t.tap(find.byKey(const Key('show-translation')));
    await t.pumpAndSettle();
    expect(find.text('đạt được'), findsOneWidget);
    await shot('4-b1-vietnamese');

    await t.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
}
