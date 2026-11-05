import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/security/pin_hasher.dart';
import '../../ui/pin_boxes.dart';
import 'parent_providers.dart';

/// First launch: the parent creates the PIN that protects the parent area.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  final _confirmFocus = FocusNode();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!PinHasher.isValidNewPin(_pin.text) ||
        !PinHasher.isValidNewPin(_confirm.text)) {
      setState(() => _error = 'Enter all 6 digits.');
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(() => _error = 'The two PINs are different.');
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    await ref
        .read(parentRepositoryProvider)
        .create(_pin.text, now: ref.read(clockProvider)());
    if (!mounted) return;
    setState(() => _busy = false);
    ref.read(parentUnlockedProvider.notifier).unlock();
    context.go('/parent');
    context.push('/parent/profiles/new');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '👋',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 64),
                  ),
                  Text(
                    'Welcome to Voca Swiper',
                    textAlign: TextAlign.center,
                    style: text.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Parents: create a PIN. It protects settings and profiles '
                    'so children can only learn.',
                    textAlign: TextAlign.center,
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  PinBoxes(
                    key: const Key('setup-pin'),
                    controller: _pin,
                    autofocus: true,
                    label: 'New PIN (6 digits)',
                    onCompleted: (_) => _confirmFocus.requestFocus(),
                  ),
                  const SizedBox(height: 20),
                  PinBoxes(
                    key: const Key('setup-confirm'),
                    controller: _confirm,
                    focusNode: _confirmFocus,
                    label: 'Repeat PIN',
                    errorText: _error,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('setup-create'),
                    onPressed: _busy ? null : _create,
                    child: Text(_busy ? 'Creating…' : 'Create PIN'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
