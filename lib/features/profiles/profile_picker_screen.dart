import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/app_database.dart';
import '../parent/parent_providers.dart';
import '../parent/setup_screen.dart';
import 'profile_providers.dart';

/// Home: first-run setup, or "Who's learning today?".
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(parentAccountProvider);
    return account.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (a) =>
          a == null ? const SetupScreen() : const ProfilePickerScreen(),
    );
  }
}

class ProfilePickerScreen extends ConsumerWidget {
  const ProfilePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton.icon(
            key: const Key('open-parent'),
            onPressed: () => context.push('/parent'),
            icon: const Icon(Icons.lock_outline),
            label: const Text('Parents'),
          ),
        ],
      ),
      body: profiles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty ? const _NoProfiles() : _Grid(list),
      ),
    );
  }
}

class _NoProfiles extends StatelessWidget {
  const _NoProfiles();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🧸', style: TextStyle(fontSize: 64)),
          Text(
            'No learners yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Ask a parent to add your profile.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push('/parent'),
            child: const Text('Add a child'),
          ),
        ],
      ),
    ),
  );
}

class _Grid extends StatelessWidget {
  const _Grid(this.profiles);

  final List<ProfileRow> profiles;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Text(
              "Who's learning today?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: GridView.extent(
              maxCrossAxisExtent: 220,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                for (final p in profiles)
                  Card(
                    key: Key('profile-${p.id}'),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push('/kid/${p.id}'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(p.avatar, style: const TextStyle(fontSize: 64)),
                          const SizedBox(height: 8),
                          Text(
                            p.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
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
