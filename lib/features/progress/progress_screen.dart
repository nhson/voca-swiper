import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/progress/progress_stats.dart';
import '../../ui/chunky_button.dart';
import '../../ui/kid_look.dart';
import '../../ui/kid_screen.dart';
import '../profiles/profile_providers.dart';

/// Words by state, accuracy and minutes per day for one profile.
final progressStatsProvider = FutureProvider.autoDispose
    .family<ProgressStats, int>((ref, profileId) async {
      final repo = ref.watch(progressRepositoryProvider);
      final schedules = await repo.schedules(profileId);
      final sessions = await repo.sessionStats(profileId);
      return ProgressStats.compute(
        states: [for (final s in schedules.values) s.state],
        sessions: sessions,
        now: ref.read(clockProvider)(),
      );
    });

const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

/// "My words": a simple progress screen per profile, shared by the child
/// home and the parent area (docs/SPEC.md — Phase 1).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key, required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider(profileId)).value;
    final stats = ref.watch(progressStatsProvider(profileId)).value;
    final look = KidLook.forAge(profile?.age);
    final text = Theme.of(context).textTheme;
    return KidScreen(
      look: look,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    profile == null ? '' : "${profile.name}'s words",
                    style: text.headlineLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (profile != null)
                  Text(profile.avatar, style: const TextStyle(fontSize: 34)),
              ],
            ),
          ),
          Expanded(
            child: stats == null
                ? const Center(child: CircularProgressIndicator())
                : _Body(stats: stats, look: look),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.stats, required this.look});

  final ProgressStats stats;
  final KidLook look;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final acc = stats.accuracy;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            _Panel(
              child: Row(
                children: [
                  _StateTile(
                    id: 'mastered',
                    emoji: '🌳',
                    label: 'Mastered',
                    value: stats.mastered,
                    color: KidColors.knew,
                  ),
                  _StateTile(
                    id: 'review',
                    emoji: '🌿',
                    label: 'Growing',
                    value: stats.review,
                    color: const Color(0xFF4FA9FF),
                  ),
                  _StateTile(
                    id: 'learning',
                    emoji: '🌱',
                    label: 'Learning',
                    value: stats.learning,
                    color: KidColors.almost,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Panel(
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Right answers', style: text.titleMedium),
                        Text(
                          acc == null
                              ? 'Not yet'
                              : 'out of ${stats.answered} '
                                    '${stats.answered == 1 ? 'answer' : 'answers'}',
                          style: text.bodyMedium?.copyWith(
                            color: KidColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    acc == null ? '–' : '${(acc * 100).round()}%',
                    key: const Key('stat-accuracy'),
                    style: text.displaySmall?.copyWith(color: look.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Minutes this week',
                          style: text.titleMedium,
                        ),
                      ),
                      Text(
                        '${stats.minutesThisWeek}',
                        key: const Key('minutes-week'),
                        style: text.headlineMedium,
                      ),
                      Text(' min', style: text.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MinutesChart(days: stats.minutesByDay, color: look.accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: KidColors.ink.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

class _StateTile extends StatelessWidget {
  const _StateTile({
    required this.id,
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String id;
  final String emoji;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            key: Key('stat-$id'),
            style: text.headlineLarge?.copyWith(
              color: KidColors.shade(color, 0.1),
            ),
          ),
          Text(label, style: text.labelLarge),
        ],
      ),
    );
  }
}

class _MinutesChart extends StatelessWidget {
  const _MinutesChart({required this.days, required this.color});

  final List<DayMinutes> days;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final top = days.fold(1, (m, d) => d.minutes > m ? d.minutes : m);
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, d) in days.indexed)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    d.minutes == 0 ? '' : '${d.minutes}',
                    key: Key('minutes-day-$i'),
                    style: text.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: 6 + 94 * d.minutes / top,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: d.minutes == 0
                          ? const Color(0xFFEDEAF5)
                          : i == days.length - 1
                          ? color
                          : color.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dayLetters[d.day.weekday - 1],
                    style: text.labelLarge?.copyWith(
                      color: i == days.length - 1
                          ? KidColors.ink
                          : KidColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
