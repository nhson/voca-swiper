import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../core/levels.dart';
import '../../ui/sfx.dart';
import '../profiles/profile_providers.dart';
import '../reminders/reminders_screen.dart' show formatMinute;
import '../levels/level_service.dart';
import 'parent_providers.dart';
import 'pin_gate.dart';
import '../../ui/readable_width.dart';

class ParentScreen extends ConsumerWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ParentGate(
      child: PopScope(
        onPopInvokedWithResult: (didPop, _) {
          // Runs during navigation; providers can't change mid-build.
          if (didPop) {
            final unlocked = ref.read(parentUnlockedProvider.notifier);
            Future.microtask(unlocked.lock);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Parent area'),
            leading: IconButton(
              key: const Key('exit-parent'),
              tooltip: 'Lock and exit',
              icon: const Icon(Icons.lock),
              onPressed: () {
                ref.read(parentUnlockedProvider.notifier).lock();
                context.go('/');
              },
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('add-child'),
            onPressed: () => context.push('/parent/profiles/new'),
            icon: const Icon(Icons.person_add),
            label: const Text('Add child'),
          ),
          body: const _ParentBody(),
        ),
      ),
    );
  }
}

class _ParentBody extends ConsumerWidget {
  const _ParentBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: readablePadding(context, bottom: 96),
      children: [
        Text('Children', style: text.titleMedium),
        const SizedBox(height: 8),
        if (profiles.isEmpty)
          const Card(
            child: ListTile(title: Text('No profiles yet. Tap "Add child".')),
          ),
        for (final p in profiles)
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  key: Key('parent-profile-${p.id}'),
                  leading: Text(p.avatar, style: const TextStyle(fontSize: 32)),
                  title: Text(p.name),
                  subtitle: Text(
                    'Age ${p.age} · ${CefrLevel.fromCode(p.currentLevel).label} · '
                    '${p.dailyNewWords} new words a day',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: Key('parent-progress-${p.id}'),
                        tooltip: 'Progress',
                        icon: const Icon(Icons.insights_rounded),
                        onPressed: () =>
                            context.push('/parent/profiles/${p.id}/dashboard'),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => context.push('/parent/profiles/${p.id}'),
                ),
                _StepBackBanner(profile: p),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text('Settings', style: text.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                key: const Key('open-reminders'),
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Daily reminder'),
                subtitle: Text(_reminderLabel(context, ref)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/parent/reminders'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.pin_outlined),
                title: const Text('Change PIN'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/parent/pin'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                key: const Key('sound-toggle'),
                secondary: const Icon(Icons.music_note_outlined),
                title: const Text('Sound effects'),
                subtitle: const Text('Short sounds for answers and stars'),
                value: ref.watch(soundEffectsOnProvider).value ?? true,
                onChanged: (on) =>
                    ref.read(settingsRepositoryProvider).setSoundEffects(on),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _reminderLabel(BuildContext context, WidgetRef ref) {
    final m = ref.watch(parentAccountProvider).value?.reminderMinuteOfDay;
    if (m == null) return 'Off';
    return 'Every day at ${formatMinute(context, m)}';
  }
}

/// "Step back a level?" for a child who has been finding the level hard
/// (feat-016). The parent decides; nothing changes on its own.
class _StepBackBanner extends ConsumerWidget {
  const _StepBackBanner({required this.profile});

  final ProfileRow profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = profile.id;
    final s = ref.watch(stepBackSuggestionProvider(id)).value;
    if (s == null) return const SizedBox.shrink();
    final level = CefrLevel.fromCode(profile.currentLevel);
    final service = ref.read(levelServiceProvider);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: Key('step-back-$id'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${profile.name} got ${(s.accuracy * 100).round()}% right this '
            'week at ${level.label}. Step back to ${s.to.label} for a while?',
            style: TextStyle(color: scheme.onTertiaryContainer),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            overflowAlignment: OverflowBarAlignment.end,
            children: [
              TextButton(
                key: Key('step-back-dismiss-$id'),
                onPressed: () async {
                  await service.dismissStepBack(id);
                  ref.invalidate(stepBackSuggestionProvider(id));
                },
                child: const Text('Not now'),
              ),
              FilledButton(
                key: Key('step-back-accept-$id'),
                onPressed: () async {
                  await service.setLevel(id, s.to);
                  ref.invalidate(stepBackSuggestionProvider(id));
                },
                child: const Text('Step back'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
