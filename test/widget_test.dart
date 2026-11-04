import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/app/app.dart';

void main() {
  testWidgets('app boots to the home screen', (tester) async {
    await tester.pumpWidget(const VocaSwiperApp());
    expect(find.text('Voca Swiper'), findsOneWidget);
  });
}
