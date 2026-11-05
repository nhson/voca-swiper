import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A PIN entered into separate boxes, one digit each (default 6).
///
/// A single invisible text field underneath does the real input, so the
/// number keyboard, backspace and paste behave normally; the boxes on top
/// only draw what has been typed (a dot, never the digit).
class PinBoxes extends StatefulWidget {
  const PinBoxes({
    super.key,
    required this.controller,
    this.length = 6,
    this.focusNode,
    this.autofocus = false,
    this.label,
    this.errorText,
    this.onChanged,
    this.onCompleted,
  });

  final TextEditingController controller;
  final int length;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? label;
  final String? errorText;

  /// Called on every edit (e.g. to clear an error once typing resumes).
  final ValueChanged<String>? onChanged;

  /// Called with the PIN when the last box is filled.
  final ValueChanged<String>? onCompleted;

  @override
  State<PinBoxes> createState() => _PinBoxesState();
}

class _PinBoxesState extends State<PinBoxes> {
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
    _focus.addListener(_changed);
  }

  @override
  void didUpdateWidget(PinBoxes old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_changed);
      _focus.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _focus.removeListener(_changed);
    _ownFocus?.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final filled = widget.controller.text.length;
    final hasError = widget.errorText != null;
    final focused = _focus.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: text.titleSmall),
          const SizedBox(height: 8),
        ],
        LayoutBuilder(
          builder: (context, c) {
            const gap = 10.0;
            final side =
                ((c.maxWidth - gap * (widget.length - 1)) / widget.length)
                    .clamp(36.0, 56.0);
            return Center(
              child: Stack(
                children: [
                  // The real input, invisible, covering the boxes: a tap on
                  // any box focuses it and opens the number keyboard.
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focus,
                        autofocus: widget.autofocus,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        showCursor: false,
                        enableInteractiveSelection: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(widget.length),
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        onChanged: (v) {
                          widget.onChanged?.call(v);
                          if (v.length == widget.length) {
                            widget.onCompleted?.call(v);
                          }
                        },
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < widget.length; i++) ...[
                          if (i > 0) const SizedBox(width: gap),
                          _Box(
                            key: Key('pin-box-$i'),
                            side: side,
                            filled: i < filled,
                            current:
                                focused &&
                                (i == filled ||
                                    (filled == widget.length &&
                                        i == widget.length - 1)),
                            error: hasError,
                            scheme: scheme,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.error),
          ),
        ],
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    super.key,
    required this.side,
    required this.filled,
    required this.current,
    required this.error,
    required this.scheme,
  });

  final double side;
  final bool filled;
  final bool current;
  final bool error;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final border = error
        ? scheme.error
        : current
        ? scheme.primary
        : filled
        ? scheme.primary.withValues(alpha: 0.5)
        : scheme.outlineVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: side,
      height: side * 1.15,
      decoration: BoxDecoration(
        color: filled ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
        border: Border.all(color: border, width: current ? 2.5 : 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: filled
          ? Container(
              key: const Key('pin-dot'),
              width: side * 0.26,
              height: side * 0.26,
              decoration: BoxDecoration(
                color: scheme.onSurface,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
