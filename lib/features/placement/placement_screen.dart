import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../ui/chunky_button.dart';
import '../../ui/kid_look.dart';
import '../../ui/kid_screen.dart';
import '../../ui/mascot.dart';
import '../../ui/sfx.dart';
import '../session/quiz_view.dart';
import '../session/speaker.dart';
import 'placement_controller.dart';

/// Onboarding for a new child (feat-015): "do you know this word?", a
/// picture check now and then, favourite themes, then the first 5 easy
/// words.
class PlacementScreen extends ConsumerStatefulWidget {
  const PlacementScreen({super.key, required this.profileId});

  final int profileId;

  @override
  ConsumerState<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends ConsumerState<PlacementScreen> {
  late final PlacementController _c = PlacementController(
    profileId: widget.profileId,
    words: ref.read(wordRepositoryProvider),
    profiles: ref.read(profileRepositoryProvider),
    clock: ref.read(clockProvider),
  );
  late final Speaker _speaker = ref.read(speakerProvider);
  late final Sfx _sfx = ref.read(sfxProvider);
  String? _spokenFor;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChange);
    _c.start();
  }

  @override
  void dispose() {
    _c.removeListener(_onChange);
    _c.dispose();
    _speaker.stop();
    super.dispose();
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    final card = _c.phase == PlacementPhase.word ? _c.currentCard : null;
    final key = card == null ? null : '${_c.test!.answered}:${card.word.id}';
    if (key != null && key != _spokenFor) {
      _spokenFor = key;
      _speaker.say(card!.word.word);
    }
  }

  void _answer({required bool known}) {
    _sfx.play(known ? Sound.knew : Sound.tap);
    HapticFeedback.selectionClick();
    _c.answer(known: known);
  }

  Future<void> _finish() async {
    final words = await _c.finish();
    if (!mounted) return;
    if (words.isEmpty) {
      context.pop();
    } else {
      context.pushReplacement('/kid/${widget.profileId}/session', extra: words);
    }
  }

  @override
  Widget build(BuildContext context) {
    final look = KidLook.forAge(_c.profile?.age);
    return KidScreen(
      look: look,
      sun: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: switch (_c.phase) {
            PlacementPhase.loading || PlacementPhase.done => const Center(
              child: CircularProgressIndicator(),
            ),
            PlacementPhase.intro => _Intro(
              look: look,
              name: _c.profile!.name,
              onStart: _c.begin,
              onQuit: () => context.pop(),
            ),
            PlacementPhase.word => _WordQuestion(
              look: look,
              word: _c.currentCard?.word.word ?? '',
              number: _c.test!.answered + 1,
              total: _c.test!.total,
              onSay: () => _speaker.say(_c.currentCard?.word.word ?? ''),
              onAnswer: _answer,
              onQuit: () => context.pop(),
            ),
            PlacementPhase.check => QuizView(
              key: ValueKey('check-${_c.check!.wordId}'),
              title: 'Show me!',
              item: _c.check!,
              number: _c.test!.answered,
              total: _c.test!.total,
              cardFor: _c.cardFor,
              look: look,
              showWords: (_c.profile?.age ?? 0) >= 7,
              say: _speaker.say,
              sfx: _sfx,
              onAnswered: (given) async => _c.answerCheck(given),
              onQuit: () => context.pop(),
            ),
            PlacementPhase.themes => _ThemePicker(
              look: look,
              controller: _c,
              onDone: _finish,
            ),
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onQuit, this.trailing});

  final VoidCallback onQuit;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
    child: Row(
      children: [
        RoundIconButton(
          key: const Key('placement-quit'),
          tooltip: 'Stop',
          icon: Icons.close_rounded,
          onPressed: onQuit,
        ),
        const Spacer(),
        ?trailing,
      ],
    ),
  );
}

class _Intro extends StatelessWidget {
  const _Intro({
    required this.look,
    required this.name,
    required this.onStart,
    required this.onQuit,
  });

