import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/levels.dart';
import '../../core/placement/placement.dart';
import '../../core/quiz/quiz_builder.dart';
import '../../core/themes.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/word_repository.dart';

enum PlacementPhase { loading, intro, word, check, themes, done }

/// Runs onboarding for a new profile (feat-015): the placement test, the
/// favourite-theme picker, then hands over the first mini-session's words.
/// Nothing is saved until [finish]; quitting midway means the child takes
/// the test again next time.
class PlacementController extends ChangeNotifier {
  PlacementController({
    required this.profileId,
    required WordRepository words,
    required ProfileRepository profiles,
    required DateTime Function() clock,
    Random? random,
    this.quizBuilder = const QuizBuilder(),
  }) : _words = words,
       _profiles = profiles,
       _clock = clock,
       _random = random ?? Random();

  final int profileId;
  final QuizBuilder quizBuilder;
  final WordRepository _words;
  final ProfileRepository _profiles;
  final DateTime Function() _clock;
  final Random _random;

  ProfileRow? profile;
  PlacementTest? test;
  PlacementResult? result;
  Map<String, WordCard> _cards = const {};

  /// Check options per level index: words at or below that level.
  final Map<int, List<QuizWord>> _optionPools = {};

  /// The picture / meaning check for [PlacementTest.pendingCheck].
  QuizItem? check;
  List<ThemeInfo> themes = const [];
  final Set<String> picked = {};

  /// Words for the first mini-session, once [finish] has run.
  List<String>? firstWords;
  bool _intro = true;
  bool _saving = false;

  PlacementPhase get phase {
    final t = test;
    if (t == null) return PlacementPhase.loading;
    if (firstWords != null) return PlacementPhase.done;
    if (t.isFinished) return PlacementPhase.themes;
    if (_intro) return PlacementPhase.intro;
    if (check != null) return PlacementPhase.check;
    return PlacementPhase.word;
  }

  WordCard? cardFor(String wordId) => _cards[wordId];

  WordCard? get currentCard {
    final id = test?.current;
    return id == null ? null : _cards[id];
  }

  /// Picture checks for 4–6 (no reading); 7+ may also get a meaning check.
  bool get _readsWell => (profile?.age ?? 0) >= 7;

  Future<void> start() async {
    final p = (await _profiles.get(profileId))!;
    profile = p;
    final cards = await _words.placementWords(
      age: p.age,
      language: p.nativeLanguage,
    );
    _cards = {for (final c in cards) c.word.id: c};
    final pool = <CefrLevel, List<String>>{};
    for (final c in cards) {
      pool
          .putIfAbsent(CefrLevel.fromCode(c.word.cefrLevel), () => [])
          .add(c.word.id);
    }
    test = PlacementTest(
      pool: pool,
      // The parent's level in the form (the age default unless changed).
      start: CefrLevel.fromCode(p.currentLevel),
      checkable: {
        for (final c in cards)
          if (c.word.emoji != null || (_readsWell && c.translation != null))
            c.word.id,
      },
      random: _random,
    );
    notifyListeners();
  }

  void begin() {
    _intro = false;
    notifyListeners();
  }

  void answer({required bool known}) {
    final t = test;
    if (t == null || phase != PlacementPhase.word) return;
    t.answer(known: known);
    _afterStep();
  }

  /// The child's pick on the check: a word id.
  void answerCheck(String given) {
    final t = test;
    final item = check;
    if (t == null || item == null) return;
    check = null;
    t.answerCheck(item.isCorrect(given));
    _afterStep();
  }

  void _afterStep() {
    final t = test!;
    final pending = t.pendingCheck;
    if (pending != null) {
      check = _buildCheck(pending);
      if (check == null) t.cannotCheck();
    }
    if (t.isFinished && result == null) {
      result = t.result;
      _loadThemes();
      return;
    }
    notifyListeners();
  }

  QuizItem? _buildCheck(String wordId) {
    final c = _cards[wordId];
    if (c == null) return null;
    final w = _quizWord(c);
    final pool = _optionPools.putIfAbsent(
      c.word.levelIndex,
      () => [
        for (final o in _cards.values)
          if (o.word.levelIndex <= c.word.levelIndex) _quizWord(o),
      ],
    );
    final kinds = [
      if (c.word.emoji != null) QuizKind.pickPicture,
      if (_readsWell) QuizKind.chooseMeaning,
    ];
    for (final kind in kinds) {
      final item = quizBuilder.question(kind, w, pool, _random);
      if (item != null) return item;
    }
    return null;
  }

  QuizWord _quizWord(WordCard c) => QuizWord(
    id: c.word.id,
    word: c.word.word,
    emoji: c.word.emoji,
    meaning: c.translation,
  );

  Future<void> _loadThemes() async {
    final counts = await _words.themeCounts(
      levelIndex: result!.level.index,
      age: profile!.age,
    );
    themes = themeChoices(counts);
    notifyListeners();
  }

  void toggleTheme(String id) {
    if (!picked.remove(id) && picked.length < maxFavouriteThemes) {
      picked.add(id);
    }
    notifyListeners();
  }

  /// Saves the level and favourites and picks the first mini-session's
  /// words.
  Future<List<String>> finish() async {
    final r = result;
    if (r == null || _saving) return firstWords ?? const [];
    _saving = true;
    final interests = [
      for (final t in themes)
        if (picked.contains(t.id)) t.id,
    ];
    await _profiles.finishPlacement(
      profileId,
      level: r.level,
      interests: interests,
      now: _clock(),
    );
    final fill = await _words.newWordCandidates(
      profileId: profileId,
      levelIndex: r.level.index,
      age: profile!.age,
      limit: 10,
      interests: interests,
    );
    firstWords = r.firstSessionWords(fill: fill);
    notifyListeners();
    return firstWords!;
  }
}
