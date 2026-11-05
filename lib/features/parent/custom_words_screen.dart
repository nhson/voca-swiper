import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/custom_words.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/custom_word_repository.dart';
import '../../data/repositories/word_repository.dart';
import '../../ui/readable_width.dart';
import '../profiles/profile_providers.dart';
import 'pin_gate.dart';

final customWordRepositoryProvider = Provider(
  (ref) => CustomWordRepository(ref.watch(databaseProvider)),
);

/// A child's custom words with their cards (bank content for matched ones).
final customWordsProvider = StreamProvider.autoDispose
    .family<List<(CustomWordRow, WordCard?)>, int>((ref, profileId) async* {
      final repo = ref.watch(customWordRepositoryProvider);
      final words = ref.watch(wordRepositoryProvider);
      final profile = await ref.watch(profileRepositoryProvider).get(profileId);
      final lang = profile?.nativeLanguage ?? 'vi';
      await for (final rows in repo.watch(profileId)) {
        final cards = {
          for (final c in await words.cards([
            for (final r in rows) effectiveWordId(r),
          ], language: lang))
            c.word.id: c,
        };
        yield [for (final r in rows) (r, cards[effectiveWordId(r)])];
      }
    });

/// Words a parent added from homework or books (feat-018).
class CustomWordsScreen extends ConsumerWidget {
  const CustomWordsScreen({super.key, required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileProvider(profileId)).value?.name ?? '';
    final words = ref.watch(customWordsProvider(profileId)).value;
    final text = Theme.of(context).textTheme;
    return ParentGate(
      child: Scaffold(
        appBar: AppBar(title: Text("$name's word list")),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('cw-add'),
          onPressed: () =>
              context.push('/parent/profiles/$profileId/words/new'),
          icon: const Icon(Icons.add),
          label: const Text('Add word'),
        ),
        body: words == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                key: const Key('cw-list'),
                padding: readablePadding(context, bottom: 96),
                children: [
                  Text(
                    'Words from homework or books. They come first among '
                    "$name's new words.",
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  if (words.isEmpty)
                    const Card(
                      child: ListTile(
                        key: Key('cw-empty'),
                        title: Text('No words yet. Tap "Add word".'),
                      ),
                    ),
                  for (final (row, card) in words)
                    Card(
                      child: ListTile(
                        key: Key('cw-row-${row.id}'),
                        leading: Text(
                          card?.word.emoji ?? '📝',
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Text(card?.word.word ?? row.word),
                        subtitle: Text(
                          [
                            ?card?.translation,
                            row.wordId == null ? 'your word' : 'from word bank',
                          ].join(' · '),
                        ),
                        onTap: row.wordId == null
                            ? () => context.push(
                                '/parent/profiles/$profileId/words/${row.id}',
                              )
                            : null,
                        trailing: IconButton(
                          key: Key('cw-delete-${row.id}'),
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(context, ref, row),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CustomWordRow row,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Remove "${row.word}"?'),
        content: Text(
          row.wordId == null
              ? 'The word and what the child learned of it are removed.'
              : 'It leaves the list. Progress on it is kept, as it is also '
                    'in the word bank.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm'),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(customWordRepositoryProvider).delete(row.id);
    }
  }
}

/// Emoji offered for the parent's own words; any emoji can also be typed.
const customEmojiChoices = [
  '⭐', '🦖', '🚀', '🐉', '🦄', '🏰', '🎂', '🧩', '🎈', '🌈', //
  '🐙', '🦋', '🌋', '🧲', '🔭', '🎻', '⚽', '🍕', '🍉', '📚',
];

/// Add ([customId] == null) or edit a custom word.
class CustomWordFormScreen extends ConsumerStatefulWidget {
  const CustomWordFormScreen({
    super.key,
    required this.profileId,
    this.customId,
  });

  final int profileId;
  final int? customId;

  @override
  ConsumerState<CustomWordFormScreen> createState() =>
      _CustomWordFormScreenState();
}

class _CustomWordFormScreenState extends ConsumerState<CustomWordFormScreen> {
  final _word = TextEditingController();
  final _definition = TextEditingController();
  final _translation = TextEditingController();
  final _emoji = TextEditingController();
  WordRow? _match;
  int _lookup = 0;
  String? _wordError;
  String? _meaningError;
  bool _loaded = false;

  bool get _isNew => widget.customId == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.customId;
    if (id != null) {
      final row = await ref.read(customWordRepositoryProvider).get(id);
      if (row != null) {
        _word.text = row.word;
        _definition.text = row.definition;
        _translation.text = row.translation ?? '';
        _emoji.text = row.emoji ?? '';
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _word.dispose();
    _definition.dispose();
    _translation.dispose();
    _emoji.dispose();
    super.dispose();
  }

  Future<void> _onWordChanged(String text) async {
    if (!_isNew) return;
    final token = ++_lookup;
    final m = await ref.read(customWordRepositoryProvider).match(text);
    if (mounted && token == _lookup) setState(() => _match = m);
  }

  Future<void> _save() async {
    final wordError = validateCustomWord(_word.text);
    final meaningError =
        validateCustomMeaning(_definition.text) ??
        validateCustomMeaning(_translation.text);
    setState(() {
      _wordError = wordError;
      _meaningError = meaningError;
    });
    if (wordError != null || meaningError != null) return;
    final repo = ref.read(customWordRepositoryProvider);
    try {
      if (_isNew) {
        await repo.add(
          widget.profileId,
          text: _word.text,
          definition: _definition.text,
          translation: _translation.text,
          emoji: _emoji.text,
          now: ref.read(clockProvider)(),
        );
      } else {
        await repo.update(
          widget.customId!,
          text: _word.text,
          definition: _definition.text,
          translation: _translation.text,
          emoji: _emoji.text,
        );
      }
    } on DuplicateCustomWord {
      setState(() => _wordError = 'Already in the list.');
      return;
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final m = _match;
    return ParentGate(
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'Add a word' : 'Edit word')),
        body: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                key: const Key('cw-form'),
                padding: readablePadding(context),
                children: [
                  TextField(
                    key: const Key('cw-word'),
                    controller: _word,
                    autofocus: _isNew,
                    maxLength: maxCustomWordLength,
                    decoration: InputDecoration(
                      labelText: 'English word',
                      errorText: _wordError,
                    ),
                    onChanged: _onWordChanged,
                  ),
                  if (m != null)
                    Card(
                      key: const Key('cw-match'),
                      child: ListTile(
                        leading: Text(
                          m.emoji ?? '📘',
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Text('In the word bank: ${m.word}'),
                        subtitle: const Text(
                          'Its picture, meaning and translation are used.',
                        ),
                      ),
                    )
                  else ...[
                    TextField(
                      key: const Key('cw-definition'),
                      controller: _definition,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Short meaning in simple English',
                        hintText: 'A very big animal from long ago.',
                        errorText: _meaningError,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('cw-translation'),
                      controller: _translation,
                      decoration: const InputDecoration(
                        labelText: 'Vietnamese',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Picture', style: text.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final e in customEmojiChoices)
                          ChoiceChip(
                            key: Key('cw-emoji-$e'),
                            label: Text(
                              e,
                              style: const TextStyle(fontSize: 22),
                            ),
                            selected: _emoji.text == e,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => _emoji.text = e),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('cw-emoji'),
                      controller: _emoji,
                      maxLength: 8,
                      decoration: const InputDecoration(
                        labelText: 'Or type any emoji',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    Text(
                      'The word is read aloud by the device voice.',
                      style: text.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('cw-save'),
                    onPressed: _save,
                    child: Text(_isNew ? 'Add' : 'Save'),
                  ),
                ],
              ),
      ),
    );
  }
}
