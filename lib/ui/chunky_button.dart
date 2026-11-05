import 'package:flutter/material.dart';

import 'kid_look.dart';

/// A big, tactile "sticker" button with a darker lip that presses down.
/// Disabled when [onPressed] is null.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.onPressed,
    required this.color,
    required this.child,
    this.circle = false,
    this.size,
    this.padding = const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
    this.semanticLabel,
  });

  final VoidCallback? onPressed;
  final Color color;
  final Widget child;
  final bool circle;

  /// Fixed size (circle buttons).
  final double? size;
  final EdgeInsets padding;
  final String? semanticLabel;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;
  static const _lip = 6.0;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final face = enabled ? widget.color : const Color(0xFFD9D5E3);
    final lip = KidColors.shade(face, 0.16);
    final shape = widget.circle
        ? const CircleBorder()
        : const StadiumBorder() as ShapeBorder;
    final pressed = _down && enabled;
    final content = DefaultTextStyle.merge(
      style: TextStyle(
        fontFamily: 'Baloo2',
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.1,
        color: enabled ? Colors.white : const Color(0xFF9A93AD),
      ),
      child: IconTheme.merge(
        data: IconThemeData(
          color: enabled ? Colors.white : const Color(0xFF9A93AD),
        ),
        // Shrink a long label instead of overflowing on small screens.
        child: FittedBox(fit: BoxFit.scaleDown, child: widget.child),
      ),
    );
    Widget faceBox = Container(
      width: widget.size,
      height: widget.size,
      padding: widget.circle ? EdgeInsets.zero : widget.padding,
      alignment: Alignment.center,
      decoration: ShapeDecoration(color: face, shape: shape),
      child: content,
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          margin: EdgeInsets.only(top: pressed ? _lip : 0),
          padding: EdgeInsets.only(bottom: pressed ? 0 : _lip),
          decoration: ShapeDecoration(
            color: lip,
            shape: shape,
            shadows: [
              BoxShadow(
                color: KidColors.ink.withValues(alpha: enabled ? 0.18 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: faceBox,
        ),
      ),
    );
  }
}

/// A small round white button for back/close on child screens.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: ChunkyButton(
      onPressed: onPressed,
      color: Colors.white,
      circle: true,
      size: 48,
      semanticLabel: tooltip,
      child: Icon(icon, color: KidColors.ink, size: 28),
    ),
  );
}
