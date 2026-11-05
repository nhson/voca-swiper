import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/ui/pin_boxes.dart';

void main() {
  Future<(TextEditingController, List<String>)> pump(WidgetTester t) async {
    final c = TextEditingController();
    final done = <String>[];
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PinBoxes(
              key: const Key('pin'),
              controller: c,
              onCompleted: done.add,
            ),
          ),
        ),
      ),
    );
    return (c, done);
  }

  Finder input() => find.descendant(
    of: find.byKey(const Key('pin')),
    matching: find.byType(EditableText),
  );

  testWidgets('six boxes, filled ones show a dot, digits hidden', (t) async {
    final (c, _) = await pump(t);
    for (var i = 0; i < 6; i++) {
      expect(find.byKey(Key('pin-box-$i')), findsOneWidget);
    }
    expect(find.byKey(const Key('pin-box-6')), findsNothing);

    await t.enterText(input(), '123');
    await t.pump();
    expect(c.text, '123');
    expect(find.byKey(const Key('pin-dot')), findsNWidgets(3));
    expect(find.text('1'), findsNothing, reason: 'digits are never shown');
  });

  testWidgets('only digits, at most 6, completes once full', (t) async {
    final (c, done) = await pump(t);
    await t.enterText(input(), '12a4');
    await t.pump();
    expect(c.text, '124');
    expect(done, isEmpty);

    await t.enterText(input(), '12345678');
    await t.pump();
    expect(c.text, '123456');
    expect(done, ['123456']);
  });

  testWidgets('tapping the boxes opens the keyboard', (t) async {
    await pump(t);
    await t.tap(find.byKey(const Key('pin-box-0')));
    await t.pump();
    expect(t.testTextInput.isVisible, isTrue);
  });
}
