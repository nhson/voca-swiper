import 'package:flutter/foundation.dart';

import '../../core/levels.dart';
import '../../core/session/session_builder.dart';
import '../../core/session/session_summary.dart';
import '../../core/session/study_session.dart';
import '../../core/srs/sm2_scheduler.dart';
import '../../core/srs/word_schedule.dart';
import '../../core/srs/word_state.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/word_repository.dart';

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
  });

  final WordRepository words;
  final ProgressRepository progress;
  final ProfileRepository profiles;
  final DateTime Function() clock;
  final SessionBuilder builder;

  Future<
    ({
      ProfileRow profile,
      StudySession session,
      Map<String, WordSchedule> schedules,
    })
  >
  load(int profileId) async {
    final profile = (await profiles.get(profileId))!;
    final now = clock();
    final schedules = await progress.schedules(profileId);
    final introduced = await progress.newIntroducedSince(
      profileId,
      localDayStart(now),
    );
    final remaining = profile.dailyNewWords - introduced;
    final candidates = remaining <= 0
        ? const <String>[]
        : await words.newWordCandidates(
            profileId: profileId,
            levelIndex: CefrLevel.fromCode(profile.currentLevel).index,
            age: profile.age,
            limit: remaining,
          );
    final session = builder.build(
      schedules: schedules,
      newWordIds: candidates,
      dailyNewWords: profile.dailyNewWords,
      newIntroducedToday: introduced,
      now: now,
    );
    return (profile: profile, session: session, schedules: schedules);
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
  }) : _words = words,
       _progress = progress,
       _clock = clock,
       _loader = SessionLoader(
         words: words,
         progress: progress,
         profiles: profiles,
         clock: clock,
       );

  final int profileId;
  final Sm2Scheduler scheduler;
  final WordRepository _words;
  final ProgressRepository _progress;
  final DateTime Function() _clock;
  final SessionLoader _loader;

  ProfileRow? profile;
  StudySession? session;
  SessionSummary? summary;
  Map<String, WordCard> _cards = const {};
  Map<String, WordSchedule> _schedules = {};
  DateTime? _startedAt;
  bool _logged = false;
  bool _busy = false;

  bool get isLoading => session == null;
  bool get isFinished => session?.isFinished ?? false;

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
    final loaded = await _loader.load(profileId);
    profile = loaded.profile;
    _schedules = Map.of(loaded.schedules);
    final ids = [for (final c in loaded.session.queue) c.wordId];
    final cards = await _words.cards(ids, language: profile!.nativeLanguage);
    _cards = {for (final c in cards) c.word.id: c};
    // Drop cards whose word is missing from the bank.
    session = StudySession([
      for (final c in loaded.session.queue)
        if (_cards.containsKey(c.wordId)) c,
    ]);
    _startedAt = _clock();
    if (session!.isFinished) summary = SessionSummary.of(session!);
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
      if (session!.isFinished) await _finish();
    } finally {
      _busy = false;
    }
  }

  /// The child leaves early: keep what was answered and log it.
  Future<void> quit() async {
    if (session != null && session!.firstAnswers.isNotEmpty) await _finish();
  }

  Future<void> _finish() async {
    summary = SessionSummary.of(session!);
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
    }
    notifyListeners();
  }
}
