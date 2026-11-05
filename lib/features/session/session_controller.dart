import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/levels.dart';
import '../../core/progress/level_progression.dart';
import '../../core/quiz/quiz_builder.dart';
import '../../core/session/session_builder.dart';
import '../../core/session/session_summary.dart';
import '../../core/session/study_session.dart';
import '../../core/srs/sm2_scheduler.dart';
import '../../core/srs/word_schedule.dart';
import '../../core/srs/word_state.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/custom_word_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/word_repository.dart';
import '../levels/level_service.dart';

/// Start of the device's local calendar day containing [utc], as UTC.
DateTime localDayStart(DateTime utc) {
  final l = utc.toLocal();
  return DateTime(l.year, l.month, l.day).toUtc();
}

/// What today's session holds, before it starts (for the child home).
class SessionPreview {
  const SessionPreview({required this.reviews, required this.newWords});
  final int reviews;
  final int newWords;
  int get total => reviews + newWords;
}

/// Loads today's session for a profile.
class SessionLoader {
  SessionLoader({
    required this.words,
    required this.progress,
    required this.profiles,
    required this.clock,
    this.builder = const SessionBuilder(),
  }) : levels = LevelService(
         words: words,
         progress: progress,
         profiles: profiles,
         clock: clock,
       );

  final WordRepository words;
  final ProgressRepository progress;
  final ProfileRepository profiles;
  final DateTime Function() clock;
  final SessionBuilder builder;
  final LevelService levels;

  Future<
    ({
      ProfileRow profile,
      StudySession session,
      Map<String, WordSchedule> schedules,
    })
  >
  load(int profileId, {List<String>? firstWords}) async {
    final profile = (await profiles.get(profileId))!;
    final now = clock();
    final schedules = await progress.schedules(profileId);
    final introduced = await progress.newIntroducedSince(
      profileId,
      localDayStart(now),
    );
    final remaining = profile.dailyNewWords - introduced;
    final candidates =
        firstWords ??
        (remaining <= 0
            ? const <String>[]
            : await _newWords(profile, remaining));
    final session = builder.build(
      schedules: schedules,
      newWordIds: candidates,
      // The first mini-session after placement is exactly its easy words.
      dailyNewWords: firstWords != null
          ? introduced + firstWords.length
          : profile.dailyNewWords,
      newIntroducedToday: introduced,
      maxCards: SessionBuilder.cardsForMinutes(profile.dailyMinutes),
      now: now,
    );
    return (profile: profile, session: session, schedules: schedules);
  }

  /// New-word candidates: the parent's custom words first (feat-018), then
  /// the profile's level (favourites first) with a next-level preview word
  /// in every 5th slot (feat-016).
  Future<List<String>> _newWords(ProfileRow profile, int total) async {
    final custom = (await CustomWordRepository(
      words.db,
    ).unseenIds(profile.id)).take(total).toList();
    final count = total - custom.length;
    if (count <= 0) return custom;
    return [...custom, ...await _levelWords(profile, count)];
  }

  Future<List<String>> _levelWords(ProfileRow profile, int count) async {
    final current = await words.newWordCandidates(
      profileId: profile.id,
      levelIndex: CefrLevel.fromCode(profile.currentLevel).index,
      age: profile.age,
      limit: count,
      interests: profile.interests,
    );
    final slots = LevelProgression.previewSlots(count);
    final next = slots == 0 ? null : await levels.previewLevel(profile);
    if (next == null) return current;
    final preview = await words.newWordCandidates(
      profileId: profile.id,
      levelIndex: next.index,
      age: profile.age,
      limit: count,
      interests: profile.interests,
      exactLevel: true,
    );
    return const LevelProgression().mixPreview(current, preview, count: count);
  }

  Future<SessionPreview> preview(int profileId) async {
    final s = (await load(profileId)).session;
    final fresh = s.queue.where((c) => c.isNew).length;
    return SessionPreview(reviews: s.queue.length - fresh, newWords: fresh);
  }
}

/// Runs one daily session: shows cards, feeds first answers to the SM-2
/// scheduler and saves each one immediately, then logs the session.
class SessionController extends ChangeNotifier {
  SessionController({
    required this.profileId,
    required WordRepository words,
    required ProgressRepository progress,
    required ProfileRepository profiles,
    required DateTime Function() clock,
    this.scheduler = const Sm2Scheduler(),
    this.quizBuilder = const QuizBuilder(),
    this.firstWords,
    Random? random,
  }) : _random = random ?? Random(),
       _words = words,
       _progress = progress,
       _clock = clock,
       _loader = SessionLoader(
         words: words,
         progress: progress,
         profiles: profiles,
         clock: clock,
       );

  final int profileId;

  /// The first mini-session after placement (feat-015): these new words
  /// instead of the usual ones.
  final List<String>? firstWords;
  final Sm2Scheduler scheduler;
  final QuizBuilder quizBuilder;
  final Random _random;
  final WordRepository _words;
  final ProgressRepository _progress;
  final DateTime Function() _clock;
  final SessionLoader _loader;

  ProfileRow? profile;
  StudySession? session;
  SessionSummary? summary;

  /// The level the child just moved up to at the end of this session
  /// (feat-016), or null.
  CefrLevel? levelUp;
  Map<String, WordCard> _cards = const {};
  Map<String, WordSchedule> _schedules = {};

  /// Schedules as they were before this session, to redo a word when a
  /// wrong quiz answer overrides its swipe.
  Map<String, WordSchedule> _before = const {};