  final KidLook look;
  final String name;
  final VoidCallback onStart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        _TopBar(onQuit: onQuit),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hi $name!',
                    textAlign: TextAlign.center,
                    style: text.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: SpeechBubble(
                      child: Text(
                        "Let's find the words you know! I'll say a word. "
                        'Do you know it?',
                        key: const Key('placement-intro'),
                        textAlign: TextAlign.center,
                        style: text.titleLarge?.copyWith(fontSize: 19),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Mascot(size: 170),
                  const SizedBox(height: 20),
                  ChunkyButton(
                    key: const Key('placement-start'),
                    color: look.accent,
                    semanticLabel: "Let's go",
                    onPressed: onStart,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 44,
                      vertical: 14,
                    ),
                    child: const Text(
                      "Let's go!",
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WordQuestion extends StatelessWidget {
  const _WordQuestion({
    required this.look,
    required this.word,
    required this.number,
    required this.total,
    required this.onSay,
    required this.onAnswer,
    required this.onQuit,
  });

  final KidLook look;
  final String word;
  final int number;
  final int total;
  final VoidCallback onSay;
  final void Function({required bool known}) onAnswer;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).shortestSide >= 600 ? 1.3 : 1.0;
    return Column(
      key: const Key('placement-word'),
      children: [
        _TopBar(onQuit: onQuit, trailing: _CountPill('$number/$total')),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
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
                    child: Column(
                      children: [
                        const Text(
                          'Do you know this word?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Baloo2',
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: KidColors.inkSoft,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            word,
                            key: const Key('placement-word-text'),
                            style: TextStyle(
                              fontFamily: 'Baloo2',
                              fontWeight: FontWeight.w800,
                              fontSize: 54 * look.wordScale * scale,
                              color: KidColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        RoundIconButton(
                          key: const Key('placement-speak'),
                          tooltip: 'Hear the word',
                          icon: Icons.volume_up_rounded,
                          onPressed: onSay,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: ChunkyButton(
                          key: const Key('placement-no'),
                          color: KidColors.notYet,
                          semanticLabel: 'Not yet',
                          onPressed: () => onAnswer(known: false),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const Text('🤔 Not yet'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ChunkyButton(
                          key: const Key('placement-yes'),
                          color: KidColors.knew,
                          semanticLabel: 'I know it',
                          onPressed: () => onAnswer(known: true),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const Text('👍 I know it'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('placement-count'),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
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

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({
    required this.look,
    required this.controller,
    required this.onDone,
  });

  final KidLook look;
  final PlacementController controller;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final text = Theme.of(context).textTheme;
    return Column(
      key: const Key('placement-themes'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    const Mascot(mood: MascotMood.cheer, size: 90),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SpeechBubble(
                        child: Text(
                          'Great job! What do you like? Pick up to 3.',
                          textAlign: TextAlign.center,
                          style: text.titleLarge?.copyWith(fontSize: 19),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.extent(
                  maxCrossAxisExtent: 170,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    for (final t in c.themes)
                      _ThemeTile(
                        key: Key('theme-${t.id}'),
                        emoji: t.emoji,
                        label: t.label,
                        selected: c.picked.contains(t.id),
                        color: look.accent,
                        onTap: () => c.toggleTheme(t.id),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ChunkyButton(
            key: const Key('themes-done'),
            color: look.accent,
            semanticLabel: 'Done',
            onPressed: onDone,
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
            child: const Text('Done!', style: TextStyle(fontSize: 26)),
          ),
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    label: label,
    child: Material(
      color: selected ? Color.lerp(Colors.white, color, 0.2) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: selected ? color : Colors.transparent,
          width: 4,
        ),
      ),
      elevation: selected ? 0 : 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Baloo2',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: KidColors.ink,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: KidColors.knew),
            ],
          ),
        ),
      ),
    ),
  );
}
