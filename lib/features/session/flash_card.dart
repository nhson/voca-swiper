import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/word_repository.dart';
import '../../ui/chunky_button.dart';
import '../../ui/kid_look.dart';

/// A word card. Front: picture + word. Tap to flip. Back: meaning, example,
/// forms and (per [translationMode]) the native-language translation.
class FlashCard extends StatefulWidget {
  const FlashCard({
    super.key,
    required this.card,
    required this.translationMode,
    required this.onSpeak,
    this.look = KidLook.sunny,
  });

  final WordCard card;
  final TranslationMode translationMode;
  final VoidCallback onSpeak;
  final KidLook look;

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  bool _showTranslation = false;

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _toggle() =>
      _flip.status == AnimationStatus.completed || _flip.value > 0.5
      ? _flip.reverse()
      : _flip.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('flash-card'),
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _flip,
        builder: (context, _) {
          final angle = _flip.value * math.pi;
          final isBack = _flip.value > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _face(_back(context)),
                  )
                : _face(_front(context)),
          );
        },
      ),
    );
  }

  Color get _tint => KidColors.pastelFor(widget.card.word.id);

  Widget _face(Widget child) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(36),
      border: Border(
        bottom: BorderSide(color: KidColors.shade(_tint, 0.12), width: 8),
      ),
      boxShadow: [
        BoxShadow(
          color: KidColors.ink.withValues(alpha: 0.16),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(padding: const EdgeInsets.all(22), child: child),
  );

  Widget _speakButton({double size = 56}) => ChunkyButton(
    key: const Key('speak'),
    onPressed: widget.onSpeak,
    color: const Color(0xFF4FA9FF),
    circle: true,
    size: size,
    semanticLabel: 'Listen',
    child: Icon(Icons.volume_up_rounded, size: size * 0.55),
  );

  Widget _picture(double size) {
    final emoji = widget.card.word.emoji;
    return emoji == null
        ? Text(
            widget.card.word.word.characters.first.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Baloo2',
              fontSize: size * 0.8,
              fontWeight: FontWeight.w800,
              color: KidColors.shade(_tint, 0.3),
            ),
          )
        : Text(emoji, style: TextStyle(fontSize: size));
  }

  /// The picture sits in a soft coloured circle, like a sticker.
  Widget _pictureWell(double size) => Container(
    width: size * 1.55,
    height: size * 1.55,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: _tint, shape: BoxShape.circle),
    child: _picture(size),
  );

  Widget _front(BuildContext context) {
    final w = widget.card.word;
    final look = widget.look;
    return Column(
      children: [
        const Spacer(),
        Flexible(
          flex: 8,
          child: FittedBox(child: _pictureWell(120 * look.pictureScale)),
        ),
        const SizedBox(height: 12),
        FittedBox(
          child: Text(
            w.word,
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontSize: 64 * look.wordScale),
          ),
        ),
        const SizedBox(height: 8),
        _speakButton(),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.touch_app_rounded,
              size: 18,
              color: KidColors.inkSoft,
            ),
            const SizedBox(width: 4),
            Text(
              'Tap to flip',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: KidColors.inkSoft),
            ),
          ],
        ),
      ],
    );
  }

  Widget _back(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final w = widget.card.word;
    final translation = widget.card.translation;
    final forms = w.forms.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(' · ');
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          // Centre short content vertically; scroll when it is long.
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pictureWell(40),
                  const SizedBox(width: 12),
                  Flexible(child: Text(w.word, style: text.headlineLarge)),
                  const SizedBox(width: 10),
                  _speakButton(size: 46),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(w.partOfSpeech, style: text.labelLarge),
              ),
              const SizedBox(height: 16),
              Text(
                w.definition,
                textAlign: TextAlign.center,
                style: text.titleLarge,
              ),
              const SizedBox(height: 14),
              for (final e in w.examples)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F2FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '“$e”',
                    textAlign: TextAlign.center,
                    style: text.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: KidColors.inkSoft,
                    ),
                  ),
                ),
              if (forms.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  forms,
                  textAlign: TextAlign.center,
                  style: text.bodyLarge?.copyWith(color: KidColors.inkSoft),
                ),
              ],
              if (translation != null &&
                  widget.translationMode != TranslationMode.hidden) ...[
                const SizedBox(height: 16),
                if (widget.translationMode == TranslationMode.always ||
                    _showTranslation)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇻🇳', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            translation,
                            key: const Key('translation'),
                            textAlign: TextAlign.center,
                            style: text.headlineSmall?.copyWith(
                              color: const Color(0xFFE0603A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ActionChip(
                    key: const Key('show-translation'),
                    avatar: const Text('🇻🇳'),
                    label: const Text('Show Vietnamese'),
                    onPressed: () => setState(() => _showTranslation = true),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
