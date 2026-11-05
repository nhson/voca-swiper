import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/quiz/quiz_builder.dart';
import '../../data/repositories/word_repository.dart';
import '../../ui/chunky_button.dart';
import '../../ui/kid_look.dart';
import '../../ui/mascot.dart';
import '../../ui/sfx.dart';

/// One quiz question (feat-012). Shows the question, takes one answer,
/// shows right/wrong for a moment, then calls [onAnswered].
class QuizView extends StatefulWidget {
  const QuizView({
    super.key,
    required this.item,
    required this.number,
    required this.total,
    required this.cardFor,
    required this.look,
    required this.showWords,
    required this.say,
    required this.sfx,
    required this.onAnswered,
    required this.onQuit,
  });

  final QuizItem item;
  final int number;
  final int total;
  final WordCard? Function(String wordId) cardFor;
  final KidLook look;

  /// Older children also see the written word on picture questions.
  final bool showWords;
  final void Function(String text) say;
  final Sfx sfx;

  /// The answer (a word id, or the spelled letters). Called once the
  /// right/wrong feedback has been shown.
  final Future<void> Function(String given) onAnswered;
  final VoidCallback onQuit;

  /// How long the feedback stays before the next question.
  static const rightPause = Duration(milliseconds: 900);
  static const wrongPause = Duration(milliseconds: 1800);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  String? _given;

  /// Indexes into [QuizItem.tiles], in the order placed.
  final List<int> _placed = [];

  QuizItem get _item => widget.item;
  WordCard? get _card => widget.cardFor(_item.wordId);
  bool get _locked => _given != null;
  bool get _right => _given != null && _item.isCorrect(_given!);

  @override
  void initState() {
    super.initState();
    _sayWord();
  }

  void _sayWord() {
    final c = _card;
    if (c != null) widget.say(c.word.word);
  }

