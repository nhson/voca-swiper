import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/word_repository.dart';

/// A word card. Front: picture + word. Tap to flip. Back: meaning, example,
/// forms and (per [translationMode]) the native-language translation.
class FlashCard extends StatefulWidget {
  const FlashCard({
    super.key,
    required this.card,
    required this.translationMode,
    required this.onSpeak,
  });

  final WordCard card;
  final TranslationMode translationMode;
  final VoidCallback onSpeak;

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

  Widget _face(Widget child) => Card(
    elevation: 4,
    shadowColor: Colors.black26,
    child: Padding(padding: const EdgeInsets.all(24), child: child),
  );

  Widget _speakButton() => IconButton.filledTonal(
    key: const Key('speak'),
    iconSize: 32,
    tooltip: 'Listen',
    onPressed: widget.onSpeak,
    icon: const Icon(Icons.volume_up_rounded),
  );

  Widget _picture(double size) {
    final emoji = widget.card.word.emoji;
    return emoji == null
        ? Text(
            widget.card.word.word.characters.first.toUpperCase(),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade300,
            ),
          )
        : Text(emoji, style: TextStyle(fontSize: size));
  }

  Widget _front(BuildContext context) {
    final w = widget.card.word;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        FittedBox(child: _picture(140)),
        const SizedBox(height: 16),
        FittedBox(
          child: Text(
            w.word,
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        _speakButton(),
        const Spacer(),
        Text('Tap to flip', style: Theme.of(context).textTheme.bodySmall),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _picture(56),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      w.word,
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _speakButton(),
                ],
              ),
              Text(w.partOfSpeech, style: text.labelLarge),
              const SizedBox(height: 16),
              Text(
                w.definition,
                textAlign: TextAlign.center,
                style: text.titleLarge,
              ),
              const SizedBox(height: 16),
              for (final e in w.examples)
                Text(
                  '“$e”',
                  textAlign: TextAlign.center,
                  style: text.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              if (forms.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(forms, style: text.bodyLarge),
              ],
              if (translation != null &&
                  widget.translationMode != TranslationMode.hidden) ...[
                const SizedBox(height: 20),
                if (widget.translationMode == TranslationMode.always ||
                    _showTranslation)
                  Text(
                    translation,
                    key: const Key('translation'),
                    textAlign: TextAlign.center,
                    style: text.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
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
