import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/levels.dart';
import '../../core/progress/dashboard.dart';
import '../../core/progress/level_progression.dart';
import '../../core/progress/retention.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/word_repository.dart';
import '../../ui/readable_width.dart';
import '../levels/level_service.dart';
import 'pin_gate.dart';

/// Everything the parent dashboard shows for one child (feat-017).
class DashboardData {
  const DashboardData({
    required this.profile,
    required this.goal,
    required this.weeks,
    required this.retention,
    required this.struggling,
    required this.cards,
    required this.levels,
    required this.masteredAtLevel,
    required this.wordsAtLevel,
  });

  final ProfileRow profile;
  final GoalStats goal;
  final List<WeekPoint> weeks;
  final Retention retention;
  final List<WordRecord> struggling;
  final Map<String, WordCard> cards;

  /// Levels with words for the child's age.
  final List<CefrLevel> levels;
  final int masteredAtLevel;
  final int wordsAtLevel;
}

final dashboardProvider = FutureProvider.autoDispose
    .family<DashboardData?, int>((ref, profileId) async {
      final profile = await ref.watch(profileRepositoryProvider).get(profileId);
      if (profile == null) return null;
      final progress = ref.watch(progressRepositoryProvider);
      final words = ref.watch(wordRepositoryProvider);
      final now = ref.read(clockProvider)();
      final schedules = await progress.schedules(profileId);
      final sessions = await progress.sessionStats(profileId);
      final firstSeen = await progress.firstSeen(profileId);
      final struggling = Dashboard.struggling([
        for (final e in schedules.entries)
          WordRecord(
            wordId: e.key,
            state: e.value.state,
            wrongCount: e.value.wrongCount,
            correctCount: e.value.correctCount,
          ),
      ]);
      final cards = await words.cards([
        for (final w in struggling) w.wordId,
      ], language: profile.nativeLanguage);
      final level = CefrLevel.fromCode(profile.currentLevel);
      final counts = await words.levelCounts(age: profile.age);
      return DashboardData(
        profile: profile,
        goal: Dashboard.goal(
          sessions: sessions,
          dailyMinutes: profile.dailyMinutes,
          now: now,
        ),
        weeks: Dashboard.weeklyTrend(
          firstSeen: firstSeen.values.toList(),
          sessions: sessions,
          now: now,
        ),
        retention: await progress.retention(profileId),
        struggling: struggling,
        cards: {for (final c in cards) c.word.id: c},
        levels: counts.keys.toList(),
        masteredAtLevel: await progress.masteredAt(
          profileId,
          level: level,
          age: profile.age,
        ),
        wordsAtLevel: counts[level] ?? 0,
      );
    });

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// The parent's view of one child: level, goal, trend, retention and the
/// words they find hardest (feat-017).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider(profileId));
    final name = data.value?.profile.name;
    return ParentGate(
      child: Scaffold(
        appBar: AppBar(
          title: Text(name == null ? 'Dashboard' : "$name's progress"),
          actions: [
            TextButton.icon(
              key: const Key('dash-child-view'),
              onPressed: () => context.push('/kid/$profileId/progress'),
              icon: const Icon(Icons.child_care_rounded),
              label: const Text("Child's view"),
            ),
          ],
        ),
        body: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (d) => d == null
              ? const Center(child: Text('Profile not found'))
              : _Body(data: d),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = data;
    final p = d.profile;
    final text = Theme.of(context).textTheme;
    final level = CefrLevel.fromCode(p.currentLevel);
    final share = d.wordsAtLevel == 0
        ? 0.0
        : d.masteredAtLevel / d.wordsAtLevel;
    final r = d.retention;
    return ListView(
      key: const Key('dashboard'),
      padding: readablePadding(context, bottom: 32),
      children: [
        _Section(
          title: 'Level',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DropdownButton<CefrLevel>(
                    key: const Key('dash-level'),
                    value: level,
                    items: [
                      for (final l in {...d.levels, level})
                        DropdownMenuItem(value: l, child: Text(l.label)),
                    ],
                    onChanged: (l) async {
                      if (l == null || l == level) return;
                      await ref.read(levelServiceProvider).setLevel(p.id, l);
                      ref.invalidate(dashboardProvider(p.id));
                    },
                  ),
                  const SizedBox(width: 12),
                  if (p.levelLocked)
                    const Chip(
                      avatar: Icon(Icons.lock, size: 16),
                      label: Text('Kept by you'),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (share / LevelProgression.levelUpShare).clamp(0, 1),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              Text(
                '${d.masteredAtLevel} of ${d.wordsAtLevel} ${level.label} '
                'words mastered (${(share * 100).round()}%). '
                '${p.levelLocked ? 'Level is kept as set.' : 'Moves up at 80%.'}',
                key: const Key('dash-level-progress'),
                style: text.bodyMedium,
              ),
            ],
          ),
        ),
        _Section(
          title: 'Last 7 days',
          child: Text(
            'Practised ${d.goal.daysPractised} of 7 days · '
            '${d.goal.daysAtGoal} at the ${d.goal.goal}-minute goal · '
            'about ${d.goal.averageMinutes} min a day',
            key: const Key('dash-goal'),
            style: text.bodyLarge,
          ),
        ),
        _Section(
          title: 'Remembered after 2 weeks',
          child: Text(
            r.asked == 0
                ? 'Not enough quiz answers yet on words learned 2+ weeks ago.'
                : '${(r.correct * 100 / r.asked).round()}% right '
                      '(${r.correct} of ${r.asked} quiz answers, '
                      '${r.words} ${r.words == 1 ? 'word' : 'words'})',
            key: const Key('dash-retention'),
            style: text.bodyLarge,
          ),
        ),
        _Section(
          title: 'Weekly trend',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New words', style: text.titleSmall),
              _Bars(
                id: 'words',
                weeks: d.weeks,
                value: (w) => w.newWords,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text('Minutes', style: text.titleSmall),
              _Bars(
                id: 'minutes',
                weeks: d.weeks,
                value: (w) => w.minutes,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ],
          ),
        ),
        _Section(
          title: 'Struggling words',
          child: d.struggling.isEmpty
              ? Text(
                  'None right now 🎉',
                  key: const Key('dash-no-struggling'),
                  style: text.bodyLarge,
                )
              : Column(
                  children: [
                    for (final w in d.struggling)
                      ListTile(
                        key: Key('dash-struggling-${w.wordId}'),
                        contentPadding: EdgeInsets.zero,
                        leading: Text(
                          d.cards[w.wordId]?.word.emoji ?? '📝',
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(d.cards[w.wordId]?.word.word ?? w.wordId),
                        subtitle: Text(
                          [
                            ?d.cards[w.wordId]?.translation,
                            '${w.wrongCount} misses · ${w.correctCount} right',
                          ].join(' · '),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    ),
  );
}

/// A small bar chart, one bar per week, value above, date below.
class _Bars extends StatelessWidget {
  const _Bars({
    required this.id,
    required this.weeks,
    required this.value,
    required this.color,
  });

  final String id;
  final List<WeekPoint> weeks;
  final int Function(WeekPoint) value;
  final Color color;

  static const _height = 70.0;

  @override
  Widget build(BuildContext context) {
    final values = [for (final w in weeks) value(w)];
    final top = values.fold(1, (m, v) => v > m ? v : m);
    final small = Theme.of(context).textTheme.labelSmall;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < weeks.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                children: [
                  Text('${values[i]}', key: Key('dash-$id-$i'), style: small),
                  const SizedBox(height: 2),
                  Container(
                    height: values[i] == 0 ? 2 : _height * values[i] / top,
                    decoration: BoxDecoration(
                      color: values[i] == 0
                          ? color.withValues(alpha: 0.25)
                          : color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    child: Text(_shortDate(weeks[i].start), style: small),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
