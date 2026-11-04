import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/levels.dart';
import '../profiles/profile_providers.dart';
import 'parent_providers.dart';
import 'pin_gate.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Text('Children', style: text.titleMedium),
        const SizedBox(height: 8),
        if (profiles.isEmpty)
          const Card(
            child: ListTile(title: Text('No profiles yet. Tap "Add child".')),
          ),
        for (final p in profiles)
          Card(
            child: ListTile(
              key: Key('parent-profile-${p.id}'),
              leading: Text(p.avatar, style: const TextStyle(fontSize: 32)),
              title: Text(p.name),
              subtitle: Text(
                'Age ${p.age} · ${CefrLevel.fromCode(p.currentLevel).label} · '
                '${p.dailyNewWords} new words a day',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/parent/profiles/${p.id}'),
            ),
          ),
        const SizedBox(height: 24),
        Text('Settings', style: text.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.pin_outlined),
                title: const Text('Change PIN'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/parent/pin'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
