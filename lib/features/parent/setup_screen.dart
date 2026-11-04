import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/security/pin_hasher.dart';
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
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!PinHasher.isValidPin(_pin.text)) {
      setState(() => _error = 'Use 4 to 6 digits.');
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
                  TextField(
                    key: const Key('setup-pin'),
                    controller: _pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'New PIN (4–6 digits)',
                    ),
                  ),
                  TextField(
                    key: const Key('setup-confirm'),
                    controller: _confirm,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Repeat PIN',
                      errorText: _error,
                    ),
                  ),
                  const SizedBox(height: 16),
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
