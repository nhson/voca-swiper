// Renders the app icon (Sunny on the sky) to build/icon/icon-1024.png.
// Drawn in code like the rest of the app, so there is no third-party license.
//   flutter test tool/make_icon_test.dart && tool/make_icons.sh
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_swiper/ui/kid_look.dart';
import 'package:voca_swiper/ui/mascot.dart';

const _size = 1024.0;

void main() {
  testWidgets('render app icon', (t) async {
    t.view.physicalSize = const Size(_size, _size);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final key = GlobalKey();
    await t.pumpWidget(
      ProviderScope(
        overrides: [ambientMotionProvider.overrideWithValue(false)],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [KidLook.sunny.skyTop, KidLook.sunny.skyBottom],
                ),
              ),
              alignment: Alignment.center,
              // Big enough to read on a home screen, inside Android's
              // adaptive-icon safe zone (the middle ~66%).
              child: const Mascot(size: _size * 0.78),
            ),
          ),
        ),
      ),
    );
    await t.pump();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await t.runAsync(() async {
      final image = await boundary.toImage();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final out = File('build/icon/icon-1024.png')..createSync(recursive: true);
      out.writeAsBytesSync(png!.buffer.asUint8List());
    });
  });
}
