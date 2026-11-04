import 'dart:isolate';

import 'package:drift/drift.dart';

import '../../core/security/pin_hasher.dart';
import '../db/app_database.dart';

/// Runs CPU-heavy work (PIN hashing) off the UI isolate.
typedef HeavyRunner = Future<T> Function<T>(T Function() work);

Future<T> _isolateRun<T>(T Function() work) => Isolate.run(work);

/// Runs work inline; for tests, where a real isolate can't be awaited.
Future<T> runInline<T>(T Function() work) async => work();

class ParentRepository {
  ParentRepository(this.db, {this.hasher = const PinHasher(), HeavyRunner? run})
    : _run = run ?? _isolateRun;

  final AppDatabase db;
  final PinHasher hasher;
  final HeavyRunner _run;

  Future<String> _hash(String pin, String salt) {
    final h = hasher;
    return _run(() => h.hash(pin, salt));
  }

  Future<ParentAccountRow?> account() =>
      (db.select(db.parentAccounts)..limit(1)).getSingleOrNull();

  Stream<ParentAccountRow?> watchAccount() =>
      (db.select(db.parentAccounts)..limit(1)).watchSingleOrNull();

  Future<void> create(String pin, {required DateTime now}) async {
    if (!PinHasher.isValidPin(pin)) {
      throw ArgumentError.value(pin, 'pin', 'must be 4–6 digits');
    }
    if (await account() != null) throw StateError('Parent account exists');
    final salt = hasher.newSalt();
    final pinHash = await _hash(pin, salt);
    await db
        .into(db.parentAccounts)
        .insert(
          ParentAccountsCompanion.insert(
            pinHash: pinHash,
            pinSalt: salt,
            createdAt: now,
          ),
        );
  }

  Future<bool> verifyPin(String pin) async {
    final a = await account();
    if (a == null) return false;
    final h = hasher;
    return _run(() => h.verify(pin, salt: a.pinSalt, hash: a.pinHash));
  }

  Future<void> changePin(String newPin) async {
    if (!PinHasher.isValidPin(newPin)) {
      throw ArgumentError.value(newPin, 'pin', 'must be 4–6 digits');
    }
    final a = (await account())!;
    final salt = hasher.newSalt();
    final pinHash = await _hash(newPin, salt);
    await (db.update(db.parentAccounts)..where((p) => p.id.equals(a.id))).write(
      ParentAccountsCompanion(pinHash: Value(pinHash), pinSalt: Value(salt)),
    );
  }

  Future<void> updateReminders({
    required int? reminderMinuteOfDay,
    required int quietStartMinute,
    required int quietEndMinute,
    required bool blockSchoolHours,
    required int schoolStartMinute,
    required int schoolEndMinute,
  }) async {
    final a = (await account())!;
    await (db.update(db.parentAccounts)..where((p) => p.id.equals(a.id))).write(
      ParentAccountsCompanion(
        reminderMinuteOfDay: Value(reminderMinuteOfDay),
        quietStartMinute: Value(quietStartMinute),
        quietEndMinute: Value(quietEndMinute),
        blockSchoolHours: Value(blockSchoolHours),
        schoolStartMinute: Value(schoolStartMinute),
        schoolEndMinute: Value(schoolEndMinute),
      ),
    );
  }
}
