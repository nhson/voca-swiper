import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/srs/word_state.dart';

/// JSON list ↔ TEXT column.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).cast<String>();
  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// JSON object ↔ TEXT column.
class StringMapConverter extends TypeConverter<Map<String, String>, String> {
  const StringMapConverter();
  @override
  Map<String, String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as Map).cast<String, String>();
  @override
  String toSql(Map<String, String> value) => jsonEncode(value);
}

// ---------- Shared, read-only word content (imported from the word bank) ----

@DataClassName('WordRow')
class Words extends Table {
  TextColumn get id => text()();
  TextColumn get word => text()();
  TextColumn get partOfSpeech => text()();

  /// 'preA1' | 'A1' | 'A2' | 'B1' | 'B2'
  TextColumn get cefrLevel => text()();

  /// 0 = preA1 … 4 = B2, for ordering and filtering.
  IntColumn get levelIndex => integer()();

  /// Teaching order within the level (1 = first).
  IntColumn get rank => integer()();
  IntColumn get minAge => integer()();
  TextColumn get themes => text().map(const StringListConverter())();
  TextColumn get emoji => text().nullable()();
  TextColumn get definition => text()();
  TextColumn get examples => text().map(const StringListConverter())();
  TextColumn get forms => text().map(const StringMapConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TranslationRow')
class Translations extends Table {
  TextColumn get wordId => text().references(Words, #id)();
  TextColumn get languageCode => text()();
  TextColumn get translation => text()();

  @override
  Set<Column> get primaryKey => {wordId, languageCode};
}

// ---------- Parent and profiles ----------

@DataClassName('ParentAccountRow')
class ParentAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pinHash => text()();
  TextColumn get pinSalt => text()();

  /// Daily reminder, minutes after local midnight. Null = reminders off.
  IntColumn get reminderMinuteOfDay => integer().nullable()();

  /// Quiet hours (no reminders), minutes after local midnight.
  IntColumn get quietStartMinute =>
      integer().withDefault(const Constant(21 * 60))();
  IntColumn get quietEndMinute =>
      integer().withDefault(const Constant(7 * 60))();

  /// Block reminders Mon–Fri during school hours.
  BoolColumn get blockSchoolHours =>
      boolean().withDefault(const Constant(true))();
  IntColumn get schoolStartMinute =>
      integer().withDefault(const Constant(7 * 60 + 30))();
  IntColumn get schoolEndMinute =>
      integer().withDefault(const Constant(16 * 60 + 30))();
  DateTimeColumn get createdAt => dateTime()();
}

enum TranslationMode { always, tap, hidden }

@DataClassName('ProfileRow')
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 30)();
  TextColumn get avatar => text()();
  IntColumn get age => integer()();
  TextColumn get nativeLanguage => text().withDefault(const Constant('vi'))();
  TextColumn get currentLevel => text()();
  IntColumn get dailyNewWords => integer().withDefault(const Constant(5))();
  IntColumn get dailyMinutes => integer().withDefault(const Constant(10))();
  TextColumn get translationMode => textEnum<TranslationMode>()();

  /// true: swipe right = "knew it" (default); false: flipped.
  BoolColumn get swipeKnownRight =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  /// Favourite themes (word-bank theme ids), preferred for new words.
  TextColumn get interests => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  /// When placement finished or was skipped (feat-015). Null = the child
  /// takes the placement test on next open.
  DateTimeColumn get onboardedAt => dateTime().nullable()();

  /// Parent locked the level: no automatic level-up, preview or step-back
  /// suggestion (feat-016).
  BoolColumn get levelLocked => boolean().withDefault(const Constant(false))();

  /// When the level last changed after placement (level-up, step back or
  /// the parent). Null = unchanged since placement / creation.
  DateTimeColumn get levelChangedAt => dateTime().nullable()();

  /// The parent's "not now" on a step-back suggestion.
  DateTimeColumn get stepBackDismissedAt => dateTime().nullable()();
}

// ---------- Per-profile progress ----------

@DataClassName('WordProgressRow')
class WordProgress extends Table {
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  /// No FK to [Words]: word-bank updates must never drop a child's progress.
  TextColumn get wordId => text()();
  TextColumn get state => textEnum<WordState>()();
  RealColumn get easeFactor => real()();
  IntColumn get intervalDays => integer()();
  IntColumn get repetitions => integer()();
  DateTimeColumn get nextReviewAt => dateTime().nullable()();
  DateTimeColumn get lastAnsweredAt => dateTime().nullable()();
  IntColumn get correctCount => integer()();
  IntColumn get wrongCount => integer()();
  DateTimeColumn get firstSeenAt => dateTime()();

  @override
  Set<Column> get primaryKey => {profileId, wordId};
}

@DataClassName('SessionLogRow')
class SessionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationSec => integer()();
  IntColumn get reviewed => integer()();
  IntColumn get newLearned => integer()();

  /// Share of first answers that were passes, 0–1.
  RealColumn get accuracy => real()();
}

/// Every quiz answer (feat-013), for the "remembered after 2 weeks" metric.
@DataClassName('QuizLogRow')
class QuizLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  /// No FK to [Words], like [WordProgress].
  TextColumn get wordId => text()();

  /// QuizKind name: pickPicture | chooseMeaning | spell.
  TextColumn get kind => text()();
  BoolColumn get correct => boolean()();
  DateTimeColumn get answeredAt => dateTime()();
}

/// Words a parent added for one child (feat-018). A word found in the bank
/// keeps [wordId]; otherwise this row holds the content and the word's id is
/// `custom:<id>`.
@DataClassName('CustomWordRow')
class CustomWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  /// Bank word id when matched; null for the parent's own word.
  TextColumn get wordId => text().nullable()();

  /// The word as matched (normalized: lower case, single spaces).
  TextColumn get word => text()();
  TextColumn get definition => text().withDefault(const Constant(''))();
  TextColumn get translation => text().nullable()();
  TextColumn get emoji => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
}

/// Key–value app metadata (e.g. imported word-bank version).
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
