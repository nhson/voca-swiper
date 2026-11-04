import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/app/app.dart';
import 'package:voca_swiper/app/providers.dart';

import 'support/test_db.dart';

void main() {
  testWidgets('app boots and shows the imported word bank', (tester) async {
    final db = await seededDb([w('cat'), w('dog')]);
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const VocaSwiperApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Voca Swiper'), findsOneWidget);
    expect(find.text('2 words ready'), findsOneWidget);
  });
}
