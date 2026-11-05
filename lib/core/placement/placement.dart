import 'dart:math';

import '../levels.dart';

/// Where a placement test placed the child.
class PlacementResult {
  const PlacementResult({
    required this.level,
    required this.scores,
    required this.knownWords,
  });

  /// The starting level: the highest tested level scoring at least
  /// [PlacementTest.passRate], else the lowest level in the test.
  final CefrLevel level;

  /// Estimated share known per tested level, 0–1.
  final Map<CefrLevel, double> scores;

  /// "I know it" answers that were not caught by a failed check, in the order
  /// asked, with their level.
  final Map<String, CefrLevel> knownWords;

  /// Words for the first mini-session (docs/SPEC.md — Onboarding step 5):
  /// known words at or below [level] first, so the child ends on a win, then
  /// [fill] (easiest first), without repeats.
  List<String> firstSessionWords({required List<String> fill, int count = 5}) {
    final out = <String>{
      for (final e in knownWords.entries)
        if (e.value.index <= level.index) e.key,
    }.take(count).toSet();
    for (final id in fill) {
      if (out.length >= count) break;
      out.add(id);
    }
    return out.toList();
  }
}

class _Answer {
  _Answer(this.wordId, this.level, {required this.known});
  final String wordId;
  final CefrLevel level;
  final bool known;

  /// null: not checked; true/false: picture/meaning check right/wrong.
  bool? check;
}

/// The onboarding placement test (docs/SPEC.md — Onboarding steps 2–3).
///
/// - Blocks of [blockSize] words at one level, [blocks] blocks (24 words).
///   The first block is at the start level (the age default). After each
///   block the level's score so far decides the next block: one level up if
///   it passes [passRate], one level down if not; at the top or bottom the
///   same level is sampled again for more evidence.
/// - Each block takes one word from each equal slice of the unused words in
///   teaching order, so it spans easy to hard; a word that can be checked is
///   preferred within its slice.
/// - Anti-guessing: the first "I know it" on a checkable word is checked
///   straight away, then at most one every [checkEvery] words. A failed
///   check makes that word unknown, and unchecked "I know it" answers count
///   as `(checks passed + 1) / (checks + 1)` of a word, so a child tapping
///   "I know it" on everything is caught.
/// - Result: the highest tested level scoring at least [passRate]; if none,
///   the lowest level in the test.
class PlacementTest {
  PlacementTest({
    required Map<CefrLevel, List<String>> pool,
    required CefrLevel start,
    required Set<String> checkable,
    required Random random,
    this.blockSize = defaultBlockSize,
    this.blocks = defaultBlocks,
    this.checkEvery = defaultCheckEvery,
    this.passRate = defaultPassRate,
  }) : _checkable = checkable,
       _random = random,
       _levels = [
         for (final l in CefrLevel.values)
           if ((pool[l] ?? const []).isNotEmpty) l,
       ],
       _pool = pool {
    if (_levels.isEmpty) {
      _finished = true;
      return;
    }
    _sinceCheck = checkEvery - 1;
    _level = _levels.lastWhere(
      (l) => l.index <= start.index,
      orElse: () => _levels.first,
    );
    _draw();
  }

  static const defaultBlockSize = 6;
  static const defaultBlocks = 4;
  static const defaultCheckEvery = 4;
  static const defaultPassRate = 0.7;

  final int blockSize;
  final int blocks;
  final int checkEvery;
  final double passRate;

  final Map<CefrLevel, List<String>> _pool;
  final List<CefrLevel> _levels;
  final Set<String> _checkable;
  final Random _random;

  final List<_Answer> _answers = [];
  final Set<String> _asked = {};
  List<String> _block = [];
  late CefrLevel _level;
  int _blocksDrawn = 0;
  int _sinceCheck = 0;
  String? _pendingCheck;
  bool _finished = false;

  bool get isFinished => _finished;

  /// Words answered so far.
  int get answered => _answers.length;

  /// Upper bound on the words asked.
  int get total => blockSize * blocks;

  /// The word to ask "do you know it?" about, or null while a check is
  /// pending or when finished.
  String? get current =>
      _finished || _pendingCheck != null || _block.isEmpty ? null : _block[0];

  /// A word just answered "I know it" that should be checked now.
  String? get pendingCheck => _pendingCheck;

  void answer({required bool known}) {
    final id = current;
    if (id == null) return;
    _block.removeAt(0);
    _answers.add(_Answer(id, _level, known: known));
    _sinceCheck++;
    if (known && _checkable.contains(id) && _sinceCheck >= checkEvery) {
      _pendingCheck = id;
    } else {
      _advance();
    }
  }

  void answerCheck(bool correct) {
    if (_pendingCheck == null) return;
    _answers.last.check = correct;
    _pendingCheck = null;
    _sinceCheck = 0;
    _advance();
  }

  /// The UI could not build a check for [pendingCheck]: carry on unchecked.
  void cannotCheck() {
    if (_pendingCheck == null) return;
    _pendingCheck = null;
    _advance();
  }

  PlacementResult get result {
    final scores = <CefrLevel, double>{for (final l in _levels) l: ?_score(l)};
    final passed = [
      for (final l in _levels.reversed)
        if ((scores[l] ?? 0) >= passRate) l,
    ];
    return PlacementResult(
      level: passed.isNotEmpty
          ? passed.first
          : (_levels.isEmpty ? CefrLevel.preA1 : _levels.first),
      scores: scores,
      knownWords: {
        for (final a in _answers)
          if (a.known && a.check != false) a.wordId: a.level,
      },
    );
  }

  double get _trust {
    final checks = _answers.where((a) => a.check != null).toList();
    final passed = checks.where((a) => a.check!).length;
    return (passed + 1) / (checks.length + 1);
  }

  double? _score(CefrLevel level) {
    final at = _answers.where((a) => a.level == level).toList();
    if (at.isEmpty) return null;
    final trust = _trust;
    var known = 0.0;
    for (final a in at) {
      if (!a.known || a.check == false) continue;
      known += a.check == true ? 1 : trust;
    }
    return known / at.length;
  }

  void _advance() {
    if (_block.isNotEmpty) return;
    if (_blocksDrawn >= blocks) {
      _finished = true;
      return;
    }
    final i = _levels.indexOf(_level);
    final pass = (_score(_level) ?? 0) >= passRate;
    final next = pass ? i + 1 : i - 1;
    if (next >= 0 && next < _levels.length && _unused(_levels[next]) > 0) {
      _level = _levels[next];
    }
    _draw();
  }

  int _unused(CefrLevel l) =>
      _pool[l]!.where((id) => !_asked.contains(id)).length;

  /// Draws the next block at [_level]; finishes when the level is used up.
  void _draw() {
    final unused = [
      for (final id in _pool[_level]!)
        if (!_asked.contains(id)) id,
    ];
    if (unused.isEmpty) {
      _finished = true;
      return;
    }
    final n = min(blockSize, unused.length);
    final block = <String>[];
    for (var s = 0; s < n; s++) {
      final slice = unused.sublist(
        s * unused.length ~/ n,
        (s + 1) * unused.length ~/ n,
      );
      final preferred = slice.where(_checkable.contains).toList();
      final from = preferred.isNotEmpty ? preferred : slice;
      block.add(from[_random.nextInt(from.length)]);
    }
    _asked.addAll(block);
    _block = block;
    _blocksDrawn++;
  }
}