  /// The active-recall round after the swipe cards (feat-012).
  List<QuizItem> quiz = const [];
  final Map<String, bool> quizResults = {};
  int _quizIndex = 0;
  bool _quizBuilt = false;
  DateTime? _startedAt;
  bool _logged = false;
  bool _busy = false;

  bool get isLoading => session == null;

  /// Swipe cards and quiz both done (or the session was empty).
  bool get isFinished => summary != null;

  bool get inQuiz => !isFinished && _quizBuilt && _quizIndex < quiz.length;

  QuizItem? get currentQuiz => inQuiz ? quiz[_quizIndex] : null;

  /// 1-based number of the current quiz question.
  int get quizNumber => _quizIndex + 1;

  /// Card for a word in today's session or the quiz options.
  WordCard? cardFor(String wordId) => _cards[wordId];

  WordCard? get currentCard {
    final c = session?.current;
    return c == null ? null : _cards[c.wordId];
  }

  /// Cards answered this session, in the order first answered.
  List<WordCard> get practicedCards => [
    for (final id in session?.firstAnswers.keys ?? const <String>[])
      ?_cards[id],
  ];

  Future<void> start() async {
    final loaded = await _loader.load(profileId, firstWords: firstWords);
    profile = loaded.profile;
    _schedules = Map.of(loaded.schedules);
    _before = Map.of(loaded.schedules);
    final ids = [for (final c in loaded.session.queue) c.wordId];
    final cards = await _words.cards(ids, language: profile!.nativeLanguage);
    _cards = {for (final c in cards) c.word.id: c};
    // Drop cards whose word is missing from the bank.
    session = StudySession([
      for (final c in loaded.session.queue)
        if (_cards.containsKey(c.wordId)) c,
    ]);
    _startedAt = _clock();
    if (session!.isFinished) {
      _quizBuilt = true;
      summary = SessionSummary.of(session!);
    }
    notifyListeners();
  }

  Future<void> answer(AnswerQuality quality) async {
    final s = session;
    final card = s?.current;
    if (s == null || card == null || _busy) return;
    _busy = true;
    try {
      final isFirst = !s.firstAnswers.containsKey(card.wordId);
      session = s.answer(quality);
      notifyListeners();
      if (isFirst) {
        final now = _clock();
        final next = scheduler.schedule(
          _schedules[card.wordId] ?? WordSchedule.initial(),
          quality,
          now: now,
        );
        _schedules[card.wordId] = next;
        await _progress.save(profileId, card.wordId, next, now: now);
      }
      if (session!.isFinished) await _startQuiz();
    } finally {
      _busy = false;
    }
  }

  Future<void> _startQuiz() async {
    final s = session!;
    final p = profile!;
    final pool = await _words.quizPool(
      levelIndex: CefrLevel.fromCode(p.currentLevel).index,
      age: p.age,
      language: p.nativeLanguage,
    );
    for (final c in pool) {
      _cards.putIfAbsent(c.word.id, () => c);
    }
    QuizWord qw(WordCard c) => QuizWord(
      id: c.word.id,
      word: c.word.word,
      emoji: c.word.emoji,
      meaning: c.translation,
    );
    quiz = quizBuilder.build(
      today: [
        for (final id in s.firstAnswers.keys)
          if (_cards[id] != null) qw(_cards[id]!),
      ],
      swipes: s.firstAnswers,
      pool: [for (final c in _cards.values) qw(c)],
      age: p.age,
      random: _random,
    );
    _quizBuilt = true;
    if (quiz.isEmpty) {
      await _finish();
    } else {
      notifyListeners();
    }
  }

  /// Answers the current quiz question: a word id, or the spelled letters.
  /// A wrong answer reschedules the word as a miss ("quiz wrong" overrides
  /// the swipe). Returns whether it was right.
  Future<bool> answerQuiz(String given) async {
    final item = currentQuiz;
    if (item == null || _busy) return false;
    _busy = true;
    try {
      final ok = item.isCorrect(given);
      quizResults[item.wordId] = ok;
      final now = _clock();
      await _progress.logQuiz(
        profileId: profileId,
        wordId: item.wordId,
        kind: item.kind,
        correct: ok,
        at: now,
      );
      if (!ok) {
        final next = scheduler.schedule(
          _before[item.wordId] ?? WordSchedule.initial(),
          AnswerQuality.quizWrong,
          now: now,
        );
        _schedules[item.wordId] = next;
        await _progress.save(profileId, item.wordId, next, now: now);
      }
      _quizIndex++;
      if (_quizIndex >= quiz.length) {
        await _finish();
      } else {
        notifyListeners();
      }
      return ok;
    } finally {
      _busy = false;
    }
  }

  /// The child leaves early: keep what was answered and log it.
  Future<void> quit() async {
    if (session != null && session!.firstAnswers.isNotEmpty) await _finish();
  }

  Future<void> _finish() async {
    summary = SessionSummary.of(session!, quiz: Map.of(quizResults));
    if (!_logged && summary!.answered > 0) {
      _logged = true;
      final started = _startedAt!;
      await _progress.logSession(
        profileId: profileId,
        startedAt: started,
        durationSec: _clock().difference(started).inSeconds,
        reviewed: summary!.reviewed,
        newLearned: summary!.newLearned,
        accuracy: summary!.accuracy,
      );
      levelUp = await _loader.levels.maybeLevelUp(profileId);
    }
    notifyListeners();
  }
}