  Future<void> _answer(String given) async {
    if (_locked) return;
    setState(() => _given = given);
    final ok = _item.isCorrect(given);
    widget.sfx.play(ok ? Sound.knew : Sound.notYet);
    if (ok) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
      // Hear the right word again while it is shown.
      _sayWord();
    }
    await Future<void>.delayed(ok ? QuizView.rightPause : QuizView.wrongPause);
    if (mounted) await widget.onAnswered(given);
  }

  void _placeTile(int i) {
    if (_locked || _placed.contains(i)) return;
    widget.sfx.play(Sound.tap);
    setState(() => _placed.add(i));
    if (_placed.length == _item.answer.length) {
      _answer(_placed.map((t) => _item.tiles[t]).join());
    }
  }

  void _removeSlot(int slot) {
    if (_locked || slot >= _placed.length) return;
    setState(() => _placed.removeAt(slot));
  }

  @override
  Widget build(BuildContext context) {
    final mood = !_locked
        ? MascotMood.happy
        : _right
        ? MascotMood.cheer
        : MascotMood.encourage;
    return Column(
      key: const Key('quiz'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
          child: Row(
            children: [
              RoundIconButton(
                key: const Key('quit-session'),
                tooltip: 'Stop',
                icon: Icons.close_rounded,
                onPressed: widget.onQuit,
              ),
              const SizedBox(width: 4),
              Mascot(mood: mood, size: 60),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Quiz time!',
                  style: TextStyle(
                    fontFamily: 'Baloo2',
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: KidColors.ink.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              _Pill(
                key: const Key('quiz-count'),
                text: '${widget.number}/${widget.total}',
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: [
                _prompt(context),
                const SizedBox(height: 18),
                _answers(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _speakButton() => RoundIconButton(
    key: const Key('quiz-speak'),
    tooltip: 'Hear the word',
    icon: Icons.volume_up_rounded,
    onPressed: _sayWord,
  );

  Widget _prompt(BuildContext context) {
    final c = _card;
    final word = c?.word.word ?? _item.wordId;
    final (String title, Widget? big) = switch (_item.kind) {
      QuizKind.pickPicture => (
        'Which one is…',
        widget.showWords ? _WordText(word) : null,
      ),
      QuizKind.chooseMeaning => ('What does it mean?', _WordText(word)),
      QuizKind.spell => (
        'Spell the word!',
        Text(c?.word.emoji ?? '❓', style: const TextStyle(fontSize: 84)),
      ),
    };
    return _Paper(
      child: Column(
        children: [
          Text(
            title,
            key: Key('quiz-kind-${_item.kind.name}'),
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: KidColors.inkSoft,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (big != null) ...[
                Flexible(child: big),
                const SizedBox(width: 12),
              ],
              _speakButton(),
            ],
          ),
          if (_item.kind == QuizKind.spell) ...[
            const SizedBox(height: 14),
            _slots(),
          ],
        ],
      ),
    );
  }

  /// Green for the right answer once answered; red for a wrong pick.
  Color? _markFor(String optionId) {
    if (!_locked) return null;
    if (optionId == _item.wordId) return KidColors.knew;
    if (optionId == _given) return KidColors.notYet;
    return null;
  }

  Widget _answers(BuildContext context) {
    switch (_item.kind) {
      case QuizKind.pickPicture:
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          children: [
            for (final id in _item.options)
              _PictureOption(
                key: Key('quiz-option-$id'),
                card: widget.cardFor(id),
                wordId: id,
                mark: _markFor(id),
                dimmed: _locked && _markFor(id) == null,
                onTap: () => _answer(id),
              ),
          ],
        );
      case QuizKind.chooseMeaning:
        return Column(
          children: [
            for (final id in _item.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ChunkyButton(
                    key: Key('quiz-option-$id'),
                    color:
                        _markFor(id) ??
                        (_locked
                            ? const Color(0xFFB9B2CC)
                            : widget.look.accent),
                    semanticLabel: widget.cardFor(id)?.translation ?? id,
                    onPressed: () => _answer(id),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Text(widget.cardFor(id)?.translation ?? '?'),
                  ),
                ),
              ),
          ],
        );
      case QuizKind.spell:
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < _item.tiles.length; i++)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _placed.contains(i) ? 0.25 : 1,
                child: ChunkyButton(
                  key: Key('quiz-tile-$i'),
                  color: widget.look.accent,
                  size: 58,
                  semanticLabel: _item.tiles[i],
                  onPressed: _placed.contains(i) || _locked
                      ? null
                      : () => _placeTile(i),
                  padding: EdgeInsets.zero,
                  child: Text(_item.tiles[i]),
                ),
              ),
          ],
        );
    }
  }

  Widget _slots() {
    final n = _item.answer.length;
    final showAnswer = _locked && !_right;
    final color = !_locked
        ? KidColors.inkSoft
        : _right
        ? KidColors.knew
        : KidColors.notYet;
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var s = 0; s < n; s++)
              GestureDetector(
                key: Key('quiz-slot-$s'),
                onTap: () => _removeSlot(s),
                child: Container(
                  width: 46,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: s < _placed.length
                        ? color.withValues(alpha: 0.12)
                        : const Color(0xFFF4F1FA),
                    border: Border(bottom: BorderSide(color: color, width: 4)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    s < _placed.length ? _item.tiles[_placed[s]] : '',
                    style: const TextStyle(
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      color: KidColors.ink,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (showAnswer) ...[
          const SizedBox(height: 8),
          Text(
            _item.answer,
            key: const Key('quiz-correct-spelling'),
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w800,
              fontSize: 30,
              letterSpacing: 6,
              color: KidColors.knew,
            ),
          ),
        ],
      ],
    );
  }
}

class _WordText extends StatelessWidget {
  const _WordText(this.word);

  final String word;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      word,
      key: const Key('quiz-word'),
      style: const TextStyle(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.w800,
        fontSize: 48,
        color: KidColors.ink,
      ),
    ),
  );
}

class _Paper extends StatelessWidget {
  const _Paper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: KidColors.ink.withValues(alpha: 0.14),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Baloo2',
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: KidColors.ink,
      ),
    ),
  );
}

class _PictureOption extends StatelessWidget {
  const _PictureOption({
    super.key,
    required this.card,
    required this.wordId,
    required this.mark,
    required this.dimmed,
    required this.onTap,
  });

  final WordCard? card;
  final String wordId;
  final Color? mark;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: card?.word.word ?? wordId,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dimmed ? 0.45 : 1,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: mark == null
                        ? Colors.white
                        : Color.alphaBlend(
                            mark!.withValues(alpha: 0.18),
                            Colors.white,
                          ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: mark ?? Colors.white,
                      width: mark == null ? 4 : 7,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (mark ?? KidColors.ink).withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: LayoutBuilder(
                    builder: (context, box) => Container(
                      width: box.maxWidth * 0.72,
                      height: box.maxWidth * 0.72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: KidColors.pastelFor(wordId),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        card?.word.emoji ?? '❓',
                        style: TextStyle(fontSize: box.maxWidth * 0.38),
                      ),
                    ),
                  ),
                ),
              ),
              if (mark != null)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    key: Key(
                      mark == KidColors.knew
                          ? 'quiz-mark-right'
                          : 'quiz-mark-wrong',
                    ),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: mark,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(
                      mark == KidColors.knew
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
