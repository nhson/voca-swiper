import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/session/session_summary.dart';
import '../../core/srs/word_state.dart';
import '../../data/repositories/word_repository.dart';
import '../../ui/chunky_button.dart';
import '../../ui/confetti.dart';
import '../../ui/kid_look.dart';
import '../../ui/kid_screen.dart';
import '../../ui/mascot.dart';
import '../../ui/sfx.dart';
import 'flash_card.dart';
import 'quiz_view.dart';
import 'session_controller.dart';
import 'speaker.dart';
import 'swipe_card.dart';

const _knewColor = KidColors.knew;
const _missColor = KidColors.notYet;
const _almostColor = KidColors.almost;

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, required this.profileId, this.firstWords});

  final int profileId;

  /// New words for the first mini-session after placement (feat-015).
  final List<String>? firstWords;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  late final SessionController _c = SessionController(
    profileId: widget.profileId,
    words: ref.read(wordRepositoryProvider),
    progress: ref.read(progressRepositoryProvider),
    profiles: ref.read(profileRepositoryProvider),
    clock: ref.read(clockProvider),
    firstWords: widget.firstWords,
  );
  late final Speaker _speaker = ref.read(speakerProvider);
  late final Sfx _sfx = ref.read(sfxProvider);
  final _swipeKey = GlobalKey<SwipeCardState>();
  String? _spokenFor;
  MascotMood _mood = MascotMood.happy;
  Timer? _moodReset;
  bool _cheered = false;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChange);
    _c.start();
  }

  @override
  void dispose() {
    _moodReset?.cancel();
    _c.removeListener(_onChange);
    _c.dispose();
    _speaker.stop();
    super.dispose();
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    if (_c.isFinished && !_cheered && (_c.summary?.answered ?? 0) > 0) {
      _cheered = true;
      _sfx.play(Sound.cheer);
    }
    // Say each new card's word once when it appears.
    final s = _c.session;
    final card = _c.currentCard;
    final key = card == null ? null : '${s!.seen.length}:${card.word.id}';
    if (key != null && key != _spokenFor) {
      _spokenFor = key;
      _speaker.say(card!.word.word);
    }
  }

  bool get _knownRight => _c.profile?.swipeKnownRight ?? true;

  AnswerQuality _qualityFor(SwipeDirection d) => switch (d) {
    SwipeDirection.up => AnswerQuality.almost,
    SwipeDirection.right =>
      _knownRight ? AnswerQuality.knew : AnswerQuality.didntKnow,
    SwipeDirection.left =>
      _knownRight ? AnswerQuality.didntKnow : AnswerQuality.knew,
  };

  ({String label, Color color}) _hint(SwipeDirection d) =>
      switch (_qualityFor(d)) {
        AnswerQuality.knew => (label: 'Knew it!', color: _knewColor),
        AnswerQuality.almost => (label: 'Almost', color: _almostColor),
        _ => (label: 'Not yet', color: _missColor),
      };

  SwipeDirection _directionFor(AnswerQuality q) => switch (q) {
    AnswerQuality.almost => SwipeDirection.up,
    AnswerQuality.knew =>
      _knownRight ? SwipeDirection.right : SwipeDirection.left,
    _ => _knownRight ? SwipeDirection.left : SwipeDirection.right,
  };

  Future<void> _press(AnswerQuality q) async {
    final card = _swipeKey.currentState;
    if (card != null) {
      await card.flyOut(_directionFor(q));
    } else {
      await _answer(q);
    }
  }

  /// Sunny and a short sound react to each answer, then the next card.
  Future<void> _answer(AnswerQuality q) {
    final (mood, sound) = switch (q) {
      AnswerQuality.knew => (MascotMood.cheer, Sound.knew),
      AnswerQuality.almost => (MascotMood.happy, Sound.almost),
      _ => (MascotMood.encourage, Sound.notYet),
    };
    _sfx.play(sound);
    if (q == AnswerQuality.knew) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    _moodReset?.cancel();
    setState(() => _mood = mood);
    _moodReset = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _mood = MascotMood.happy);
    });
    return _c.answer(q);
  }

  Future<void> _quit() async {
    await _c.quit();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final look = KidLook.forAge(_c.profile?.age);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _quit();
      },
      child: KidScreen(
        look: look,
        sun: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _body(context, look),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, KidLook look) {
    if (_c.isLoading) return const Center(child: CircularProgressIndicator());
    if (_c.isFinished) {
      return SessionSummaryView(
        summary: _c.summary!,
        practiced: _c.practicedCards,
        look: look,
        onDone: () => Navigator.of(context).pop(),
      );
    }
    if (_c.inQuiz) {
      return QuizView(
        key: ValueKey('quiz-${_c.quizNumber}'),
        item: _c.currentQuiz!,
        number: _c.quizNumber,
        total: _c.quiz.length,
        cardFor: _c.cardFor,
        look: look,
        showWords: (_c.profile?.age ?? 0) >= 7,
        say: _speaker.say,
        sfx: _sfx,
        onAnswered: _c.answerQuiz,
        onQuit: _quit,
      );
    }
    final s = _c.session!;
    if (s.isFinished) {
      // Getting the quiz ready.
      return const Center(child: CircularProgressIndicator());
    }
    final card = _c.currentCard!;
    final profile = _c.profile!;
    final cardKey = '${s.seen.length}:${card.word.id}';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
          child: Row(
            children: [
              RoundIconButton(
                key: const Key('quit-session'),
                tooltip: 'Stop',
                icon: Icons.close_rounded,
                onPressed: _quit,
              ),
              const SizedBox(width: 4),
              Mascot(mood: _mood, size: 60),
              Expanded(
                child: _ProgressTrack(
                  value: s.total == 0 ? 0 : s.seen.length / s.total,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${s.seen.length + 1}/${s.total}',
                  key: const Key('session-count'),
                  style: const TextStyle(
                    fontFamily: 'Baloo2',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: KidColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: s.current!.isRetry
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KidColors.almost,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'One more try! 💪',
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
            // Keep a card shape: on tall screens the card would otherwise
            // stretch into a thin strip.
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.72,
                child: SwipeCard(
                  key: _swipeKey,
                  hintFor: _hint,
                  onSwiped: (d) => _answer(_qualityFor(d)),
                  child: _CardEntrance(
                    key: ValueKey(cardKey),
                    child: FlashCard(
                      key: ValueKey(cardKey),
                      card: card,
                      look: look,
                      translationMode: profile.translationMode,
                      onSpeak: () => _speaker.say(card.word.word),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final dir in [
                SwipeDirection.left,
                SwipeDirection.up,
                SwipeDirection.right,
              ])
                _AnswerButton(
                  quality: _qualityFor(dir),
                  onPressed: () => _press(_qualityFor(dir)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Each new card pops in with a little bounce.
class _CardEntrance extends StatelessWidget {
  const _CardEntrance({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!flourishes(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.86 + 0.14 * t, child: child),
      ),
      child: child,
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, box) => Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: box.maxWidth * value.clamp(0.0, 1.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5BE3A8), KidColors.knew],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({required this.quality, required this.onPressed});

  final AnswerQuality quality;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color, key) = switch (quality) {
      AnswerQuality.knew => (
        Icons.check_rounded,
        'Knew it',
        _knewColor,
        'knew',
      ),
      AnswerQuality.almost => (
        Icons.more_horiz_rounded,
        'Almost',
        _almostColor,
        'almost',
      ),
      _ => (Icons.close_rounded, 'Not yet', _missColor, 'not-yet'),
    };
    final big = quality != AnswerQuality.almost;
    final size = big ? 78.0 : 62.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChunkyButton(
          key: Key('answer-$key'),
          color: color,
          circle: true,
          size: size,
          semanticLabel: label,
          onPressed: onPressed,
          child: Icon(icon, size: size * 0.55),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Baloo2',
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: Colors.white,
            shadows: [Shadow(color: Color(0x55000000), blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}

class SessionSummaryView extends StatelessWidget {
  const SessionSummaryView({
    super.key,
    required this.summary,
    required this.onDone,
    this.practiced = const [],
    this.look = KidLook.sunny,
  });

  final SessionSummary summary;
  final List<WordCard> practiced;
  final KidLook look;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final nothingToDo = summary.answered == 0;
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: KidColors.ink.withValues(alpha: 0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (nothingToDo) ...[
                    const Mascot(mood: MascotMood.sleepy, size: 140),
                    Text(
                      'All done for today!',
                      key: const Key('all-done'),
                      textAlign: TextAlign.center,
                      style: text.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Come back tomorrow for more words.',
                      textAlign: TextAlign.center,
                      style: text.titleMedium?.copyWith(
                        color: KidColors.inkSoft,
                      ),
                    ),
                  ] else ...[
                    const Mascot(mood: MascotMood.cheer, size: 130),
                    _Stars(key: const Key('stars'), count: summary.stars),
                    const SizedBox(height: 6),
                    Text(
                      _cheer(summary.stars),
                      style: text.displaySmall?.copyWith(color: look.accent),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      children: [
                        if (summary.newLearned > 0)
                          Text(
                            '${summary.newLearned} new '
                            '${summary.newLearned == 1 ? 'word' : 'words'}',
                            key: const Key('summary-new'),
                            style: text.titleLarge,
                          ),
                        if (summary.reviewed > 0)
                          Text(
                            '${summary.reviewed} '
                            '${summary.reviewed == 1 ? 'word' : 'words'} '
                            'reviewed',
                            key: const Key('summary-reviewed'),
                            style: text.titleLarge,
                          ),
                      ],
                    ),
                    if (summary.quizAsked > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Quiz: ${summary.quizCorrect} of '
                          '${summary.quizAsked} right',
                          key: const Key('summary-quiz'),
                          style: text.titleMedium?.copyWith(
                            color: KidColors.inkSoft,
                          ),
                        ),
                      ),
                    if (practiced.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        key: const Key('practiced'),
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in practiced)
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: KidColors.pastelFor(c.word.id),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                c.word.emoji ??
                                    c.word.word.characters.first.toUpperCase(),
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  ChunkyButton(
                    key: const Key('session-done'),
                    color: look.accent,
                    semanticLabel: 'Done',
                    onPressed: onDone,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 12,
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!nothingToDo) const Positioned.fill(child: ConfettiBurst()),
      ],
    );
  }

  static String _cheer(int stars) => switch (stars) {
    3 => 'Amazing!',
    2 => 'Great job!',
    _ => 'Good try!',
  };
}

/// Three stars that pop in one after another; earned ones are gold.
class _Stars extends StatelessWidget {
  const _Stars({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final animate = flourishes(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.fromLTRB(4, i == 1 ? 0 : 14, 4, 0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: animate ? 0 : 1, end: 1),
              duration: Duration(milliseconds: 500 + i * 220),
              curve: Interval(i * 0.3, 1, curve: Curves.elasticOut),
              builder: (context, t, child) =>
                  Transform.scale(scale: t, child: child),
              child: Icon(
                Icons.star_rounded,
                size: i == 1 ? 76 : 60,
                color: i < count ? KidColors.star : const Color(0xFFE6E1F0),
                shadows: i < count
                    ? const [Shadow(color: Color(0x55FFA000), blurRadius: 12)]
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
