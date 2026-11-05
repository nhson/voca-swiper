import '../srs/word_state.dart';

/// One card in a session queue.
class SessionCard {
  const SessionCard(this.wordId, {required this.isNew, this.isRetry = false});

  final String wordId;

  /// First time this profile sees the word.
  final bool isNew;

  /// Re-shown at the end of the session after a miss (practice only).
  final bool isRetry;

  SessionCard asRetry() => SessionCard(wordId, isNew: isNew, isRetry: true);

  @override
  String toString() =>
      'SessionCard($wordId${isNew ? ', new' : ''}${isRetry ? ', retry' : ''})';
}

/// An in-progress daily session (docs/SPEC.md — Core learning loop).
///
/// Immutable: [answer] returns the next session. Rules:
/// - A miss (didn't know / quiz wrong) re-queues the word at the end, once.
/// - Only the first answer per word counts for scheduling ([firstAnswers]);
///   the retry is practice.
class StudySession {
  StudySession(List<SessionCard> queue)
    : this._(List.unmodifiable(queue), const {}, const []);

  StudySession._(this.queue, this.firstAnswers, this.seen);

  /// Cards still to show; [current] is the first.
  final List<SessionCard> queue;

  /// The answer that should be fed to the scheduler, per word.
  final Map<String, AnswerQuality> firstAnswers;

  /// Cards already answered, in order (retries included).
  final List<SessionCard> seen;

  /// Total cards in this session so far: answered + still queued.
  int get total => seen.length + queue.length;

  SessionCard? get current => queue.isEmpty ? null : queue.first;

  bool get isFinished => queue.isEmpty;

  StudySession answer(AnswerQuality quality) {
    final card = current;
    if (card == null) {
      throw StateError('Session is finished; there is no card to answer.');
    }

    final rest = queue.sublist(1);
    final isMiss =
        quality == AnswerQuality.didntKnow ||
        quality == AnswerQuality.quizWrong;
    final nextQueue = [...rest, if (isMiss && !card.isRetry) card.asRetry()];

    final answers = firstAnswers.containsKey(card.wordId)
        ? firstAnswers
        : Map<String, AnswerQuality>.unmodifiable({
            ...firstAnswers,
            card.wordId: quality,
          });

    return StudySession._(
      List.unmodifiable(nextQueue),
      answers,
      List.unmodifiable([...seen, card]),
    );
  }
}
