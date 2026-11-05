import 'package:flutter/widgets.dart';

/// Padding that keeps a parent-area list at a readable width on tablets
/// (content centred, at most [maxWidth] wide).
EdgeInsets readablePadding(
  BuildContext context, {
  double side = 16,
  double top = 8,
  double bottom = 32,
  double maxWidth = 680,
}) {
  final w = MediaQuery.sizeOf(context).width;
  final inset = w > maxWidth + side * 2 ? (w - maxWidth) / 2 : side;
  return EdgeInsets.fromLTRB(inset, top, inset, bottom);
}
