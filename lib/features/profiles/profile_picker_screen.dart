import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/app_database.dart';
import '../parent/parent_providers.dart';
import '../parent/setup_screen.dart';
import '../../ui/chunky_button.dart';
import '../../ui/kid_look.dart';
import '../../ui/kid_screen.dart';
import '../../ui/mascot.dart';
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
    return KidScreen(
      look: KidLook.sunny,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _ParentsButton(onTap: () => context.push('/parent')),
            ),
          ),
          Expanded(
            child: profiles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => list.isEmpty ? const _NoProfiles() : _Grid(list),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentsButton extends StatelessWidget {
  const _ParentsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: 0.85),
    shape: const StadiumBorder(),
    child: InkWell(
      key: const Key('open-parent'),
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, size: 18, color: KidColors.inkSoft),
            SizedBox(width: 6),
            Text(
              'Parents',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: KidColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
          const Mascot(mood: MascotMood.happy, size: 150),
          const SizedBox(height: 8),
          Text(
            'No learners yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Ask a parent to add your profile.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          ChunkyButton(
            onPressed: () => context.push('/parent'),
            color: KidLook.sunny.accent,
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

  static const _tileColors = [
    Color(0xFFFF8A65),
    Color(0xFF7B5CFF),
    Color(0xFF22C48A),
    Color(0xFF4FA9FF),
    Color(0xFFFF6FA5),
    Color(0xFFFFB627),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        const Mascot(mood: MascotMood.happy, size: 110),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
          child: Text(
            "Who's learning today?",
            textAlign: TextAlign.center,
            style: text.headlineLarge,
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 18,
                runSpacing: 18,
                children: [
                  for (final p in profiles)
                    _ProfileTile(
                      key: Key('profile-${p.id}'),
                      profile: p,
                      color: _tileColors[p.id % _tileColors.length],
                      onTap: () => context.push('/kid/${p.id}'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    super.key,
    required this.profile,
    required this.color,
    required this.onTap,
  });

  final ProfileRow profile;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: profile.name,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 150,
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border(
              bottom: BorderSide(color: KidColors.shade(color, 0.1), width: 6),
            ),
            boxShadow: [
              BoxShadow(
                color: KidColors.ink.withValues(alpha: 0.14),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.18),
                  border: Border.all(color: color, width: 4),
                ),
                child: Text(
                  profile.avatar,
                  style: const TextStyle(fontSize: 52),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
