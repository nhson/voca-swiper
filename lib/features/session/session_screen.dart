import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/session/session_summary.dart';
import '../../core/srs/word_state.dart';
import 'flash_card.dart';
import 'session_controller.dart';
import 'speaker.dart';
import 'swipe_card.dart';

const _knewColor = Color(0xFF2E9E5B);
const _missColor = Color(0xFFE0573E);
const _almostColor = Color(0xFFF2A007);

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, required this.profileId});

  final int profileId;

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
  );
  late final Speaker _speaker = ref.read(speakerProvider);
  final _swipeKey = GlobalKey<SwipeCardState>();
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
      await _c.answer(q);
    }
  }

  Future<void> _quit() async {
    await _c.quit();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _quit();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: _body(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_c.isLoading) return const Center(child: CircularProgressIndicator());
    if (_c.isFinished) {
      return SessionSummaryView(
        summary: _c.summary!,
        onDone: () => Navigator.of(context).pop(),
      );
    }
    final s = _c.session!;
    final card = _c.currentCard!;
    final profile = _c.profile!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
          child: Row(
            children: [
              IconButton(
                key: const Key('quit-session'),
                tooltip: 'Stop',
                icon: const Icon(Icons.close_rounded),
                onPressed: _quit,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 12,
                    value: s.total == 0 ? 0 : s.seen.length / s.total,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${s.seen.length + 1}/${s.total}',
                key: const Key('session-count'),
              ),
            ],
          ),
        ),
        if (s.current!.isRetry)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('One more try! 💪'),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            // Keep a card shape: on tall screens the card would otherwise
            // stretch into a thin strip.
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.72,
                child: SwipeCard(
                  key: _swipeKey,
                  hintFor: _hint,
                  onSwiped: (d) => _c.answer(_qualityFor(d)),
                  child: FlashCard(
                    key: ValueKey('${s.seen.length}:${card.word.id}'),
                    card: card,
                    translationMode: profile.translationMode,
                    onSpeak: () => _speaker.say(card.word.word),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: big ? 72 : 56,
          child: FilledButton(
            key: Key('answer-$key'),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            onPressed: onPressed,
            child: Icon(icon, size: big ? 40 : 30, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}

class SessionSummaryView extends StatelessWidget {
  const SessionSummaryView({
    super.key,
    required this.summary,
    required this.onDone,
  });

  final SessionSummary summary;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final nothingToDo = summary.answered == 0;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (nothingToDo) ...[
            const Text('🎉', style: TextStyle(fontSize: 80)),
            Text(
              'All done for today!',
              key: const Key('all-done'),
              style: text.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Come back tomorrow for more words.', style: text.titleMedium),
          ] else ...[
            Row(
              key: const Key('stars'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      i < summary.stars ? '⭐' : '☆',
                      style: TextStyle(
                        fontSize: 56,
                        color: Colors.amber.shade300,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_cheer(summary.stars), style: text.headlineMedium),
            const SizedBox(height: 16),
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
                '${summary.reviewed == 1 ? 'word' : 'words'} reviewed',
                key: const Key('summary-reviewed'),
                style: text.titleLarge,
              ),
          ],
          const SizedBox(height: 32),
          FilledButton(
            key: const Key('session-done'),
            onPressed: onDone,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  static String _cheer(int stars) => switch (stars) {
    3 => 'Amazing!',
    2 => 'Great job!',
    _ => 'Good try!',
  };
}
