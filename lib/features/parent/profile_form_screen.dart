import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/levels.dart';
import '../../core/session/session_builder.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/profile_repository.dart';
import '../profiles/profile_providers.dart';
import '../../ui/readable_width.dart';
import '../reminders/reminder_service.dart';
import 'pin_gate.dart';

/// Levels that have content in the bundled bank.
const availableLevels = [
  CefrLevel.preA1,
  CefrLevel.a1,
  CefrLevel.a2,
  CefrLevel.b1,
];

/// Create ([profileId] == null) or edit a child profile.
class ProfileFormScreen extends ConsumerWidget {
  const ProfileFormScreen({super.key, this.profileId});

  final int? profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = profileId;
    if (id == null) return const ParentGate(child: _ProfileForm());
    final profile = ref.watch(profileProvider(id));
    return ParentGate(
      child: profile.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
        data: (p) => p == null
            ? const Scaffold(body: Center(child: Text('Profile not found')))
            : _ProfileForm(existing: p),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({this.existing});

  final ProfileRow? existing;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _name;
  late String _avatar;
  late int _age;
  late CefrLevel _level;
  late int _dailyNewWords;
  late int _dailyMinutes;
  late TranslationMode _translation;
  late bool _swipeKnownRight;
  bool _levelTouched = false;
  bool _translationTouched = false;
  String? _nameError;

  bool get _isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final d = e == null ? null : ProfileDraft.fromRow(e);
    _name = TextEditingController(text: d?.name ?? '');
    _avatar = d?.avatar ?? avatars.first;
    _age = d?.age ?? 6;
    _level = d?.level ?? CefrLevel.defaultForAge(_age);
    _dailyNewWords = d?.dailyNewWords ?? 5;
    _dailyMinutes = d?.dailyMinutes ?? 10;
    _translation =
        d?.translationMode ?? ProfileDraft.defaultTranslationMode(_level);
    _swipeKnownRight = d?.swipeKnownRight ?? true;
    _levelTouched = !_isNew;
    _translationTouched = !_isNew;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _setAge(int age) => setState(() {
    _age = age;
    if (!_levelTouched) _setLevel(CefrLevel.defaultForAge(age), touch: false);
  });

  void _setLevel(CefrLevel level, {bool touch = true}) {
    _level = level;
    if (touch) _levelTouched = true;
    if (!_translationTouched) {
      _translation = ProfileDraft.defaultTranslationMode(level);
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || name.length > 30) {
      setState(() => _nameError = 'Enter a first name or nickname.');
      return;
    }
    final draft = ProfileDraft(
      name: name,
      avatar: _avatar,
      age: _age,
      level: _level,
      dailyNewWords: _dailyNewWords,
      dailyMinutes: _dailyMinutes,
      translationMode: _translation,
      swipeKnownRight: _swipeKnownRight,
    );
    final repo = ref.read(profileRepositoryProvider);
    if (_isNew) {
      await repo.create(draft, now: ref.read(clockProvider)());
    } else {
      await repo.update(widget.existing!.id, draft);
    }
    // Names appear in reminder text.
    unawaited(ref.read(reminderServiceProvider).refresh());
    if (mounted) _leave();
  }

  void _leave() => context.canPop() ? context.pop() : context.go('/parent');

  Future<void> _confirm(
    String title,
    String body,
    Future<void> Function() action, {
    bool popAfter = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm'),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await action();
    unawaited(ref.read(reminderServiceProvider).refresh());
    if (mounted && popAfter) _leave();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final existing = widget.existing;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add child' : 'Edit ${existing!.name}'),
      ),
      body: ListView(
        key: const Key('profile-form'),
        padding: readablePadding(context),
        children: [
          TextField(
            key: const Key('name-field'),
            controller: _name,
            textCapitalization: TextCapitalization.words,
            maxLength: 30,
            decoration: InputDecoration(
              labelText: 'First name or nickname',
              errorText: _nameError,
            ),
          ),
          Text('Avatar', style: text.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in avatars)
                ChoiceChip(
                  label: Text(a, style: const TextStyle(fontSize: 28)),
                  selected: a == _avatar,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _avatar = a),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Age: $_age', style: text.titleSmall),
          Slider(
            key: const Key('age-slider'),
            value: _age.toDouble(),
            min: 4,
            max: 15,
            divisions: 11,
            label: '$_age',
            onChanged: (v) => _setAge(v.round()),
          ),
          Text('Level', style: text.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<CefrLevel>(
            key: const Key('level'),
            showSelectedIcon: false,
            segments: [
              for (final l in availableLevels)
                ButtonSegment(value: l, label: Text(l.label)),
            ],
            selected: {_level},
            onSelectionChanged: (s) => setState(() => _setLevel(s.first)),
          ),
          const SizedBox(height: 4),
          Text(
            'A2 and B1 are for ages 7+ and show grammar forms '
            '(went, bigger…).',
            style: text.bodySmall,
          ),
          const SizedBox(height: 16),
          Text('New words per day: $_dailyNewWords', style: text.titleSmall),
          Slider(
            key: const Key('daily-new'),
            value: _dailyNewWords.toDouble(),
            min: 5,
            max: 15,
            divisions: 10,
            label: '$_dailyNewWords',
            onChanged: (v) => setState(() => _dailyNewWords = v.round()),
          ),
          Text('Minutes per day: $_dailyMinutes', style: text.titleSmall),
          Slider(
            value: _dailyMinutes.toDouble(),
            min: 5,
            max: 30,
            divisions: 5,
            label: '$_dailyMinutes',
            onChanged: (v) => setState(() => _dailyMinutes = v.round()),
          ),
          Text(
            'Each session shows up to '
            '${SessionBuilder.cardsForMinutes(_dailyMinutes)} cards. When '
            'more reviews are waiting, the oldest go first and new words '
            'pause until the child catches up.',
            key: const Key('minutes-hint'),
            style: text.bodySmall,
          ),
          const SizedBox(height: 8),
          Text('Vietnamese translation', style: text.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<TranslationMode>(
            segments: const [
              ButtonSegment(value: TranslationMode.always, label: Text('Show')),
              ButtonSegment(value: TranslationMode.tap, label: Text('Tap')),
              ButtonSegment(value: TranslationMode.hidden, label: Text('Hide')),
            ],
            selected: {_translation},
            onSelectionChanged: (s) => setState(() {
              _translation = s.first;
              _translationTouched = true;
            }),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            key: const Key('swipe-direction'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Swipe right means "I knew it"'),
            subtitle: Text(
              _swipeKnownRight
                  ? 'Right = knew it, left = didn\'t know'
                  : 'Left = knew it, right = didn\'t know',
            ),
            value: _swipeKnownRight,
            onChanged: (v) => setState(() => _swipeKnownRight = v),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('save-profile'),
            onPressed: _save,
            child: const Text('Save'),
          ),
          if (existing != null) ...[
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset progress'),
              onPressed: () => _confirm(
                'Reset ${existing.name}\'s progress?',
                'All learned words and history for this child are cleared. '
                    'Settings stay.',
                () => ref
                    .read(profileRepositoryProvider)
                    .resetProgress(existing.id),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('delete-profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete profile'),
              onPressed: () => _confirm(
                'Delete ${existing.name}?',
                'The profile and all its progress are deleted. This cannot be '
                    'undone.',
                () => ref.read(profileRepositoryProvider).delete(existing.id),
                popAfter: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
