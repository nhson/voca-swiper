import 'package:drift/drift.dart';

import '../../core/security/pin_hasher.dart';
import '../db/app_database.dart';

class ParentRepository {
  ParentRepository(this.db, {this.hasher = const PinHasher()});

  final AppDatabase db;
  final PinHasher hasher;

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
    await db.into(db.parentAccounts).insert(
          ParentAccountsCompanion.insert(
            pinHash: hasher.hash(pin, salt),
            pinSalt: salt,
            createdAt: now,
          ),
        );
  }

  Future<bool> verifyPin(String pin) async {
    final a = await account();
    return a != null && hasher.verify(pin, salt: a.pinSalt, hash: a.pinHash);
  }

  Future<void> changePin(String newPin) async {
    if (!PinHasher.isValidPin(newPin)) {
      throw ArgumentError.value(newPin, 'pin', 'must be 4–6 digits');
    }
    final a = (await account())!;
    final salt = hasher.newSalt();
    await (db.update(db.parentAccounts)..where((p) => p.id.equals(a.id))).write(
      ParentAccountsCompanion(
        pinHash: Value(hasher.hash(newPin, salt)),
        pinSalt: Value(salt),
      ),
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
