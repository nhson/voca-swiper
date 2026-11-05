// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WordsTable extends Words with TableInfo<$WordsTable, WordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cefrLevelMeta = const VerificationMeta(
    'cefrLevel',
  );
  @override
  late final GeneratedColumn<String> cefrLevel = GeneratedColumn<String>(
    'cefr_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelIndexMeta = const VerificationMeta(
    'levelIndex',
  );
  @override
  late final GeneratedColumn<int> levelIndex = GeneratedColumn<int>(
    'level_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minAgeMeta = const VerificationMeta('minAge');
  @override
  late final GeneratedColumn<int> minAge = GeneratedColumn<int>(
    'min_age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> themes =
      GeneratedColumn<String>(
        'themes',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($WordsTable.$converterthemes);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> examples =
      GeneratedColumn<String>(
        'examples',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($WordsTable.$converterexamples);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  forms = GeneratedColumn<String>(
    'forms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, String>>($WordsTable.$converterforms);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    partOfSpeech,
    cefrLevel,
    levelIndex,
    rank,
    minAge,
    themes,
    emoji,
    definition,
    examples,
    forms,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partOfSpeechMeta);
    }
    if (data.containsKey('cefr_level')) {
      context.handle(
        _cefrLevelMeta,
        cefrLevel.isAcceptableOrUnknown(data['cefr_level']!, _cefrLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_cefrLevelMeta);
    }
    if (data.containsKey('level_index')) {
      context.handle(
        _levelIndexMeta,
        levelIndex.isAcceptableOrUnknown(data['level_index']!, _levelIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_levelIndexMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    } else if (isInserting) {
      context.missing(_rankMeta);
    }
    if (data.containsKey('min_age')) {
      context.handle(
        _minAgeMeta,
        minAge.isAcceptableOrUnknown(data['min_age']!, _minAgeMeta),
      );
    } else if (isInserting) {
      context.missing(_minAgeMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      )!,
      cefrLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cefr_level'],
      )!,
      levelIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_index'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
      minAge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_age'],
      )!,
      themes: $WordsTable.$converterthemes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}themes'],
        )!,
      ),
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      ),
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      examples: $WordsTable.$converterexamples.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}examples'],
        )!,
      ),
      forms: $WordsTable.$converterforms.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forms'],
        )!,
      ),
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterthemes =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterexamples =
      const StringListConverter();
  static TypeConverter<Map<String, String>, String> $converterforms =
      const StringMapConverter();
}

class WordRow extends DataClass implements Insertable<WordRow> {
  final String id;
  final String word;
  final String partOfSpeech;

  /// 'preA1' | 'A1' | 'A2' | 'B1' | 'B2'
  final String cefrLevel;

  /// 0 = preA1 … 4 = B2, for ordering and filtering.
  final int levelIndex;

  /// Teaching order within the level (1 = first).
  final int rank;
  final int minAge;
  final List<String> themes;
  final String? emoji;
  final String definition;
  final List<String> examples;
  final Map<String, String> forms;
  const WordRow({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.cefrLevel,
    required this.levelIndex,
    required this.rank,
    required this.minAge,
    required this.themes,
    this.emoji,
    required this.definition,
    required this.examples,
    required this.forms,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['word'] = Variable<String>(word);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    map['cefr_level'] = Variable<String>(cefrLevel);
    map['level_index'] = Variable<int>(levelIndex);
    map['rank'] = Variable<int>(rank);
    map['min_age'] = Variable<int>(minAge);
    {
      map['themes'] = Variable<String>(
        $WordsTable.$converterthemes.toSql(themes),
      );
    }
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    map['definition'] = Variable<String>(definition);
    {
      map['examples'] = Variable<String>(
        $WordsTable.$converterexamples.toSql(examples),
      );
    }
    {
      map['forms'] = Variable<String>($WordsTable.$converterforms.toSql(forms));
    }
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      word: Value(word),
      partOfSpeech: Value(partOfSpeech),
      cefrLevel: Value(cefrLevel),
      levelIndex: Value(levelIndex),
      rank: Value(rank),
      minAge: Value(minAge),
      themes: Value(themes),
      emoji: emoji == null && nullToAbsent
          ? const Value.absent()
          : Value(emoji),
      definition: Value(definition),
      examples: Value(examples),
      forms: Value(forms),
    );
  }

  factory WordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordRow(
      id: serializer.fromJson<String>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
      cefrLevel: serializer.fromJson<String>(json['cefrLevel']),
      levelIndex: serializer.fromJson<int>(json['levelIndex']),
      rank: serializer.fromJson<int>(json['rank']),
      minAge: serializer.fromJson<int>(json['minAge']),
      themes: serializer.fromJson<List<String>>(json['themes']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      definition: serializer.fromJson<String>(json['definition']),
      examples: serializer.fromJson<List<String>>(json['examples']),
      forms: serializer.fromJson<Map<String, String>>(json['forms']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'word': serializer.toJson<String>(word),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
      'cefrLevel': serializer.toJson<String>(cefrLevel),
      'levelIndex': serializer.toJson<int>(levelIndex),
      'rank': serializer.toJson<int>(rank),
      'minAge': serializer.toJson<int>(minAge),
      'themes': serializer.toJson<List<String>>(themes),
      'emoji': serializer.toJson<String?>(emoji),
      'definition': serializer.toJson<String>(definition),
      'examples': serializer.toJson<List<String>>(examples),
      'forms': serializer.toJson<Map<String, String>>(forms),
    };
  }

  WordRow copyWith({
    String? id,
    String? word,
    String? partOfSpeech,
    String? cefrLevel,
    int? levelIndex,
    int? rank,
    int? minAge,
    List<String>? themes,
    Value<String?> emoji = const Value.absent(),
    String? definition,
    List<String>? examples,
    Map<String, String>? forms,
  }) => WordRow(
    id: id ?? this.id,
    word: word ?? this.word,
    partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    cefrLevel: cefrLevel ?? this.cefrLevel,
    levelIndex: levelIndex ?? this.levelIndex,
    rank: rank ?? this.rank,
    minAge: minAge ?? this.minAge,
    themes: themes ?? this.themes,
    emoji: emoji.present ? emoji.value : this.emoji,
    definition: definition ?? this.definition,
    examples: examples ?? this.examples,
    forms: forms ?? this.forms,
  );
  WordRow copyWithCompanion(WordsCompanion data) {
    return WordRow(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      cefrLevel: data.cefrLevel.present ? data.cefrLevel.value : this.cefrLevel,
      levelIndex: data.levelIndex.present
          ? data.levelIndex.value
          : this.levelIndex,
      rank: data.rank.present ? data.rank.value : this.rank,
      minAge: data.minAge.present ? data.minAge.value : this.minAge,
      themes: data.themes.present ? data.themes.value : this.themes,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      examples: data.examples.present ? data.examples.value : this.examples,
      forms: data.forms.present ? data.forms.value : this.forms,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordRow(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('cefrLevel: $cefrLevel, ')
          ..write('levelIndex: $levelIndex, ')
          ..write('rank: $rank, ')
          ..write('minAge: $minAge, ')
          ..write('themes: $themes, ')
          ..write('emoji: $emoji, ')
          ..write('definition: $definition, ')
          ..write('examples: $examples, ')
          ..write('forms: $forms')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    word,
    partOfSpeech,
    cefrLevel,
    levelIndex,
    rank,
    minAge,
    themes,
    emoji,
    definition,
    examples,
    forms,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordRow &&
          other.id == this.id &&
          other.word == this.word &&
          other.partOfSpeech == this.partOfSpeech &&
          other.cefrLevel == this.cefrLevel &&
          other.levelIndex == this.levelIndex &&
          other.rank == this.rank &&
          other.minAge == this.minAge &&
          other.themes == this.themes &&
          other.emoji == this.emoji &&
          other.definition == this.definition &&
          other.examples == this.examples &&
          other.forms == this.forms);
}

class WordsCompanion extends UpdateCompanion<WordRow> {
  final Value<String> id;
  final Value<String> word;
  final Value<String> partOfSpeech;
  final Value<String> cefrLevel;
  final Value<int> levelIndex;
  final Value<int> rank;
  final Value<int> minAge;
  final Value<List<String>> themes;
  final Value<String?> emoji;
  final Value<String> definition;
  final Value<List<String>> examples;
  final Value<Map<String, String>> forms;
  final Value<int> rowid;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.cefrLevel = const Value.absent(),
    this.levelIndex = const Value.absent(),
    this.rank = const Value.absent(),
    this.minAge = const Value.absent(),
    this.themes = const Value.absent(),
    this.emoji = const Value.absent(),
    this.definition = const Value.absent(),
    this.examples = const Value.absent(),
    this.forms = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordsCompanion.insert({
    required String id,
    required String word,
    required String partOfSpeech,
    required String cefrLevel,
    required int levelIndex,
    required int rank,
    required int minAge,
    required List<String> themes,
    this.emoji = const Value.absent(),
    required String definition,
    required List<String> examples,
    required Map<String, String> forms,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       word = Value(word),
       partOfSpeech = Value(partOfSpeech),
       cefrLevel = Value(cefrLevel),
       levelIndex = Value(levelIndex),
       rank = Value(rank),
       minAge = Value(minAge),
       themes = Value(themes),
       definition = Value(definition),
       examples = Value(examples),
       forms = Value(forms);
  static Insertable<WordRow> custom({
    Expression<String>? id,
    Expression<String>? word,
    Expression<String>? partOfSpeech,
    Expression<String>? cefrLevel,
    Expression<int>? levelIndex,
    Expression<int>? rank,
    Expression<int>? minAge,
    Expression<String>? themes,
    Expression<String>? emoji,
    Expression<String>? definition,
    Expression<String>? examples,
    Expression<String>? forms,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (cefrLevel != null) 'cefr_level': cefrLevel,
      if (levelIndex != null) 'level_index': levelIndex,
      if (rank != null) 'rank': rank,
      if (minAge != null) 'min_age': minAge,
      if (themes != null) 'themes': themes,
      if (emoji != null) 'emoji': emoji,
      if (definition != null) 'definition': definition,
      if (examples != null) 'examples': examples,
      if (forms != null) 'forms': forms,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordsCompanion copyWith({
    Value<String>? id,
    Value<String>? word,
    Value<String>? partOfSpeech,
    Value<String>? cefrLevel,
    Value<int>? levelIndex,
    Value<int>? rank,
    Value<int>? minAge,
    Value<List<String>>? themes,
    Value<String?>? emoji,
    Value<String>? definition,
    Value<List<String>>? examples,
    Value<Map<String, String>>? forms,
    Value<int>? rowid,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      levelIndex: levelIndex ?? this.levelIndex,
      rank: rank ?? this.rank,
      minAge: minAge ?? this.minAge,
      themes: themes ?? this.themes,
      emoji: emoji ?? this.emoji,
      definition: definition ?? this.definition,
      examples: examples ?? this.examples,
      forms: forms ?? this.forms,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (cefrLevel.present) {
      map['cefr_level'] = Variable<String>(cefrLevel.value);
    }
    if (levelIndex.present) {
      map['level_index'] = Variable<int>(levelIndex.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (minAge.present) {
      map['min_age'] = Variable<int>(minAge.value);
    }
    if (themes.present) {
      map['themes'] = Variable<String>(
        $WordsTable.$converterthemes.toSql(themes.value),
      );
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (examples.present) {
      map['examples'] = Variable<String>(
        $WordsTable.$converterexamples.toSql(examples.value),
      );
    }
    if (forms.present) {
      map['forms'] = Variable<String>(
        $WordsTable.$converterforms.toSql(forms.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('cefrLevel: $cefrLevel, ')
          ..write('levelIndex: $levelIndex, ')
          ..write('rank: $rank, ')
          ..write('minAge: $minAge, ')
          ..write('themes: $themes, ')
          ..write('emoji: $emoji, ')
          ..write('definition: $definition, ')
          ..write('examples: $examples, ')
          ..write('forms: $forms, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranslationsTable extends Translations
    with TableInfo<$TranslationsTable, TranslationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id)',
    ),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [wordId, languageCode, translation];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranslationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId, languageCode};
  @override
  TranslationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationRow(
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
    );
  }

  @override
  $TranslationsTable createAlias(String alias) {
    return $TranslationsTable(attachedDatabase, alias);
  }
}

class TranslationRow extends DataClass implements Insertable<TranslationRow> {
  final String wordId;
  final String languageCode;
  final String translation;
  const TranslationRow({
    required this.wordId,
    required this.languageCode,
    required this.translation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<String>(wordId);
    map['language_code'] = Variable<String>(languageCode);
    map['translation'] = Variable<String>(translation);
    return map;
  }

  TranslationsCompanion toCompanion(bool nullToAbsent) {
    return TranslationsCompanion(
      wordId: Value(wordId),
      languageCode: Value(languageCode),
      translation: Value(translation),
    );
  }

  factory TranslationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationRow(
      wordId: serializer.fromJson<String>(json['wordId']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      translation: serializer.fromJson<String>(json['translation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<String>(wordId),
      'languageCode': serializer.toJson<String>(languageCode),
      'translation': serializer.toJson<String>(translation),
    };
  }

  TranslationRow copyWith({
    String? wordId,
    String? languageCode,
    String? translation,
  }) => TranslationRow(
    wordId: wordId ?? this.wordId,
    languageCode: languageCode ?? this.languageCode,
    translation: translation ?? this.translation,
  );
  TranslationRow copyWithCompanion(TranslationsCompanion data) {
    return TranslationRow(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationRow(')
          ..write('wordId: $wordId, ')
          ..write('languageCode: $languageCode, ')
          ..write('translation: $translation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordId, languageCode, translation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationRow &&
          other.wordId == this.wordId &&
          other.languageCode == this.languageCode &&
          other.translation == this.translation);
}

class TranslationsCompanion extends UpdateCompanion<TranslationRow> {
  final Value<String> wordId;
  final Value<String> languageCode;
  final Value<String> translation;
  final Value<int> rowid;
  const TranslationsCompanion({
    this.wordId = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.translation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranslationsCompanion.insert({
    required String wordId,
    required String languageCode,
    required String translation,
    this.rowid = const Value.absent(),
  }) : wordId = Value(wordId),
       languageCode = Value(languageCode),
       translation = Value(translation);
  static Insertable<TranslationRow> custom({
    Expression<String>? wordId,
    Expression<String>? languageCode,
    Expression<String>? translation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (languageCode != null) 'language_code': languageCode,
      if (translation != null) 'translation': translation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranslationsCompanion copyWith({
    Value<String>? wordId,
    Value<String>? languageCode,
    Value<String>? translation,
    Value<int>? rowid,
  }) {
    return TranslationsCompanion(
      wordId: wordId ?? this.wordId,
      languageCode: languageCode ?? this.languageCode,
      translation: translation ?? this.translation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationsCompanion(')
          ..write('wordId: $wordId, ')
          ..write('languageCode: $languageCode, ')
          ..write('translation: $translation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParentAccountsTable extends ParentAccounts
    with TableInfo<$ParentAccountsTable, ParentAccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParentAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinSaltMeta = const VerificationMeta(
    'pinSalt',
  );
  @override
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
    'pin_salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderMinuteOfDayMeta =
      const VerificationMeta('reminderMinuteOfDay');
  @override
  late final GeneratedColumn<int> reminderMinuteOfDay = GeneratedColumn<int>(
    'reminder_minute_of_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quietStartMinuteMeta = const VerificationMeta(
    'quietStartMinute',
  );
  @override
  late final GeneratedColumn<int> quietStartMinute = GeneratedColumn<int>(
    'quiet_start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(21 * 60),
  );
  static const VerificationMeta _quietEndMinuteMeta = const VerificationMeta(
    'quietEndMinute',
  );
  @override
  late final GeneratedColumn<int> quietEndMinute = GeneratedColumn<int>(
    'quiet_end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7 * 60),
  );
  static const VerificationMeta _blockSchoolHoursMeta = const VerificationMeta(
    'blockSchoolHours',
  );
  @override
  late final GeneratedColumn<bool> blockSchoolHours = GeneratedColumn<bool>(
    'block_school_hours',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("block_school_hours" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _schoolStartMinuteMeta = const VerificationMeta(
    'schoolStartMinute',
  );
  @override
  late final GeneratedColumn<int> schoolStartMinute = GeneratedColumn<int>(
    'school_start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7 * 60 + 30),
  );
  static const VerificationMeta _schoolEndMinuteMeta = const VerificationMeta(
    'schoolEndMinute',
  );
  @override
  late final GeneratedColumn<int> schoolEndMinute = GeneratedColumn<int>(
    'school_end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(16 * 60 + 30),
  );
  static const VerificationMeta _weeklyRecapMeta = const VerificationMeta(
    'weeklyRecap',
  );
  @override
  late final GeneratedColumn<bool> weeklyRecap = GeneratedColumn<bool>(
    'weekly_recap',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weekly_recap" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pinHash,
    pinSalt,
    reminderMinuteOfDay,
    quietStartMinute,
    quietEndMinute,
    blockSchoolHours,
    schoolStartMinute,
    schoolEndMinute,
    weeklyRecap,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parent_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParentAccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('pin_salt')) {
      context.handle(
        _pinSaltMeta,
        pinSalt.isAcceptableOrUnknown(data['pin_salt']!, _pinSaltMeta),
      );
    } else if (isInserting) {
      context.missing(_pinSaltMeta);
    }
    if (data.containsKey('reminder_minute_of_day')) {
      context.handle(
        _reminderMinuteOfDayMeta,
        reminderMinuteOfDay.isAcceptableOrUnknown(
          data['reminder_minute_of_day']!,
          _reminderMinuteOfDayMeta,
        ),
      );
    }
    if (data.containsKey('quiet_start_minute')) {
      context.handle(
        _quietStartMinuteMeta,
        quietStartMinute.isAcceptableOrUnknown(
          data['quiet_start_minute']!,
          _quietStartMinuteMeta,
        ),
      );
    }
    if (data.containsKey('quiet_end_minute')) {
      context.handle(
        _quietEndMinuteMeta,
        quietEndMinute.isAcceptableOrUnknown(
          data['quiet_end_minute']!,
          _quietEndMinuteMeta,
        ),
      );
    }
    if (data.containsKey('block_school_hours')) {
      context.handle(
        _blockSchoolHoursMeta,
        blockSchoolHours.isAcceptableOrUnknown(
          data['block_school_hours']!,
          _blockSchoolHoursMeta,
        ),
      );
    }
    if (data.containsKey('school_start_minute')) {
      context.handle(
        _schoolStartMinuteMeta,
        schoolStartMinute.isAcceptableOrUnknown(
          data['school_start_minute']!,
          _schoolStartMinuteMeta,
        ),
      );
    }
    if (data.containsKey('school_end_minute')) {
      context.handle(
        _schoolEndMinuteMeta,
        schoolEndMinute.isAcceptableOrUnknown(
          data['school_end_minute']!,
          _schoolEndMinuteMeta,
        ),
      );
    }
    if (data.containsKey('weekly_recap')) {
      context.handle(
        _weeklyRecapMeta,
        weeklyRecap.isAcceptableOrUnknown(
          data['weekly_recap']!,
          _weeklyRecapMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParentAccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParentAccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      )!,
      pinSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_salt'],
      )!,
      reminderMinuteOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute_of_day'],
      ),
      quietStartMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_start_minute'],
      )!,
      quietEndMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_end_minute'],
      )!,
      blockSchoolHours: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}block_school_hours'],
      )!,
      schoolStartMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}school_start_minute'],
      )!,
      schoolEndMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}school_end_minute'],
      )!,
      weeklyRecap: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weekly_recap'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ParentAccountsTable createAlias(String alias) {
    return $ParentAccountsTable(attachedDatabase, alias);
  }
}

class ParentAccountRow extends DataClass
    implements Insertable<ParentAccountRow> {
  final int id;
  final String pinHash;
  final String pinSalt;

  /// Daily reminder, minutes after local midnight. Null = reminders off.
  final int? reminderMinuteOfDay;

  /// Quiet hours (no reminders), minutes after local midnight.
  final int quietStartMinute;
  final int quietEndMinute;

  /// Block reminders Mon–Fri during school hours.
  final bool blockSchoolHours;
  final int schoolStartMinute;
  final int schoolEndMinute;

  /// Weekly recap notification on Sundays (feat-019). Off by default.
  final bool weeklyRecap;
  final DateTime createdAt;
  const ParentAccountRow({
    required this.id,
    required this.pinHash,
    required this.pinSalt,
    this.reminderMinuteOfDay,
    required this.quietStartMinute,
    required this.quietEndMinute,
    required this.blockSchoolHours,
    required this.schoolStartMinute,
    required this.schoolEndMinute,
    required this.weeklyRecap,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pin_hash'] = Variable<String>(pinHash);
    map['pin_salt'] = Variable<String>(pinSalt);
    if (!nullToAbsent || reminderMinuteOfDay != null) {
      map['reminder_minute_of_day'] = Variable<int>(reminderMinuteOfDay);
    }
    map['quiet_start_minute'] = Variable<int>(quietStartMinute);
    map['quiet_end_minute'] = Variable<int>(quietEndMinute);
    map['block_school_hours'] = Variable<bool>(blockSchoolHours);
    map['school_start_minute'] = Variable<int>(schoolStartMinute);
    map['school_end_minute'] = Variable<int>(schoolEndMinute);
    map['weekly_recap'] = Variable<bool>(weeklyRecap);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ParentAccountsCompanion toCompanion(bool nullToAbsent) {
    return ParentAccountsCompanion(
      id: Value(id),
      pinHash: Value(pinHash),
      pinSalt: Value(pinSalt),
      reminderMinuteOfDay: reminderMinuteOfDay == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinuteOfDay),
      quietStartMinute: Value(quietStartMinute),
      quietEndMinute: Value(quietEndMinute),
      blockSchoolHours: Value(blockSchoolHours),
      schoolStartMinute: Value(schoolStartMinute),
      schoolEndMinute: Value(schoolEndMinute),
      weeklyRecap: Value(weeklyRecap),
      createdAt: Value(createdAt),
    );
  }

  factory ParentAccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParentAccountRow(
      id: serializer.fromJson<int>(json['id']),
      pinHash: serializer.fromJson<String>(json['pinHash']),
      pinSalt: serializer.fromJson<String>(json['pinSalt']),
      reminderMinuteOfDay: serializer.fromJson<int?>(
        json['reminderMinuteOfDay'],
      ),
      quietStartMinute: serializer.fromJson<int>(json['quietStartMinute']),
      quietEndMinute: serializer.fromJson<int>(json['quietEndMinute']),
      blockSchoolHours: serializer.fromJson<bool>(json['blockSchoolHours']),
      schoolStartMinute: serializer.fromJson<int>(json['schoolStartMinute']),
      schoolEndMinute: serializer.fromJson<int>(json['schoolEndMinute']),
      weeklyRecap: serializer.fromJson<bool>(json['weeklyRecap']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pinHash': serializer.toJson<String>(pinHash),
      'pinSalt': serializer.toJson<String>(pinSalt),
      'reminderMinuteOfDay': serializer.toJson<int?>(reminderMinuteOfDay),
      'quietStartMinute': serializer.toJson<int>(quietStartMinute),
      'quietEndMinute': serializer.toJson<int>(quietEndMinute),
      'blockSchoolHours': serializer.toJson<bool>(blockSchoolHours),
      'schoolStartMinute': serializer.toJson<int>(schoolStartMinute),
      'schoolEndMinute': serializer.toJson<int>(schoolEndMinute),
      'weeklyRecap': serializer.toJson<bool>(weeklyRecap),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ParentAccountRow copyWith({
    int? id,
    String? pinHash,
    String? pinSalt,
    Value<int?> reminderMinuteOfDay = const Value.absent(),
    int? quietStartMinute,
    int? quietEndMinute,
    bool? blockSchoolHours,
    int? schoolStartMinute,
    int? schoolEndMinute,
    bool? weeklyRecap,
    DateTime? createdAt,
  }) => ParentAccountRow(
    id: id ?? this.id,
    pinHash: pinHash ?? this.pinHash,
    pinSalt: pinSalt ?? this.pinSalt,
    reminderMinuteOfDay: reminderMinuteOfDay.present
        ? reminderMinuteOfDay.value
        : this.reminderMinuteOfDay,
    quietStartMinute: quietStartMinute ?? this.quietStartMinute,
    quietEndMinute: quietEndMinute ?? this.quietEndMinute,
    blockSchoolHours: blockSchoolHours ?? this.blockSchoolHours,
    schoolStartMinute: schoolStartMinute ?? this.schoolStartMinute,
    schoolEndMinute: schoolEndMinute ?? this.schoolEndMinute,
    weeklyRecap: weeklyRecap ?? this.weeklyRecap,
    createdAt: createdAt ?? this.createdAt,
  );
  ParentAccountRow copyWithCompanion(ParentAccountsCompanion data) {
    return ParentAccountRow(
      id: data.id.present ? data.id.value : this.id,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      pinSalt: data.pinSalt.present ? data.pinSalt.value : this.pinSalt,
      reminderMinuteOfDay: data.reminderMinuteOfDay.present
          ? data.reminderMinuteOfDay.value
          : this.reminderMinuteOfDay,
      quietStartMinute: data.quietStartMinute.present
          ? data.quietStartMinute.value
          : this.quietStartMinute,
      quietEndMinute: data.quietEndMinute.present
          ? data.quietEndMinute.value
          : this.quietEndMinute,
      blockSchoolHours: data.blockSchoolHours.present
          ? data.blockSchoolHours.value
          : this.blockSchoolHours,
      schoolStartMinute: data.schoolStartMinute.present
          ? data.schoolStartMinute.value
          : this.schoolStartMinute,
      schoolEndMinute: data.schoolEndMinute.present
          ? data.schoolEndMinute.value
          : this.schoolEndMinute,
      weeklyRecap: data.weeklyRecap.present
          ? data.weeklyRecap.value
          : this.weeklyRecap,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParentAccountRow(')
          ..write('id: $id, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('reminderMinuteOfDay: $reminderMinuteOfDay, ')
          ..write('quietStartMinute: $quietStartMinute, ')
          ..write('quietEndMinute: $quietEndMinute, ')
          ..write('blockSchoolHours: $blockSchoolHours, ')
          ..write('schoolStartMinute: $schoolStartMinute, ')
          ..write('schoolEndMinute: $schoolEndMinute, ')
          ..write('weeklyRecap: $weeklyRecap, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pinHash,
    pinSalt,
    reminderMinuteOfDay,
    quietStartMinute,
    quietEndMinute,
    blockSchoolHours,
    schoolStartMinute,
    schoolEndMinute,
    weeklyRecap,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParentAccountRow &&
          other.id == this.id &&
          other.pinHash == this.pinHash &&
          other.pinSalt == this.pinSalt &&
          other.reminderMinuteOfDay == this.reminderMinuteOfDay &&
          other.quietStartMinute == this.quietStartMinute &&
          other.quietEndMinute == this.quietEndMinute &&
          other.blockSchoolHours == this.blockSchoolHours &&
          other.schoolStartMinute == this.schoolStartMinute &&
          other.schoolEndMinute == this.schoolEndMinute &&
          other.weeklyRecap == this.weeklyRecap &&
          other.createdAt == this.createdAt);
}

class ParentAccountsCompanion extends UpdateCompanion<ParentAccountRow> {
  final Value<int> id;
  final Value<String> pinHash;
  final Value<String> pinSalt;
  final Value<int?> reminderMinuteOfDay;
  final Value<int> quietStartMinute;
  final Value<int> quietEndMinute;
  final Value<bool> blockSchoolHours;
  final Value<int> schoolStartMinute;
  final Value<int> schoolEndMinute;
  final Value<bool> weeklyRecap;
  final Value<DateTime> createdAt;
  const ParentAccountsCompanion({
    this.id = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.reminderMinuteOfDay = const Value.absent(),
    this.quietStartMinute = const Value.absent(),
    this.quietEndMinute = const Value.absent(),
    this.blockSchoolHours = const Value.absent(),
    this.schoolStartMinute = const Value.absent(),
    this.schoolEndMinute = const Value.absent(),
    this.weeklyRecap = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ParentAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String pinHash,
    required String pinSalt,
    this.reminderMinuteOfDay = const Value.absent(),
    this.quietStartMinute = const Value.absent(),
    this.quietEndMinute = const Value.absent(),
    this.blockSchoolHours = const Value.absent(),
    this.schoolStartMinute = const Value.absent(),
    this.schoolEndMinute = const Value.absent(),
    this.weeklyRecap = const Value.absent(),
    required DateTime createdAt,
  }) : pinHash = Value(pinHash),
       pinSalt = Value(pinSalt),
       createdAt = Value(createdAt);
  static Insertable<ParentAccountRow> custom({
    Expression<int>? id,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<int>? reminderMinuteOfDay,
    Expression<int>? quietStartMinute,
    Expression<int>? quietEndMinute,
    Expression<bool>? blockSchoolHours,
    Expression<int>? schoolStartMinute,
    Expression<int>? schoolEndMinute,
    Expression<bool>? weeklyRecap,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pinHash != null) 'pin_hash': pinHash,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (reminderMinuteOfDay != null)
        'reminder_minute_of_day': reminderMinuteOfDay,
      if (quietStartMinute != null) 'quiet_start_minute': quietStartMinute,
      if (quietEndMinute != null) 'quiet_end_minute': quietEndMinute,
      if (blockSchoolHours != null) 'block_school_hours': blockSchoolHours,
      if (schoolStartMinute != null) 'school_start_minute': schoolStartMinute,
      if (schoolEndMinute != null) 'school_end_minute': schoolEndMinute,
      if (weeklyRecap != null) 'weekly_recap': weeklyRecap,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ParentAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? pinHash,
    Value<String>? pinSalt,
    Value<int?>? reminderMinuteOfDay,
    Value<int>? quietStartMinute,
    Value<int>? quietEndMinute,
    Value<bool>? blockSchoolHours,
    Value<int>? schoolStartMinute,
    Value<int>? schoolEndMinute,
    Value<bool>? weeklyRecap,
    Value<DateTime>? createdAt,
  }) {
    return ParentAccountsCompanion(
      id: id ?? this.id,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      reminderMinuteOfDay: reminderMinuteOfDay ?? this.reminderMinuteOfDay,
      quietStartMinute: quietStartMinute ?? this.quietStartMinute,
      quietEndMinute: quietEndMinute ?? this.quietEndMinute,
      blockSchoolHours: blockSchoolHours ?? this.blockSchoolHours,
      schoolStartMinute: schoolStartMinute ?? this.schoolStartMinute,
      schoolEndMinute: schoolEndMinute ?? this.schoolEndMinute,
      weeklyRecap: weeklyRecap ?? this.weeklyRecap,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (pinSalt.present) {
      map['pin_salt'] = Variable<String>(pinSalt.value);
    }
    if (reminderMinuteOfDay.present) {
      map['reminder_minute_of_day'] = Variable<int>(reminderMinuteOfDay.value);
    }
    if (quietStartMinute.present) {
      map['quiet_start_minute'] = Variable<int>(quietStartMinute.value);
    }
    if (quietEndMinute.present) {
      map['quiet_end_minute'] = Variable<int>(quietEndMinute.value);
    }
    if (blockSchoolHours.present) {
      map['block_school_hours'] = Variable<bool>(blockSchoolHours.value);
    }
    if (schoolStartMinute.present) {
      map['school_start_minute'] = Variable<int>(schoolStartMinute.value);
    }
    if (schoolEndMinute.present) {
      map['school_end_minute'] = Variable<int>(schoolEndMinute.value);
    }
    if (weeklyRecap.present) {
      map['weekly_recap'] = Variable<bool>(weeklyRecap.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParentAccountsCompanion(')
          ..write('id: $id, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('reminderMinuteOfDay: $reminderMinuteOfDay, ')
          ..write('quietStartMinute: $quietStartMinute, ')
          ..write('quietEndMinute: $quietEndMinute, ')
          ..write('blockSchoolHours: $blockSchoolHours, ')
          ..write('schoolStartMinute: $schoolStartMinute, ')
          ..write('schoolEndMinute: $schoolEndMinute, ')
          ..write('weeklyRecap: $weeklyRecap, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nativeLanguageMeta = const VerificationMeta(
    'nativeLanguage',
  );
  @override
  late final GeneratedColumn<String> nativeLanguage = GeneratedColumn<String>(
    'native_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('vi'),
  );
  static const VerificationMeta _currentLevelMeta = const VerificationMeta(
    'currentLevel',
  );
  @override
  late final GeneratedColumn<String> currentLevel = GeneratedColumn<String>(
    'current_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyNewWordsMeta = const VerificationMeta(
    'dailyNewWords',
  );
  @override
  late final GeneratedColumn<int> dailyNewWords = GeneratedColumn<int>(
    'daily_new_words',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _dailyMinutesMeta = const VerificationMeta(
    'dailyMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyMinutes = GeneratedColumn<int>(
    'daily_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TranslationMode, String>
  translationMode = GeneratedColumn<String>(
    'translation_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TranslationMode>($ProfilesTable.$convertertranslationMode);
  static const VerificationMeta _swipeKnownRightMeta = const VerificationMeta(
    'swipeKnownRight',
  );
  @override
  late final GeneratedColumn<bool> swipeKnownRight = GeneratedColumn<bool>(
    'swipe_known_right',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("swipe_known_right" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> interests =
      GeneratedColumn<String>(
        'interests',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($ProfilesTable.$converterinterests);
  static const VerificationMeta _onboardedAtMeta = const VerificationMeta(
    'onboardedAt',
  );
  @override
  late final GeneratedColumn<DateTime> onboardedAt = GeneratedColumn<DateTime>(
    'onboarded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelLockedMeta = const VerificationMeta(
    'levelLocked',
  );
  @override
  late final GeneratedColumn<bool> levelLocked = GeneratedColumn<bool>(
    'level_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("level_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _levelChangedAtMeta = const VerificationMeta(
    'levelChangedAt',
  );
  @override
  late final GeneratedColumn<DateTime> levelChangedAt =
      GeneratedColumn<DateTime>(
        'level_changed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _stepBackDismissedAtMeta =
      const VerificationMeta('stepBackDismissedAt');
  @override
  late final GeneratedColumn<DateTime> stepBackDismissedAt =
      GeneratedColumn<DateTime>(
        'step_back_dismissed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    avatar,
    age,
    nativeLanguage,
    currentLevel,
    dailyNewWords,
    dailyMinutes,
    translationMode,
    swipeKnownRight,
    createdAt,
    interests,
    onboardedAt,
    levelLocked,
    levelChangedAt,
    stepBackDismissedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    } else if (isInserting) {
      context.missing(_avatarMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('native_language')) {
      context.handle(
        _nativeLanguageMeta,
        nativeLanguage.isAcceptableOrUnknown(
          data['native_language']!,
          _nativeLanguageMeta,
        ),
      );
    }
    if (data.containsKey('current_level')) {
      context.handle(
        _currentLevelMeta,
        currentLevel.isAcceptableOrUnknown(
          data['current_level']!,
          _currentLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentLevelMeta);
    }
    if (data.containsKey('daily_new_words')) {
      context.handle(
        _dailyNewWordsMeta,
        dailyNewWords.isAcceptableOrUnknown(
          data['daily_new_words']!,
          _dailyNewWordsMeta,
        ),
      );
    }
    if (data.containsKey('daily_minutes')) {
      context.handle(
        _dailyMinutesMeta,
        dailyMinutes.isAcceptableOrUnknown(
          data['daily_minutes']!,
          _dailyMinutesMeta,
        ),
      );
    }
    if (data.containsKey('swipe_known_right')) {
      context.handle(
        _swipeKnownRightMeta,
        swipeKnownRight.isAcceptableOrUnknown(
          data['swipe_known_right']!,
          _swipeKnownRightMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('onboarded_at')) {
      context.handle(
        _onboardedAtMeta,
        onboardedAt.isAcceptableOrUnknown(
          data['onboarded_at']!,
          _onboardedAtMeta,
        ),
      );
    }
    if (data.containsKey('level_locked')) {
      context.handle(
        _levelLockedMeta,
        levelLocked.isAcceptableOrUnknown(
          data['level_locked']!,
          _levelLockedMeta,
        ),
      );
    }
    if (data.containsKey('level_changed_at')) {
      context.handle(
        _levelChangedAtMeta,
        levelChangedAt.isAcceptableOrUnknown(
          data['level_changed_at']!,
          _levelChangedAtMeta,
        ),
      );
    }
    if (data.containsKey('step_back_dismissed_at')) {
      context.handle(
        _stepBackDismissedAtMeta,
        stepBackDismissedAt.isAcceptableOrUnknown(
          data['step_back_dismissed_at']!,
          _stepBackDismissedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      nativeLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_language'],
      )!,
      currentLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_level'],
      )!,
      dailyNewWords: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_new_words'],
      )!,
      dailyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_minutes'],
      )!,
      translationMode: $ProfilesTable.$convertertranslationMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}translation_mode'],
        )!,
      ),
      swipeKnownRight: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}swipe_known_right'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      interests: $ProfilesTable.$converterinterests.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}interests'],
        )!,
      ),
      onboardedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}onboarded_at'],
      ),
      levelLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}level_locked'],
      )!,
      levelChangedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}level_changed_at'],
      ),
      stepBackDismissedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}step_back_dismissed_at'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TranslationMode, String, String>
  $convertertranslationMode = const EnumNameConverter<TranslationMode>(
    TranslationMode.values,
  );
  static TypeConverter<List<String>, String> $converterinterests =
      const StringListConverter();
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int id;
  final String name;
  final String avatar;
  final int age;
  final String nativeLanguage;
  final String currentLevel;
  final int dailyNewWords;
  final int dailyMinutes;
  final TranslationMode translationMode;

  /// true: swipe right = "knew it" (default); false: flipped.
  final bool swipeKnownRight;
  final DateTime createdAt;

  /// Favourite themes (word-bank theme ids), preferred for new words.
  final List<String> interests;

  /// When placement finished or was skipped (feat-015). Null = the child
  /// takes the placement test on next open.
  final DateTime? onboardedAt;

  /// Parent locked the level: no automatic level-up, preview or step-back
  /// suggestion (feat-016).
  final bool levelLocked;

  /// When the level last changed after placement (level-up, step back or
  /// the parent). Null = unchanged since placement / creation.
  final DateTime? levelChangedAt;

  /// The parent's "not now" on a step-back suggestion.
  final DateTime? stepBackDismissedAt;
  const ProfileRow({
    required this.id,
    required this.name,
    required this.avatar,
    required this.age,
    required this.nativeLanguage,
    required this.currentLevel,
    required this.dailyNewWords,
    required this.dailyMinutes,
    required this.translationMode,
    required this.swipeKnownRight,
    required this.createdAt,
    required this.interests,
    this.onboardedAt,
    required this.levelLocked,
    this.levelChangedAt,
    this.stepBackDismissedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['avatar'] = Variable<String>(avatar);
    map['age'] = Variable<int>(age);
    map['native_language'] = Variable<String>(nativeLanguage);
    map['current_level'] = Variable<String>(currentLevel);
    map['daily_new_words'] = Variable<int>(dailyNewWords);
    map['daily_minutes'] = Variable<int>(dailyMinutes);
    {
      map['translation_mode'] = Variable<String>(
        $ProfilesTable.$convertertranslationMode.toSql(translationMode),
      );
    }
    map['swipe_known_right'] = Variable<bool>(swipeKnownRight);
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['interests'] = Variable<String>(
        $ProfilesTable.$converterinterests.toSql(interests),
      );
    }
    if (!nullToAbsent || onboardedAt != null) {
      map['onboarded_at'] = Variable<DateTime>(onboardedAt);
    }
    map['level_locked'] = Variable<bool>(levelLocked);
    if (!nullToAbsent || levelChangedAt != null) {
      map['level_changed_at'] = Variable<DateTime>(levelChangedAt);
    }
    if (!nullToAbsent || stepBackDismissedAt != null) {
      map['step_back_dismissed_at'] = Variable<DateTime>(stepBackDismissedAt);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      avatar: Value(avatar),
      age: Value(age),
      nativeLanguage: Value(nativeLanguage),
      currentLevel: Value(currentLevel),
      dailyNewWords: Value(dailyNewWords),
      dailyMinutes: Value(dailyMinutes),
      translationMode: Value(translationMode),
      swipeKnownRight: Value(swipeKnownRight),
      createdAt: Value(createdAt),
      interests: Value(interests),
      onboardedAt: onboardedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardedAt),
      levelLocked: Value(levelLocked),
      levelChangedAt: levelChangedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(levelChangedAt),
      stepBackDismissedAt: stepBackDismissedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(stepBackDismissedAt),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatar: serializer.fromJson<String>(json['avatar']),
      age: serializer.fromJson<int>(json['age']),
      nativeLanguage: serializer.fromJson<String>(json['nativeLanguage']),
      currentLevel: serializer.fromJson<String>(json['currentLevel']),
      dailyNewWords: serializer.fromJson<int>(json['dailyNewWords']),
      dailyMinutes: serializer.fromJson<int>(json['dailyMinutes']),
      translationMode: $ProfilesTable.$convertertranslationMode.fromJson(
        serializer.fromJson<String>(json['translationMode']),
      ),
      swipeKnownRight: serializer.fromJson<bool>(json['swipeKnownRight']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      interests: serializer.fromJson<List<String>>(json['interests']),
      onboardedAt: serializer.fromJson<DateTime?>(json['onboardedAt']),
      levelLocked: serializer.fromJson<bool>(json['levelLocked']),
      levelChangedAt: serializer.fromJson<DateTime?>(json['levelChangedAt']),
      stepBackDismissedAt: serializer.fromJson<DateTime?>(
        json['stepBackDismissedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'avatar': serializer.toJson<String>(avatar),
      'age': serializer.toJson<int>(age),
      'nativeLanguage': serializer.toJson<String>(nativeLanguage),
      'currentLevel': serializer.toJson<String>(currentLevel),
      'dailyNewWords': serializer.toJson<int>(dailyNewWords),
      'dailyMinutes': serializer.toJson<int>(dailyMinutes),
      'translationMode': serializer.toJson<String>(
        $ProfilesTable.$convertertranslationMode.toJson(translationMode),
      ),
      'swipeKnownRight': serializer.toJson<bool>(swipeKnownRight),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'interests': serializer.toJson<List<String>>(interests),
      'onboardedAt': serializer.toJson<DateTime?>(onboardedAt),
      'levelLocked': serializer.toJson<bool>(levelLocked),
      'levelChangedAt': serializer.toJson<DateTime?>(levelChangedAt),
      'stepBackDismissedAt': serializer.toJson<DateTime?>(stepBackDismissedAt),
    };
  }

  ProfileRow copyWith({
    int? id,
    String? name,
    String? avatar,
    int? age,
    String? nativeLanguage,
    String? currentLevel,
    int? dailyNewWords,
    int? dailyMinutes,
    TranslationMode? translationMode,
    bool? swipeKnownRight,
    DateTime? createdAt,
    List<String>? interests,
    Value<DateTime?> onboardedAt = const Value.absent(),
    bool? levelLocked,
    Value<DateTime?> levelChangedAt = const Value.absent(),
    Value<DateTime?> stepBackDismissedAt = const Value.absent(),
  }) => ProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    avatar: avatar ?? this.avatar,
    age: age ?? this.age,
    nativeLanguage: nativeLanguage ?? this.nativeLanguage,
    currentLevel: currentLevel ?? this.currentLevel,
    dailyNewWords: dailyNewWords ?? this.dailyNewWords,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    translationMode: translationMode ?? this.translationMode,
    swipeKnownRight: swipeKnownRight ?? this.swipeKnownRight,
    createdAt: createdAt ?? this.createdAt,
    interests: interests ?? this.interests,
    onboardedAt: onboardedAt.present ? onboardedAt.value : this.onboardedAt,
    levelLocked: levelLocked ?? this.levelLocked,
    levelChangedAt: levelChangedAt.present
        ? levelChangedAt.value
        : this.levelChangedAt,
    stepBackDismissedAt: stepBackDismissedAt.present
        ? stepBackDismissedAt.value
        : this.stepBackDismissedAt,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      age: data.age.present ? data.age.value : this.age,
      nativeLanguage: data.nativeLanguage.present
          ? data.nativeLanguage.value
          : this.nativeLanguage,
      currentLevel: data.currentLevel.present
          ? data.currentLevel.value
          : this.currentLevel,
      dailyNewWords: data.dailyNewWords.present
          ? data.dailyNewWords.value
          : this.dailyNewWords,
      dailyMinutes: data.dailyMinutes.present
          ? data.dailyMinutes.value
          : this.dailyMinutes,
      translationMode: data.translationMode.present
          ? data.translationMode.value
          : this.translationMode,
      swipeKnownRight: data.swipeKnownRight.present
          ? data.swipeKnownRight.value
          : this.swipeKnownRight,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      interests: data.interests.present ? data.interests.value : this.interests,
      onboardedAt: data.onboardedAt.present
          ? data.onboardedAt.value
          : this.onboardedAt,
      levelLocked: data.levelLocked.present
          ? data.levelLocked.value
          : this.levelLocked,
      levelChangedAt: data.levelChangedAt.present
          ? data.levelChangedAt.value
          : this.levelChangedAt,
      stepBackDismissedAt: data.stepBackDismissedAt.present
          ? data.stepBackDismissedAt.value
          : this.stepBackDismissedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('age: $age, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('currentLevel: $currentLevel, ')
          ..write('dailyNewWords: $dailyNewWords, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('translationMode: $translationMode, ')
          ..write('swipeKnownRight: $swipeKnownRight, ')
          ..write('createdAt: $createdAt, ')
          ..write('interests: $interests, ')
          ..write('onboardedAt: $onboardedAt, ')
          ..write('levelLocked: $levelLocked, ')
          ..write('levelChangedAt: $levelChangedAt, ')
          ..write('stepBackDismissedAt: $stepBackDismissedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    avatar,
    age,
    nativeLanguage,
    currentLevel,
    dailyNewWords,
    dailyMinutes,
    translationMode,
    swipeKnownRight,
    createdAt,
    interests,
    onboardedAt,
    levelLocked,
    levelChangedAt,
    stepBackDismissedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatar == this.avatar &&
          other.age == this.age &&
          other.nativeLanguage == this.nativeLanguage &&
          other.currentLevel == this.currentLevel &&
          other.dailyNewWords == this.dailyNewWords &&
          other.dailyMinutes == this.dailyMinutes &&
          other.translationMode == this.translationMode &&
          other.swipeKnownRight == this.swipeKnownRight &&
          other.createdAt == this.createdAt &&
          other.interests == this.interests &&
          other.onboardedAt == this.onboardedAt &&
          other.levelLocked == this.levelLocked &&
          other.levelChangedAt == this.levelChangedAt &&
          other.stepBackDismissedAt == this.stepBackDismissedAt);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> avatar;
  final Value<int> age;
  final Value<String> nativeLanguage;
  final Value<String> currentLevel;
  final Value<int> dailyNewWords;
  final Value<int> dailyMinutes;
  final Value<TranslationMode> translationMode;
  final Value<bool> swipeKnownRight;
  final Value<DateTime> createdAt;
  final Value<List<String>> interests;
  final Value<DateTime?> onboardedAt;
  final Value<bool> levelLocked;
  final Value<DateTime?> levelChangedAt;
  final Value<DateTime?> stepBackDismissedAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    this.age = const Value.absent(),
    this.nativeLanguage = const Value.absent(),
    this.currentLevel = const Value.absent(),
    this.dailyNewWords = const Value.absent(),
    this.dailyMinutes = const Value.absent(),
    this.translationMode = const Value.absent(),
    this.swipeKnownRight = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.interests = const Value.absent(),
    this.onboardedAt = const Value.absent(),
    this.levelLocked = const Value.absent(),
    this.levelChangedAt = const Value.absent(),
    this.stepBackDismissedAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String avatar,
    required int age,
    this.nativeLanguage = const Value.absent(),
    required String currentLevel,
    this.dailyNewWords = const Value.absent(),
    this.dailyMinutes = const Value.absent(),
    required TranslationMode translationMode,
    this.swipeKnownRight = const Value.absent(),
    required DateTime createdAt,
    this.interests = const Value.absent(),
    this.onboardedAt = const Value.absent(),
    this.levelLocked = const Value.absent(),
    this.levelChangedAt = const Value.absent(),
    this.stepBackDismissedAt = const Value.absent(),
  }) : name = Value(name),
       avatar = Value(avatar),
       age = Value(age),
       currentLevel = Value(currentLevel),
       translationMode = Value(translationMode),
       createdAt = Value(createdAt);
  static Insertable<ProfileRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? avatar,
    Expression<int>? age,
    Expression<String>? nativeLanguage,
    Expression<String>? currentLevel,
    Expression<int>? dailyNewWords,
    Expression<int>? dailyMinutes,
    Expression<String>? translationMode,
    Expression<bool>? swipeKnownRight,
    Expression<DateTime>? createdAt,
    Expression<String>? interests,
    Expression<DateTime>? onboardedAt,
    Expression<bool>? levelLocked,
    Expression<DateTime>? levelChangedAt,
    Expression<DateTime>? stepBackDismissedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (age != null) 'age': age,
      if (nativeLanguage != null) 'native_language': nativeLanguage,
      if (currentLevel != null) 'current_level': currentLevel,
      if (dailyNewWords != null) 'daily_new_words': dailyNewWords,
      if (dailyMinutes != null) 'daily_minutes': dailyMinutes,
      if (translationMode != null) 'translation_mode': translationMode,
      if (swipeKnownRight != null) 'swipe_known_right': swipeKnownRight,
      if (createdAt != null) 'created_at': createdAt,
      if (interests != null) 'interests': interests,
      if (onboardedAt != null) 'onboarded_at': onboardedAt,
      if (levelLocked != null) 'level_locked': levelLocked,
      if (levelChangedAt != null) 'level_changed_at': levelChangedAt,
      if (stepBackDismissedAt != null)
        'step_back_dismissed_at': stepBackDismissedAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? avatar,
    Value<int>? age,
    Value<String>? nativeLanguage,
    Value<String>? currentLevel,
    Value<int>? dailyNewWords,
    Value<int>? dailyMinutes,
    Value<TranslationMode>? translationMode,
    Value<bool>? swipeKnownRight,
    Value<DateTime>? createdAt,
    Value<List<String>>? interests,
    Value<DateTime?>? onboardedAt,
    Value<bool>? levelLocked,
    Value<DateTime?>? levelChangedAt,
    Value<DateTime?>? stepBackDismissedAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      age: age ?? this.age,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      currentLevel: currentLevel ?? this.currentLevel,
      dailyNewWords: dailyNewWords ?? this.dailyNewWords,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      translationMode: translationMode ?? this.translationMode,
      swipeKnownRight: swipeKnownRight ?? this.swipeKnownRight,
      createdAt: createdAt ?? this.createdAt,
      interests: interests ?? this.interests,
      onboardedAt: onboardedAt ?? this.onboardedAt,
      levelLocked: levelLocked ?? this.levelLocked,
      levelChangedAt: levelChangedAt ?? this.levelChangedAt,
      stepBackDismissedAt: stepBackDismissedAt ?? this.stepBackDismissedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (nativeLanguage.present) {
      map['native_language'] = Variable<String>(nativeLanguage.value);
    }
    if (currentLevel.present) {
      map['current_level'] = Variable<String>(currentLevel.value);
    }
    if (dailyNewWords.present) {
      map['daily_new_words'] = Variable<int>(dailyNewWords.value);
    }
    if (dailyMinutes.present) {
      map['daily_minutes'] = Variable<int>(dailyMinutes.value);
    }
    if (translationMode.present) {
      map['translation_mode'] = Variable<String>(
        $ProfilesTable.$convertertranslationMode.toSql(translationMode.value),
      );
    }
    if (swipeKnownRight.present) {
      map['swipe_known_right'] = Variable<bool>(swipeKnownRight.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (interests.present) {
      map['interests'] = Variable<String>(
        $ProfilesTable.$converterinterests.toSql(interests.value),
      );
    }
    if (onboardedAt.present) {
      map['onboarded_at'] = Variable<DateTime>(onboardedAt.value);
    }
    if (levelLocked.present) {
      map['level_locked'] = Variable<bool>(levelLocked.value);
    }
    if (levelChangedAt.present) {
      map['level_changed_at'] = Variable<DateTime>(levelChangedAt.value);
    }
    if (stepBackDismissedAt.present) {
      map['step_back_dismissed_at'] = Variable<DateTime>(
        stepBackDismissedAt.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('age: $age, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('currentLevel: $currentLevel, ')
          ..write('dailyNewWords: $dailyNewWords, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('translationMode: $translationMode, ')
          ..write('swipeKnownRight: $swipeKnownRight, ')
          ..write('createdAt: $createdAt, ')
          ..write('interests: $interests, ')
          ..write('onboardedAt: $onboardedAt, ')
          ..write('levelLocked: $levelLocked, ')
          ..write('levelChangedAt: $levelChangedAt, ')
          ..write('stepBackDismissedAt: $stepBackDismissedAt')
          ..write(')'))
        .toString();
  }
}

class $WordProgressTable extends WordProgress
    with TableInfo<$WordProgressTable, WordProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WordState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WordState>($WordProgressTable.$converterstate);
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAnsweredAtMeta = const VerificationMeta(
    'lastAnsweredAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAnsweredAt =
      GeneratedColumn<DateTime>(
        'last_answered_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wrongCountMeta = const VerificationMeta(
    'wrongCount',
  );
  @override
  late final GeneratedColumn<int> wrongCount = GeneratedColumn<int>(
    'wrong_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    wordId,
    state,
    easeFactor,
    intervalDays,
    repetitions,
    nextReviewAt,
    lastAnsweredAt,
    correctCount,
    wrongCount,
    firstSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    } else if (isInserting) {
      context.missing(_easeFactorMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalDaysMeta);
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repetitionsMeta);
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    if (data.containsKey('last_answered_at')) {
      context.handle(
        _lastAnsweredAtMeta,
        lastAnsweredAt.isAcceptableOrUnknown(
          data['last_answered_at']!,
          _lastAnsweredAtMeta,
        ),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctCountMeta);
    }
    if (data.containsKey('wrong_count')) {
      context.handle(
        _wrongCountMeta,
        wrongCount.isAcceptableOrUnknown(data['wrong_count']!, _wrongCountMeta),
      );
    } else if (isInserting) {
      context.missing(_wrongCountMeta);
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, wordId};
  @override
  WordProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordProgressRow(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      )!,
      state: $WordProgressTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      ),
      lastAnsweredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_answered_at'],
      ),
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      wrongCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_count'],
      )!,
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen_at'],
      )!,
    );
  }

  @override
  $WordProgressTable createAlias(String alias) {
    return $WordProgressTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WordState, String, String> $converterstate =
      const EnumNameConverter<WordState>(WordState.values);
}

class WordProgressRow extends DataClass implements Insertable<WordProgressRow> {
  final int profileId;

  /// No FK to [Words]: word-bank updates must never drop a child's progress.
  final String wordId;
  final WordState state;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime? nextReviewAt;
  final DateTime? lastAnsweredAt;
  final int correctCount;
  final int wrongCount;
  final DateTime firstSeenAt;
  const WordProgressRow({
    required this.profileId,
    required this.wordId,
    required this.state,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    this.nextReviewAt,
    this.lastAnsweredAt,
    required this.correctCount,
    required this.wrongCount,
    required this.firstSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['word_id'] = Variable<String>(wordId);
    {
      map['state'] = Variable<String>(
        $WordProgressTable.$converterstate.toSql(state),
      );
    }
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval_days'] = Variable<int>(intervalDays);
    map['repetitions'] = Variable<int>(repetitions);
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    }
    if (!nullToAbsent || lastAnsweredAt != null) {
      map['last_answered_at'] = Variable<DateTime>(lastAnsweredAt);
    }
    map['correct_count'] = Variable<int>(correctCount);
    map['wrong_count'] = Variable<int>(wrongCount);
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    return map;
  }

  WordProgressCompanion toCompanion(bool nullToAbsent) {
    return WordProgressCompanion(
      profileId: Value(profileId),
      wordId: Value(wordId),
      state: Value(state),
      easeFactor: Value(easeFactor),
      intervalDays: Value(intervalDays),
      repetitions: Value(repetitions),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      lastAnsweredAt: lastAnsweredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAnsweredAt),
      correctCount: Value(correctCount),
      wrongCount: Value(wrongCount),
      firstSeenAt: Value(firstSeenAt),
    );
  }

  factory WordProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordProgressRow(
      profileId: serializer.fromJson<int>(json['profileId']),
      wordId: serializer.fromJson<String>(json['wordId']),
      state: $WordProgressTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      nextReviewAt: serializer.fromJson<DateTime?>(json['nextReviewAt']),
      lastAnsweredAt: serializer.fromJson<DateTime?>(json['lastAnsweredAt']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      wrongCount: serializer.fromJson<int>(json['wrongCount']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'wordId': serializer.toJson<String>(wordId),
      'state': serializer.toJson<String>(
        $WordProgressTable.$converterstate.toJson(state),
      ),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'repetitions': serializer.toJson<int>(repetitions),
      'nextReviewAt': serializer.toJson<DateTime?>(nextReviewAt),
      'lastAnsweredAt': serializer.toJson<DateTime?>(lastAnsweredAt),
      'correctCount': serializer.toJson<int>(correctCount),
      'wrongCount': serializer.toJson<int>(wrongCount),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
    };
  }

  WordProgressRow copyWith({
    int? profileId,
    String? wordId,
    WordState? state,
    double? easeFactor,
    int? intervalDays,
    int? repetitions,
    Value<DateTime?> nextReviewAt = const Value.absent(),
    Value<DateTime?> lastAnsweredAt = const Value.absent(),
    int? correctCount,
    int? wrongCount,
    DateTime? firstSeenAt,
  }) => WordProgressRow(
    profileId: profileId ?? this.profileId,
    wordId: wordId ?? this.wordId,
    state: state ?? this.state,
    easeFactor: easeFactor ?? this.easeFactor,
    intervalDays: intervalDays ?? this.intervalDays,
    repetitions: repetitions ?? this.repetitions,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
    lastAnsweredAt: lastAnsweredAt.present
        ? lastAnsweredAt.value
        : this.lastAnsweredAt,
    correctCount: correctCount ?? this.correctCount,
    wrongCount: wrongCount ?? this.wrongCount,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
  );
  WordProgressRow copyWithCompanion(WordProgressCompanion data) {
    return WordProgressRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      state: data.state.present ? data.state.value : this.state,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      lastAnsweredAt: data.lastAnsweredAt.present
          ? data.lastAnsweredAt.value
          : this.lastAnsweredAt,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      wrongCount: data.wrongCount.present
          ? data.wrongCount.value
          : this.wrongCount,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordProgressRow(')
          ..write('profileId: $profileId, ')
          ..write('wordId: $wordId, ')
          ..write('state: $state, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('repetitions: $repetitions, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastAnsweredAt: $lastAnsweredAt, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('firstSeenAt: $firstSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    wordId,
    state,
    easeFactor,
    intervalDays,
    repetitions,
    nextReviewAt,
    lastAnsweredAt,
    correctCount,
    wrongCount,
    firstSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordProgressRow &&
          other.profileId == this.profileId &&
          other.wordId == this.wordId &&
          other.state == this.state &&
          other.easeFactor == this.easeFactor &&
          other.intervalDays == this.intervalDays &&
          other.repetitions == this.repetitions &&
          other.nextReviewAt == this.nextReviewAt &&
          other.lastAnsweredAt == this.lastAnsweredAt &&
          other.correctCount == this.correctCount &&
          other.wrongCount == this.wrongCount &&
          other.firstSeenAt == this.firstSeenAt);
}

class WordProgressCompanion extends UpdateCompanion<WordProgressRow> {
  final Value<int> profileId;
  final Value<String> wordId;
  final Value<WordState> state;
  final Value<double> easeFactor;
  final Value<int> intervalDays;
  final Value<int> repetitions;
  final Value<DateTime?> nextReviewAt;
  final Value<DateTime?> lastAnsweredAt;
  final Value<int> correctCount;
  final Value<int> wrongCount;
  final Value<DateTime> firstSeenAt;
  final Value<int> rowid;
  const WordProgressCompanion({
    this.profileId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.state = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.lastAnsweredAt = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.wrongCount = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordProgressCompanion.insert({
    required int profileId,
    required String wordId,
    required WordState state,
    required double easeFactor,
    required int intervalDays,
    required int repetitions,
    this.nextReviewAt = const Value.absent(),
    this.lastAnsweredAt = const Value.absent(),
    required int correctCount,
    required int wrongCount,
    required DateTime firstSeenAt,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       wordId = Value(wordId),
       state = Value(state),
       easeFactor = Value(easeFactor),
       intervalDays = Value(intervalDays),
       repetitions = Value(repetitions),
       correctCount = Value(correctCount),
       wrongCount = Value(wrongCount),
       firstSeenAt = Value(firstSeenAt);
  static Insertable<WordProgressRow> custom({
    Expression<int>? profileId,
    Expression<String>? wordId,
    Expression<String>? state,
    Expression<double>? easeFactor,
    Expression<int>? intervalDays,
    Expression<int>? repetitions,
    Expression<DateTime>? nextReviewAt,
    Expression<DateTime>? lastAnsweredAt,
    Expression<int>? correctCount,
    Expression<int>? wrongCount,
    Expression<DateTime>? firstSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (wordId != null) 'word_id': wordId,
      if (state != null) 'state': state,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (repetitions != null) 'repetitions': repetitions,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (lastAnsweredAt != null) 'last_answered_at': lastAnsweredAt,
      if (correctCount != null) 'correct_count': correctCount,
      if (wrongCount != null) 'wrong_count': wrongCount,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordProgressCompanion copyWith({
    Value<int>? profileId,
    Value<String>? wordId,
    Value<WordState>? state,
    Value<double>? easeFactor,
    Value<int>? intervalDays,
    Value<int>? repetitions,
    Value<DateTime?>? nextReviewAt,
    Value<DateTime?>? lastAnsweredAt,
    Value<int>? correctCount,
    Value<int>? wrongCount,
    Value<DateTime>? firstSeenAt,
    Value<int>? rowid,
  }) {
    return WordProgressCompanion(
      profileId: profileId ?? this.profileId,
      wordId: wordId ?? this.wordId,
      state: state ?? this.state,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      lastAnsweredAt: lastAnsweredAt ?? this.lastAnsweredAt,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $WordProgressTable.$converterstate.toSql(state.value),
      );
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (lastAnsweredAt.present) {
      map['last_answered_at'] = Variable<DateTime>(lastAnsweredAt.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (wrongCount.present) {
      map['wrong_count'] = Variable<int>(wrongCount.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordProgressCompanion(')
          ..write('profileId: $profileId, ')
          ..write('wordId: $wordId, ')
          ..write('state: $state, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('repetitions: $repetitions, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastAnsweredAt: $lastAnsweredAt, ')
          ..write('correctCount: $correctCount, ')
          ..write('wrongCount: $wrongCount, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionLogsTable extends SessionLogs
    with TableInfo<$SessionLogsTable, SessionLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewedMeta = const VerificationMeta(
    'reviewed',
  );
  @override
  late final GeneratedColumn<int> reviewed = GeneratedColumn<int>(
    'reviewed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newLearnedMeta = const VerificationMeta(
    'newLearned',
  );
  @override
  late final GeneratedColumn<int> newLearned = GeneratedColumn<int>(
    'new_learned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    startedAt,
    durationSec,
    reviewed,
    newLearned,
    accuracy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecMeta);
    }
    if (data.containsKey('reviewed')) {
      context.handle(
        _reviewedMeta,
        reviewed.isAcceptableOrUnknown(data['reviewed']!, _reviewedMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedMeta);
    }
    if (data.containsKey('new_learned')) {
      context.handle(
        _newLearnedMeta,
        newLearned.isAcceptableOrUnknown(data['new_learned']!, _newLearnedMeta),
      );
    } else if (isInserting) {
      context.missing(_newLearnedMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      )!,
      reviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed'],
      )!,
      newLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_learned'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
    );
  }

  @override
  $SessionLogsTable createAlias(String alias) {
    return $SessionLogsTable(attachedDatabase, alias);
  }
}

class SessionLogRow extends DataClass implements Insertable<SessionLogRow> {
  final int id;
  final int profileId;
  final DateTime startedAt;
  final int durationSec;
  final int reviewed;
  final int newLearned;

  /// Share of first answers that were passes, 0–1.
  final double accuracy;
  const SessionLogRow({
    required this.id,
    required this.profileId,
    required this.startedAt,
    required this.durationSec,
    required this.reviewed,
    required this.newLearned,
    required this.accuracy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_sec'] = Variable<int>(durationSec);
    map['reviewed'] = Variable<int>(reviewed);
    map['new_learned'] = Variable<int>(newLearned);
    map['accuracy'] = Variable<double>(accuracy);
    return map;
  }

  SessionLogsCompanion toCompanion(bool nullToAbsent) {
    return SessionLogsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      startedAt: Value(startedAt),
      durationSec: Value(durationSec),
      reviewed: Value(reviewed),
      newLearned: Value(newLearned),
      accuracy: Value(accuracy),
    );
  }

  factory SessionLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionLogRow(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      reviewed: serializer.fromJson<int>(json['reviewed']),
      newLearned: serializer.fromJson<int>(json['newLearned']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationSec': serializer.toJson<int>(durationSec),
      'reviewed': serializer.toJson<int>(reviewed),
      'newLearned': serializer.toJson<int>(newLearned),
      'accuracy': serializer.toJson<double>(accuracy),
    };
  }

  SessionLogRow copyWith({
    int? id,
    int? profileId,
    DateTime? startedAt,
    int? durationSec,
    int? reviewed,
    int? newLearned,
    double? accuracy,
  }) => SessionLogRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    startedAt: startedAt ?? this.startedAt,
    durationSec: durationSec ?? this.durationSec,
    reviewed: reviewed ?? this.reviewed,
    newLearned: newLearned ?? this.newLearned,
    accuracy: accuracy ?? this.accuracy,
  );
  SessionLogRow copyWithCompanion(SessionLogsCompanion data) {
    return SessionLogRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      reviewed: data.reviewed.present ? data.reviewed.value : this.reviewed,
      newLearned: data.newLearned.present
          ? data.newLearned.value
          : this.newLearned,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionLogRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSec: $durationSec, ')
          ..write('reviewed: $reviewed, ')
          ..write('newLearned: $newLearned, ')
          ..write('accuracy: $accuracy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    startedAt,
    durationSec,
    reviewed,
    newLearned,
    accuracy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionLogRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.startedAt == this.startedAt &&
          other.durationSec == this.durationSec &&
          other.reviewed == this.reviewed &&
          other.newLearned == this.newLearned &&
          other.accuracy == this.accuracy);
}

class SessionLogsCompanion extends UpdateCompanion<SessionLogRow> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<DateTime> startedAt;
  final Value<int> durationSec;
  final Value<int> reviewed;
  final Value<int> newLearned;
  final Value<double> accuracy;
  const SessionLogsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.reviewed = const Value.absent(),
    this.newLearned = const Value.absent(),
    this.accuracy = const Value.absent(),
  });
  SessionLogsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required DateTime startedAt,
    required int durationSec,
    required int reviewed,
    required int newLearned,
    required double accuracy,
  }) : profileId = Value(profileId),
       startedAt = Value(startedAt),
       durationSec = Value(durationSec),
       reviewed = Value(reviewed),
       newLearned = Value(newLearned),
       accuracy = Value(accuracy);
  static Insertable<SessionLogRow> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<DateTime>? startedAt,
    Expression<int>? durationSec,
    Expression<int>? reviewed,
    Expression<int>? newLearned,
    Expression<double>? accuracy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (startedAt != null) 'started_at': startedAt,
      if (durationSec != null) 'duration_sec': durationSec,
      if (reviewed != null) 'reviewed': reviewed,
      if (newLearned != null) 'new_learned': newLearned,
      if (accuracy != null) 'accuracy': accuracy,
    });
  }

  SessionLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<DateTime>? startedAt,
    Value<int>? durationSec,
    Value<int>? reviewed,
    Value<int>? newLearned,
    Value<double>? accuracy,
  }) {
    return SessionLogsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      startedAt: startedAt ?? this.startedAt,
      durationSec: durationSec ?? this.durationSec,
      reviewed: reviewed ?? this.reviewed,
      newLearned: newLearned ?? this.newLearned,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (reviewed.present) {
      map['reviewed'] = Variable<int>(reviewed.value);
    }
    if (newLearned.present) {
      map['new_learned'] = Variable<int>(newLearned.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionLogsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSec: $durationSec, ')
          ..write('reviewed: $reviewed, ')
          ..write('newLearned: $newLearned, ')
          ..write('accuracy: $accuracy')
          ..write(')'))
        .toString();
  }
}

class $QuizLogsTable extends QuizLogs
    with TableInfo<$QuizLogsTable, QuizLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    wordId,
    kind,
    correct,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $QuizLogsTable createAlias(String alias) {
    return $QuizLogsTable(attachedDatabase, alias);
  }
}

class QuizLogRow extends DataClass implements Insertable<QuizLogRow> {
  final int id;
  final int profileId;

  /// No FK to [Words], like [WordProgress].
  final String wordId;

  /// QuizKind name: pickPicture | chooseMeaning | spell.
  final String kind;
  final bool correct;
  final DateTime answeredAt;
  const QuizLogRow({
    required this.id,
    required this.profileId,
    required this.wordId,
    required this.kind,
    required this.correct,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['word_id'] = Variable<String>(wordId);
    map['kind'] = Variable<String>(kind);
    map['correct'] = Variable<bool>(correct);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  QuizLogsCompanion toCompanion(bool nullToAbsent) {
    return QuizLogsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      wordId: Value(wordId),
      kind: Value(kind),
      correct: Value(correct),
      answeredAt: Value(answeredAt),
    );
  }

  factory QuizLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizLogRow(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      wordId: serializer.fromJson<String>(json['wordId']),
      kind: serializer.fromJson<String>(json['kind']),
      correct: serializer.fromJson<bool>(json['correct']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'wordId': serializer.toJson<String>(wordId),
      'kind': serializer.toJson<String>(kind),
      'correct': serializer.toJson<bool>(correct),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  QuizLogRow copyWith({
    int? id,
    int? profileId,
    String? wordId,
    String? kind,
    bool? correct,
    DateTime? answeredAt,
  }) => QuizLogRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    wordId: wordId ?? this.wordId,
    kind: kind ?? this.kind,
    correct: correct ?? this.correct,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  QuizLogRow copyWithCompanion(QuizLogsCompanion data) {
    return QuizLogRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      kind: data.kind.present ? data.kind.value : this.kind,
      correct: data.correct.present ? data.correct.value : this.correct,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizLogRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('wordId: $wordId, ')
          ..write('kind: $kind, ')
          ..write('correct: $correct, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, wordId, kind, correct, answeredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizLogRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.wordId == this.wordId &&
          other.kind == this.kind &&
          other.correct == this.correct &&
          other.answeredAt == this.answeredAt);
}

class QuizLogsCompanion extends UpdateCompanion<QuizLogRow> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> wordId;
  final Value<String> kind;
  final Value<bool> correct;
  final Value<DateTime> answeredAt;
  const QuizLogsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.kind = const Value.absent(),
    this.correct = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  QuizLogsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String wordId,
    required String kind,
    required bool correct,
    required DateTime answeredAt,
  }) : profileId = Value(profileId),
       wordId = Value(wordId),
       kind = Value(kind),
       correct = Value(correct),
       answeredAt = Value(answeredAt);
  static Insertable<QuizLogRow> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? wordId,
    Expression<String>? kind,
    Expression<bool>? correct,
    Expression<DateTime>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (wordId != null) 'word_id': wordId,
      if (kind != null) 'kind': kind,
      if (correct != null) 'correct': correct,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  QuizLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? wordId,
    Value<String>? kind,
    Value<bool>? correct,
    Value<DateTime>? answeredAt,
  }) {
    return QuizLogsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      wordId: wordId ?? this.wordId,
      kind: kind ?? this.kind,
      correct: correct ?? this.correct,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizLogsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('wordId: $wordId, ')
          ..write('kind: $kind, ')
          ..write('correct: $correct, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $CustomWordsTable extends CustomWords
    with TableInfo<$CustomWordsTable, CustomWordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
    'word_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    wordId,
    word,
    definition,
    translation,
    emoji,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomWordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomWordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomWordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_id'],
      ),
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      definition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      ),
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CustomWordsTable createAlias(String alias) {
    return $CustomWordsTable(attachedDatabase, alias);
  }
}

class CustomWordRow extends DataClass implements Insertable<CustomWordRow> {
  final int id;
  final int profileId;

  /// Bank word id when matched; null for the parent's own word.
  final String? wordId;

  /// The word as matched (normalized: lower case, single spaces).
  final String word;
  final String definition;
  final String? translation;
  final String? emoji;
  final DateTime addedAt;
  const CustomWordRow({
    required this.id,
    required this.profileId,
    this.wordId,
    required this.word,
    required this.definition,
    this.translation,
    this.emoji,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    if (!nullToAbsent || wordId != null) {
      map['word_id'] = Variable<String>(wordId);
    }
    map['word'] = Variable<String>(word);
    map['definition'] = Variable<String>(definition);
    if (!nullToAbsent || translation != null) {
      map['translation'] = Variable<String>(translation);
    }
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CustomWordsCompanion toCompanion(bool nullToAbsent) {
    return CustomWordsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      wordId: wordId == null && nullToAbsent
          ? const Value.absent()
          : Value(wordId),
      word: Value(word),
      definition: Value(definition),
      translation: translation == null && nullToAbsent
          ? const Value.absent()
          : Value(translation),
      emoji: emoji == null && nullToAbsent
          ? const Value.absent()
          : Value(emoji),
      addedAt: Value(addedAt),
    );
  }

  factory CustomWordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomWordRow(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      wordId: serializer.fromJson<String?>(json['wordId']),
      word: serializer.fromJson<String>(json['word']),
      definition: serializer.fromJson<String>(json['definition']),
      translation: serializer.fromJson<String?>(json['translation']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'wordId': serializer.toJson<String?>(wordId),
      'word': serializer.toJson<String>(word),
      'definition': serializer.toJson<String>(definition),
      'translation': serializer.toJson<String?>(translation),
      'emoji': serializer.toJson<String?>(emoji),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CustomWordRow copyWith({
    int? id,
    int? profileId,
    Value<String?> wordId = const Value.absent(),
    String? word,
    String? definition,
    Value<String?> translation = const Value.absent(),
    Value<String?> emoji = const Value.absent(),
    DateTime? addedAt,
  }) => CustomWordRow(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    wordId: wordId.present ? wordId.value : this.wordId,
    word: word ?? this.word,
    definition: definition ?? this.definition,
    translation: translation.present ? translation.value : this.translation,
    emoji: emoji.present ? emoji.value : this.emoji,
    addedAt: addedAt ?? this.addedAt,
  );
  CustomWordRow copyWithCompanion(CustomWordsCompanion data) {
    return CustomWordRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      word: data.word.present ? data.word.value : this.word,
      definition: data.definition.present
          ? data.definition.value
          : this.definition,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomWordRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('definition: $definition, ')
          ..write('translation: $translation, ')
          ..write('emoji: $emoji, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    wordId,
    word,
    definition,
    translation,
    emoji,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomWordRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.wordId == this.wordId &&
          other.word == this.word &&
          other.definition == this.definition &&
          other.translation == this.translation &&
          other.emoji == this.emoji &&
          other.addedAt == this.addedAt);
}

class CustomWordsCompanion extends UpdateCompanion<CustomWordRow> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String?> wordId;
  final Value<String> word;
  final Value<String> definition;
  final Value<String?> translation;
  final Value<String?> emoji;
  final Value<DateTime> addedAt;
  const CustomWordsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.word = const Value.absent(),
    this.definition = const Value.absent(),
    this.translation = const Value.absent(),
    this.emoji = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  CustomWordsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    this.wordId = const Value.absent(),
    required String word,
    this.definition = const Value.absent(),
    this.translation = const Value.absent(),
    this.emoji = const Value.absent(),
    required DateTime addedAt,
  }) : profileId = Value(profileId),
       word = Value(word),
       addedAt = Value(addedAt);
  static Insertable<CustomWordRow> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? wordId,
    Expression<String>? word,
    Expression<String>? definition,
    Expression<String>? translation,
    Expression<String>? emoji,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (wordId != null) 'word_id': wordId,
      if (word != null) 'word': word,
      if (definition != null) 'definition': definition,
      if (translation != null) 'translation': translation,
      if (emoji != null) 'emoji': emoji,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  CustomWordsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String?>? wordId,
    Value<String>? word,
    Value<String>? definition,
    Value<String?>? translation,
    Value<String?>? emoji,
    Value<DateTime>? addedAt,
  }) {
    return CustomWordsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      translation: translation ?? this.translation,
      emoji: emoji ?? this.emoji,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomWordsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('definition: $definition, ')
          ..write('translation: $translation, ')
          ..write('emoji: $emoji, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  final String key;
  final String value;
  const AppMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaRow copyWith({String? key, String? value}) =>
      AppMetaRow(key: key ?? this.key, value: value ?? this.value);
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $TranslationsTable translations = $TranslationsTable(this);
  late final $ParentAccountsTable parentAccounts = $ParentAccountsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $WordProgressTable wordProgress = $WordProgressTable(this);
  late final $SessionLogsTable sessionLogs = $SessionLogsTable(this);
  late final $QuizLogsTable quizLogs = $QuizLogsTable(this);
  late final $CustomWordsTable customWords = $CustomWordsTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    words,
    translations,
    parentAccounts,
    profiles,
    wordProgress,
    sessionLogs,
    quizLogs,
    customWords,
    appMeta,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quiz_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('custom_words', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      required String id,
      required String word,
      required String partOfSpeech,
      required String cefrLevel,
      required int levelIndex,
      required int rank,
      required int minAge,
      required List<String> themes,
      Value<String?> emoji,
      required String definition,
      required List<String> examples,
      required Map<String, String> forms,
      Value<int> rowid,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<String> id,
      Value<String> word,
      Value<String> partOfSpeech,
      Value<String> cefrLevel,
      Value<int> levelIndex,
      Value<int> rank,
      Value<int> minAge,
      Value<List<String>> themes,
      Value<String?> emoji,
      Value<String> definition,
      Value<List<String>> examples,
      Value<Map<String, String>> forms,
      Value<int> rowid,
    });

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, WordRow> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TranslationsTable, List<TranslationRow>>
  _translationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.translations,
    aliasName: 'words__id__translations__word_id',
  );

  $$TranslationsTableProcessedTableManager get translationsRefs {
    final manager = $$TranslationsTableTableManager(
      $_db,
      $_db.translations,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_translationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cefrLevel => $composableBuilder(
    column: $table.cefrLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get levelIndex => $composableBuilder(
    column: $table.levelIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minAge => $composableBuilder(
    column: $table.minAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get themes => $composableBuilder(
    column: $table.themes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get forms => $composableBuilder(
    column: $table.forms,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> translationsRefs(
    Expression<bool> Function($$TranslationsTableFilterComposer f) f,
  ) {
    final $$TranslationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.translations,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationsTableFilterComposer(
            $db: $db,
            $table: $db.translations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cefrLevel => $composableBuilder(
    column: $table.cefrLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get levelIndex => $composableBuilder(
    column: $table.levelIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minAge => $composableBuilder(
    column: $table.minAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themes => $composableBuilder(
    column: $table.themes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forms => $composableBuilder(
    column: $table.forms,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cefrLevel =>
      $composableBuilder(column: $table.cefrLevel, builder: (column) => column);

  GeneratedColumn<int> get levelIndex => $composableBuilder(
    column: $table.levelIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<int> get minAge =>
      $composableBuilder(column: $table.minAge, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get themes =>
      $composableBuilder(column: $table.themes, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get examples =>
      $composableBuilder(column: $table.examples, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get forms =>
      $composableBuilder(column: $table.forms, builder: (column) => column);

  Expression<T> translationsRefs<T extends Object>(
    Expression<T> Function($$TranslationsTableAnnotationComposer a) f,
  ) {
    final $$TranslationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.translations,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationsTableAnnotationComposer(
            $db: $db,
            $table: $db.translations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          WordRow,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (WordRow, $$WordsTableReferences),
          WordRow,
          PrefetchHooks Function({bool translationsRefs})
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<String> cefrLevel = const Value.absent(),
                Value<int> levelIndex = const Value.absent(),
                Value<int> rank = const Value.absent(),
                Value<int> minAge = const Value.absent(),
                Value<List<String>> themes = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<List<String>> examples = const Value.absent(),
                Value<Map<String, String>> forms = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                word: word,
                partOfSpeech: partOfSpeech,
                cefrLevel: cefrLevel,
                levelIndex: levelIndex,
                rank: rank,
                minAge: minAge,
                themes: themes,
                emoji: emoji,
                definition: definition,
                examples: examples,
                forms: forms,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String word,
                required String partOfSpeech,
                required String cefrLevel,
                required int levelIndex,
                required int rank,
                required int minAge,
                required List<String> themes,
                Value<String?> emoji = const Value.absent(),
                required String definition,
                required List<String> examples,
                required Map<String, String> forms,
                Value<int> rowid = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                word: word,
                partOfSpeech: partOfSpeech,
                cefrLevel: cefrLevel,
                levelIndex: levelIndex,
                rank: rank,
                minAge: minAge,
                themes: themes,
                emoji: emoji,
                definition: definition,
                examples: examples,
                forms: forms,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordsTable, WordRow>(table),
                  $$WordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({translationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (translationsRefs) db.translations],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (translationsRefs)
                    await $_getPrefetchedDataByColumns<
                      WordRow,
                      $WordsTable,
                      TranslationRow,
                      $TranslationsTable
                    >(
                      currentTable: table,
                      referencedTable: $$WordsTableReferences
                          ._translationsRefsTable(db),
                      managerFromTypedResult: (p0) => $$WordsTableReferences(
                        db,
                        table,
                        p0,
                      ).translationsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'word_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      WordRow,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (WordRow, $$WordsTableReferences),
      WordRow,
      PrefetchHooks Function({bool translationsRefs})
    >;
typedef $$TranslationsTableCreateCompanionBuilder =
    TranslationsCompanion Function({
      required String wordId,
      required String languageCode,
      required String translation,
      Value<int> rowid,
    });
typedef $$TranslationsTableUpdateCompanionBuilder =
    TranslationsCompanion Function({
      Value<String> wordId,
      Value<String> languageCode,
      Value<String> translation,
      Value<int> rowid,
    });

final class $$TranslationsTableReferences
    extends BaseReferences<_$AppDatabase, $TranslationsTable, TranslationRow> {
  $$TranslationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('translations__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<String>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TranslationsTableFilterComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranslationsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranslationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranslationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranslationsTable,
          TranslationRow,
          $$TranslationsTableFilterComposer,
          $$TranslationsTableOrderingComposer,
          $$TranslationsTableAnnotationComposer,
          $$TranslationsTableCreateCompanionBuilder,
          $$TranslationsTableUpdateCompanionBuilder,
          (TranslationRow, $$TranslationsTableReferences),
          TranslationRow,
          PrefetchHooks Function({bool wordId})
        > {
  $$TranslationsTableTableManager(_$AppDatabase db, $TranslationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranslationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranslationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> wordId = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationsCompanion(
                wordId: wordId,
                languageCode: languageCode,
                translation: translation,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String wordId,
                required String languageCode,
                required String translation,
                Value<int> rowid = const Value.absent(),
              }) => TranslationsCompanion.insert(
                wordId: wordId,
                languageCode: languageCode,
                translation: translation,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TranslationsTable, TranslationRow>(table),
                  $$TranslationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$TranslationsTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$TranslationsTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TranslationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranslationsTable,
      TranslationRow,
      $$TranslationsTableFilterComposer,
      $$TranslationsTableOrderingComposer,
      $$TranslationsTableAnnotationComposer,
      $$TranslationsTableCreateCompanionBuilder,
      $$TranslationsTableUpdateCompanionBuilder,
      (TranslationRow, $$TranslationsTableReferences),
      TranslationRow,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$ParentAccountsTableCreateCompanionBuilder =
    ParentAccountsCompanion Function({
      Value<int> id,
      required String pinHash,
      required String pinSalt,
      Value<int?> reminderMinuteOfDay,
      Value<int> quietStartMinute,
      Value<int> quietEndMinute,
      Value<bool> blockSchoolHours,
      Value<int> schoolStartMinute,
      Value<int> schoolEndMinute,
      Value<bool> weeklyRecap,
      required DateTime createdAt,
    });
typedef $$ParentAccountsTableUpdateCompanionBuilder =
    ParentAccountsCompanion Function({
      Value<int> id,
      Value<String> pinHash,
      Value<String> pinSalt,
      Value<int?> reminderMinuteOfDay,
      Value<int> quietStartMinute,
      Value<int> quietEndMinute,
      Value<bool> blockSchoolHours,
      Value<int> schoolStartMinute,
      Value<int> schoolEndMinute,
      Value<bool> weeklyRecap,
      Value<DateTime> createdAt,
    });

class $$ParentAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $ParentAccountsTable> {
  $$ParentAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinuteOfDay => $composableBuilder(
    column: $table.reminderMinuteOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietStartMinute => $composableBuilder(
    column: $table.quietStartMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietEndMinute => $composableBuilder(
    column: $table.quietEndMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get blockSchoolHours => $composableBuilder(
    column: $table.blockSchoolHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schoolStartMinute => $composableBuilder(
    column: $table.schoolStartMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schoolEndMinute => $composableBuilder(
    column: $table.schoolEndMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weeklyRecap => $composableBuilder(
    column: $table.weeklyRecap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ParentAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParentAccountsTable> {
  $$ParentAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinuteOfDay => $composableBuilder(
    column: $table.reminderMinuteOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietStartMinute => $composableBuilder(
    column: $table.quietStartMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietEndMinute => $composableBuilder(
    column: $table.quietEndMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get blockSchoolHours => $composableBuilder(
    column: $table.blockSchoolHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schoolStartMinute => $composableBuilder(
    column: $table.schoolStartMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schoolEndMinute => $composableBuilder(
    column: $table.schoolEndMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weeklyRecap => $composableBuilder(
    column: $table.weeklyRecap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParentAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParentAccountsTable> {
  $$ParentAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => column);

  GeneratedColumn<int> get reminderMinuteOfDay => $composableBuilder(
    column: $table.reminderMinuteOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietStartMinute => $composableBuilder(
    column: $table.quietStartMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietEndMinute => $composableBuilder(
    column: $table.quietEndMinute,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get blockSchoolHours => $composableBuilder(
    column: $table.blockSchoolHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schoolStartMinute => $composableBuilder(
    column: $table.schoolStartMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schoolEndMinute => $composableBuilder(
    column: $table.schoolEndMinute,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weeklyRecap => $composableBuilder(
    column: $table.weeklyRecap,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ParentAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParentAccountsTable,
          ParentAccountRow,
          $$ParentAccountsTableFilterComposer,
          $$ParentAccountsTableOrderingComposer,
          $$ParentAccountsTableAnnotationComposer,
          $$ParentAccountsTableCreateCompanionBuilder,
          $$ParentAccountsTableUpdateCompanionBuilder,
          (
            ParentAccountRow,
            BaseReferences<
              _$AppDatabase,
              $ParentAccountsTable,
              ParentAccountRow
            >,
          ),
          ParentAccountRow,
          PrefetchHooks Function()
        > {
  $$ParentAccountsTableTableManager(
    _$AppDatabase db,
    $ParentAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParentAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParentAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParentAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pinHash = const Value.absent(),
                Value<String> pinSalt = const Value.absent(),
                Value<int?> reminderMinuteOfDay = const Value.absent(),
                Value<int> quietStartMinute = const Value.absent(),
                Value<int> quietEndMinute = const Value.absent(),
                Value<bool> blockSchoolHours = const Value.absent(),
                Value<int> schoolStartMinute = const Value.absent(),
                Value<int> schoolEndMinute = const Value.absent(),
                Value<bool> weeklyRecap = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ParentAccountsCompanion(
                id: id,
                pinHash: pinHash,
                pinSalt: pinSalt,
                reminderMinuteOfDay: reminderMinuteOfDay,
                quietStartMinute: quietStartMinute,
                quietEndMinute: quietEndMinute,
                blockSchoolHours: blockSchoolHours,
                schoolStartMinute: schoolStartMinute,
                schoolEndMinute: schoolEndMinute,
                weeklyRecap: weeklyRecap,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pinHash,
                required String pinSalt,
                Value<int?> reminderMinuteOfDay = const Value.absent(),
                Value<int> quietStartMinute = const Value.absent(),
                Value<int> quietEndMinute = const Value.absent(),
                Value<bool> blockSchoolHours = const Value.absent(),
                Value<int> schoolStartMinute = const Value.absent(),
                Value<int> schoolEndMinute = const Value.absent(),
                Value<bool> weeklyRecap = const Value.absent(),
                required DateTime createdAt,
              }) => ParentAccountsCompanion.insert(
                id: id,
                pinHash: pinHash,
                pinSalt: pinSalt,
                reminderMinuteOfDay: reminderMinuteOfDay,
                quietStartMinute: quietStartMinute,
                quietEndMinute: quietEndMinute,
                blockSchoolHours: blockSchoolHours,
                schoolStartMinute: schoolStartMinute,
                schoolEndMinute: schoolEndMinute,
                weeklyRecap: weeklyRecap,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ParentAccountsTable, ParentAccountRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ParentAccountsTable,
                    ParentAccountRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ParentAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParentAccountsTable,
      ParentAccountRow,
      $$ParentAccountsTableFilterComposer,
      $$ParentAccountsTableOrderingComposer,
      $$ParentAccountsTableAnnotationComposer,
      $$ParentAccountsTableCreateCompanionBuilder,
      $$ParentAccountsTableUpdateCompanionBuilder,
      (
        ParentAccountRow,
        BaseReferences<_$AppDatabase, $ParentAccountsTable, ParentAccountRow>,
      ),
      ParentAccountRow,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String name,
      required String avatar,
      required int age,
      Value<String> nativeLanguage,
      required String currentLevel,
      Value<int> dailyNewWords,
      Value<int> dailyMinutes,
      required TranslationMode translationMode,
      Value<bool> swipeKnownRight,
      required DateTime createdAt,
      Value<List<String>> interests,
      Value<DateTime?> onboardedAt,
      Value<bool> levelLocked,
      Value<DateTime?> levelChangedAt,
      Value<DateTime?> stepBackDismissedAt,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> avatar,
      Value<int> age,
      Value<String> nativeLanguage,
      Value<String> currentLevel,
      Value<int> dailyNewWords,
      Value<int> dailyMinutes,
      Value<TranslationMode> translationMode,
      Value<bool> swipeKnownRight,
      Value<DateTime> createdAt,
      Value<List<String>> interests,
      Value<DateTime?> onboardedAt,
      Value<bool> levelLocked,
      Value<DateTime?> levelChangedAt,
      Value<DateTime?> stepBackDismissedAt,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordProgressTable, List<WordProgressRow>>
  _wordProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordProgress,
    aliasName: 'profiles__id__word_progress__profile_id',
  );

  $$WordProgressTableProcessedTableManager get wordProgressRefs {
    final manager = $$WordProgressTableTableManager(
      $_db,
      $_db.wordProgress,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionLogsTable, List<SessionLogRow>>
  _sessionLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionLogs,
    aliasName: 'profiles__id__session_logs__profile_id',
  );

  $$SessionLogsTableProcessedTableManager get sessionLogsRefs {
    final manager = $$SessionLogsTableTableManager(
      $_db,
      $_db.sessionLogs,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuizLogsTable, List<QuizLogRow>>
  _quizLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.quizLogs,
    aliasName: 'profiles__id__quiz_logs__profile_id',
  );

  $$QuizLogsTableProcessedTableManager get quizLogsRefs {
    final manager = $$QuizLogsTableTableManager(
      $_db,
      $_db.quizLogs,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_quizLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomWordsTable, List<CustomWordRow>>
  _customWordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customWords,
    aliasName: 'profiles__id__custom_words__profile_id',
  );

  $$CustomWordsTableProcessedTableManager get customWordsRefs {
    final manager = $$CustomWordsTableTableManager(
      $_db,
      $_db.customWords,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_customWordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyNewWords => $composableBuilder(
    column: $table.dailyNewWords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TranslationMode, TranslationMode, String>
  get translationMode => $composableBuilder(
    column: $table.translationMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get swipeKnownRight => $composableBuilder(
    column: $table.swipeKnownRight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get interests => $composableBuilder(
    column: $table.interests,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get onboardedAt => $composableBuilder(
    column: $table.onboardedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get levelLocked => $composableBuilder(
    column: $table.levelLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get levelChangedAt => $composableBuilder(
    column: $table.levelChangedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get stepBackDismissedAt => $composableBuilder(
    column: $table.stepBackDismissedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordProgressRefs(
    Expression<bool> Function($$WordProgressTableFilterComposer f) f,
  ) {
    final $$WordProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordProgress,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordProgressTableFilterComposer(
            $db: $db,
            $table: $db.wordProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionLogsRefs(
    Expression<bool> Function($$SessionLogsTableFilterComposer f) f,
  ) {
    final $$SessionLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionLogs,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionLogsTableFilterComposer(
            $db: $db,
            $table: $db.sessionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quizLogsRefs(
    Expression<bool> Function($$QuizLogsTableFilterComposer f) f,
  ) {
    final $$QuizLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizLogs,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuizLogsTableFilterComposer(
            $db: $db,
            $table: $db.quizLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customWordsRefs(
    Expression<bool> Function($$CustomWordsTableFilterComposer f) f,
  ) {
    final $$CustomWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customWords,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomWordsTableFilterComposer(
            $db: $db,
            $table: $db.customWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyNewWords => $composableBuilder(
    column: $table.dailyNewWords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationMode => $composableBuilder(
    column: $table.translationMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get swipeKnownRight => $composableBuilder(
    column: $table.swipeKnownRight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interests => $composableBuilder(
    column: $table.interests,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get onboardedAt => $composableBuilder(
    column: $table.onboardedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get levelLocked => $composableBuilder(
    column: $table.levelLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get levelChangedAt => $composableBuilder(
    column: $table.levelChangedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get stepBackDismissedAt => $composableBuilder(
    column: $table.stepBackDismissedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get nativeLanguage => $composableBuilder(
    column: $table.nativeLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentLevel => $composableBuilder(
    column: $table.currentLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyNewWords => $composableBuilder(
    column: $table.dailyNewWords,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TranslationMode, String>
  get translationMode => $composableBuilder(
    column: $table.translationMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get swipeKnownRight => $composableBuilder(
    column: $table.swipeKnownRight,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get interests =>
      $composableBuilder(column: $table.interests, builder: (column) => column);

  GeneratedColumn<DateTime> get onboardedAt => $composableBuilder(
    column: $table.onboardedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get levelLocked => $composableBuilder(
    column: $table.levelLocked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get levelChangedAt => $composableBuilder(
    column: $table.levelChangedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get stepBackDismissedAt => $composableBuilder(
    column: $table.stepBackDismissedAt,
    builder: (column) => column,
  );

  Expression<T> wordProgressRefs<T extends Object>(
    Expression<T> Function($$WordProgressTableAnnotationComposer a) f,
  ) {
    final $$WordProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordProgress,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.wordProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionLogsRefs<T extends Object>(
    Expression<T> Function($$SessionLogsTableAnnotationComposer a) f,
  ) {
    final $$SessionLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionLogs,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quizLogsRefs<T extends Object>(
    Expression<T> Function($$QuizLogsTableAnnotationComposer a) f,
  ) {
    final $$QuizLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizLogs,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuizLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.quizLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customWordsRefs<T extends Object>(
    Expression<T> Function($$CustomWordsTableAnnotationComposer a) f,
  ) {
    final $$CustomWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customWords,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.customWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (ProfileRow, $$ProfilesTableReferences),
          ProfileRow,
          PrefetchHooks Function({
            bool wordProgressRefs,
            bool sessionLogsRefs,
            bool quizLogsRefs,
            bool customWordsRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> avatar = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String> nativeLanguage = const Value.absent(),
                Value<String> currentLevel = const Value.absent(),
                Value<int> dailyNewWords = const Value.absent(),
                Value<int> dailyMinutes = const Value.absent(),
                Value<TranslationMode> translationMode = const Value.absent(),
                Value<bool> swipeKnownRight = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<List<String>> interests = const Value.absent(),
                Value<DateTime?> onboardedAt = const Value.absent(),
                Value<bool> levelLocked = const Value.absent(),
                Value<DateTime?> levelChangedAt = const Value.absent(),
                Value<DateTime?> stepBackDismissedAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                avatar: avatar,
                age: age,
                nativeLanguage: nativeLanguage,
                currentLevel: currentLevel,
                dailyNewWords: dailyNewWords,
                dailyMinutes: dailyMinutes,
                translationMode: translationMode,
                swipeKnownRight: swipeKnownRight,
                createdAt: createdAt,
                interests: interests,
                onboardedAt: onboardedAt,
                levelLocked: levelLocked,
                levelChangedAt: levelChangedAt,
                stepBackDismissedAt: stepBackDismissedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String avatar,
                required int age,
                Value<String> nativeLanguage = const Value.absent(),
                required String currentLevel,
                Value<int> dailyNewWords = const Value.absent(),
                Value<int> dailyMinutes = const Value.absent(),
                required TranslationMode translationMode,
                Value<bool> swipeKnownRight = const Value.absent(),
                required DateTime createdAt,
                Value<List<String>> interests = const Value.absent(),
                Value<DateTime?> onboardedAt = const Value.absent(),
                Value<bool> levelLocked = const Value.absent(),
                Value<DateTime?> levelChangedAt = const Value.absent(),
                Value<DateTime?> stepBackDismissedAt = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                avatar: avatar,
                age: age,
                nativeLanguage: nativeLanguage,
                currentLevel: currentLevel,
                dailyNewWords: dailyNewWords,
                dailyMinutes: dailyMinutes,
                translationMode: translationMode,
                swipeKnownRight: swipeKnownRight,
                createdAt: createdAt,
                interests: interests,
                onboardedAt: onboardedAt,
                levelLocked: levelLocked,
                levelChangedAt: levelChangedAt,
                stepBackDismissedAt: stepBackDismissedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wordProgressRefs = false,
                sessionLogsRefs = false,
                quizLogsRefs = false,
                customWordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordProgressRefs) db.wordProgress,
                    if (sessionLogsRefs) db.sessionLogs,
                    if (quizLogsRefs) db.quizLogs,
                    if (customWordsRefs) db.customWords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordProgressRefs)
                        await $_getPrefetchedDataByColumns<
                          ProfileRow,
                          $ProfilesTable,
                          WordProgressRow,
                          $WordProgressTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._wordProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).wordProgressRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (sessionLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          ProfileRow,
                          $ProfilesTable,
                          SessionLogRow,
                          $SessionLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._sessionLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (quizLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          ProfileRow,
                          $ProfilesTable,
                          QuizLogRow,
                          $QuizLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._quizLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).quizLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                      if (customWordsRefs)
                        await $_getPrefetchedDataByColumns<
                          ProfileRow,
                          $ProfilesTable,
                          CustomWordRow,
                          $CustomWordsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._customWordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).customWordsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'profile_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, $$ProfilesTableReferences),
      ProfileRow,
      PrefetchHooks Function({
        bool wordProgressRefs,
        bool sessionLogsRefs,
        bool quizLogsRefs,
        bool customWordsRefs,
      })
    >;
typedef $$WordProgressTableCreateCompanionBuilder =
    WordProgressCompanion Function({
      required int profileId,
      required String wordId,
      required WordState state,
      required double easeFactor,
      required int intervalDays,
      required int repetitions,
      Value<DateTime?> nextReviewAt,
      Value<DateTime?> lastAnsweredAt,
      required int correctCount,
      required int wrongCount,
      required DateTime firstSeenAt,
      Value<int> rowid,
    });
typedef $$WordProgressTableUpdateCompanionBuilder =
    WordProgressCompanion Function({
      Value<int> profileId,
      Value<String> wordId,
      Value<WordState> state,
      Value<double> easeFactor,
      Value<int> intervalDays,
      Value<int> repetitions,
      Value<DateTime?> nextReviewAt,
      Value<DateTime?> lastAnsweredAt,
      Value<int> correctCount,
      Value<int> wrongCount,
      Value<DateTime> firstSeenAt,
      Value<int> rowid,
    });

final class $$WordProgressTableReferences
    extends BaseReferences<_$AppDatabase, $WordProgressTable, WordProgressRow> {
  $$WordProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('word_progress__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordProgressTableFilterComposer
    extends Composer<_$AppDatabase, $WordProgressTable> {
  $$WordProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get wordId => $composableBuilder(
    column: $table.wordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WordState, WordState, String> get state =>
      $composableBuilder(
        column: $table.state,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAnsweredAt => $composableBuilder(
    column: $table.lastAnsweredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $WordProgressTable> {
  $$WordProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get wordId => $composableBuilder(
    column: $table.wordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAnsweredAt => $composableBuilder(
    column: $table.lastAnsweredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordProgressTable> {
  $$WordProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WordState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAnsweredAt => $composableBuilder(
    column: $table.lastAnsweredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wrongCount => $composableBuilder(
    column: $table.wrongCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordProgressTable,
          WordProgressRow,
          $$WordProgressTableFilterComposer,
          $$WordProgressTableOrderingComposer,
          $$WordProgressTableAnnotationComposer,
          $$WordProgressTableCreateCompanionBuilder,
          $$WordProgressTableUpdateCompanionBuilder,
          (WordProgressRow, $$WordProgressTableReferences),
          WordProgressRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$WordProgressTableTableManager(_$AppDatabase db, $WordProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<String> wordId = const Value.absent(),
                Value<WordState> state = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<DateTime?> lastAnsweredAt = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> wrongCount = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordProgressCompanion(
                profileId: profileId,
                wordId: wordId,
                state: state,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                repetitions: repetitions,
                nextReviewAt: nextReviewAt,
                lastAnsweredAt: lastAnsweredAt,
                correctCount: correctCount,
                wrongCount: wrongCount,
                firstSeenAt: firstSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                required String wordId,
                required WordState state,
                required double easeFactor,
                required int intervalDays,
                required int repetitions,
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<DateTime?> lastAnsweredAt = const Value.absent(),
                required int correctCount,
                required int wrongCount,
                required DateTime firstSeenAt,
                Value<int> rowid = const Value.absent(),
              }) => WordProgressCompanion.insert(
                profileId: profileId,
                wordId: wordId,
                state: state,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                repetitions: repetitions,
                nextReviewAt: nextReviewAt,
                lastAnsweredAt: lastAnsweredAt,
                correctCount: correctCount,
                wrongCount: wrongCount,
                firstSeenAt: firstSeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WordProgressTable, WordProgressRow>(table),
                  $$WordProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$WordProgressTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$WordProgressTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordProgressTable,
      WordProgressRow,
      $$WordProgressTableFilterComposer,
      $$WordProgressTableOrderingComposer,
      $$WordProgressTableAnnotationComposer,
      $$WordProgressTableCreateCompanionBuilder,
      $$WordProgressTableUpdateCompanionBuilder,
      (WordProgressRow, $$WordProgressTableReferences),
      WordProgressRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$SessionLogsTableCreateCompanionBuilder =
    SessionLogsCompanion Function({
      Value<int> id,
      required int profileId,
      required DateTime startedAt,
      required int durationSec,
      required int reviewed,
      required int newLearned,
      required double accuracy,
    });
typedef $$SessionLogsTableUpdateCompanionBuilder =
    SessionLogsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<DateTime> startedAt,
      Value<int> durationSec,
      Value<int> reviewed,
      Value<int> newLearned,
      Value<double> accuracy,
    });

final class $$SessionLogsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionLogsTable, SessionLogRow> {
  $$SessionLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('session_logs__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionLogsTable> {
  $$SessionLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewed => $composableBuilder(
    column: $table.reviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newLearned => $composableBuilder(
    column: $table.newLearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionLogsTable> {
  $$SessionLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewed => $composableBuilder(
    column: $table.reviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newLearned => $composableBuilder(
    column: $table.newLearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionLogsTable> {
  $$SessionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewed =>
      $composableBuilder(column: $table.reviewed, builder: (column) => column);

  GeneratedColumn<int> get newLearned => $composableBuilder(
    column: $table.newLearned,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionLogsTable,
          SessionLogRow,
          $$SessionLogsTableFilterComposer,
          $$SessionLogsTableOrderingComposer,
          $$SessionLogsTableAnnotationComposer,
          $$SessionLogsTableCreateCompanionBuilder,
          $$SessionLogsTableUpdateCompanionBuilder,
          (SessionLogRow, $$SessionLogsTableReferences),
          SessionLogRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$SessionLogsTableTableManager(_$AppDatabase db, $SessionLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
                Value<int> reviewed = const Value.absent(),
                Value<int> newLearned = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
              }) => SessionLogsCompanion(
                id: id,
                profileId: profileId,
                startedAt: startedAt,
                durationSec: durationSec,
                reviewed: reviewed,
                newLearned: newLearned,
                accuracy: accuracy,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required DateTime startedAt,
                required int durationSec,
                required int reviewed,
                required int newLearned,
                required double accuracy,
              }) => SessionLogsCompanion.insert(
                id: id,
                profileId: profileId,
                startedAt: startedAt,
                durationSec: durationSec,
                reviewed: reviewed,
                newLearned: newLearned,
                accuracy: accuracy,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionLogsTable, SessionLogRow>(table),
                  $$SessionLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$SessionLogsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$SessionLogsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionLogsTable,
      SessionLogRow,
      $$SessionLogsTableFilterComposer,
      $$SessionLogsTableOrderingComposer,
      $$SessionLogsTableAnnotationComposer,
      $$SessionLogsTableCreateCompanionBuilder,
      $$SessionLogsTableUpdateCompanionBuilder,
      (SessionLogRow, $$SessionLogsTableReferences),
      SessionLogRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$QuizLogsTableCreateCompanionBuilder =
    QuizLogsCompanion Function({
      Value<int> id,
      required int profileId,
      required String wordId,
      required String kind,
      required bool correct,
      required DateTime answeredAt,
    });
typedef $$QuizLogsTableUpdateCompanionBuilder =
    QuizLogsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> wordId,
      Value<String> kind,
      Value<bool> correct,
      Value<DateTime> answeredAt,
    });

final class $$QuizLogsTableReferences
    extends BaseReferences<_$AppDatabase, $QuizLogsTable, QuizLogRow> {
  $$QuizLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('quiz_logs__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuizLogsTableFilterComposer
    extends Composer<_$AppDatabase, $QuizLogsTable> {
  $$QuizLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wordId => $composableBuilder(
    column: $table.wordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuizLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizLogsTable> {
  $$QuizLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordId => $composableBuilder(
    column: $table.wordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuizLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizLogsTable> {
  $$QuizLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuizLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuizLogsTable,
          QuizLogRow,
          $$QuizLogsTableFilterComposer,
          $$QuizLogsTableOrderingComposer,
          $$QuizLogsTableAnnotationComposer,
          $$QuizLogsTableCreateCompanionBuilder,
          $$QuizLogsTableUpdateCompanionBuilder,
          (QuizLogRow, $$QuizLogsTableReferences),
          QuizLogRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$QuizLogsTableTableManager(_$AppDatabase db, $QuizLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> wordId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
              }) => QuizLogsCompanion(
                id: id,
                profileId: profileId,
                wordId: wordId,
                kind: kind,
                correct: correct,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String wordId,
                required String kind,
                required bool correct,
                required DateTime answeredAt,
              }) => QuizLogsCompanion.insert(
                id: id,
                profileId: profileId,
                wordId: wordId,
                kind: kind,
                correct: correct,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuizLogsTable, QuizLogRow>(table),
                  $$QuizLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$QuizLogsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$QuizLogsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuizLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuizLogsTable,
      QuizLogRow,
      $$QuizLogsTableFilterComposer,
      $$QuizLogsTableOrderingComposer,
      $$QuizLogsTableAnnotationComposer,
      $$QuizLogsTableCreateCompanionBuilder,
      $$QuizLogsTableUpdateCompanionBuilder,
      (QuizLogRow, $$QuizLogsTableReferences),
      QuizLogRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$CustomWordsTableCreateCompanionBuilder =
    CustomWordsCompanion Function({
      Value<int> id,
      required int profileId,
      Value<String?> wordId,
      required String word,
      Value<String> definition,
      Value<String?> translation,
      Value<String?> emoji,
      required DateTime addedAt,
    });
typedef $$CustomWordsTableUpdateCompanionBuilder =
    CustomWordsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String?> wordId,
      Value<String> word,
      Value<String> definition,
      Value<String?> translation,
      Value<String?> emoji,
      Value<DateTime> addedAt,
    });

final class $$CustomWordsTableReferences
    extends BaseReferences<_$AppDatabase, $CustomWordsTable, CustomWordRow> {
  $$CustomWordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('custom_words__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomWordsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomWordsTable> {
  $$CustomWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wordId => $composableBuilder(
    column: $table.wordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomWordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomWordsTable> {
  $$CustomWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordId => $composableBuilder(
    column: $table.wordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomWordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomWordsTable> {
  $$CustomWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomWordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomWordsTable,
          CustomWordRow,
          $$CustomWordsTableFilterComposer,
          $$CustomWordsTableOrderingComposer,
          $$CustomWordsTableAnnotationComposer,
          $$CustomWordsTableCreateCompanionBuilder,
          $$CustomWordsTableUpdateCompanionBuilder,
          (CustomWordRow, $$CustomWordsTableReferences),
          CustomWordRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$CustomWordsTableTableManager(_$AppDatabase db, $CustomWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String?> wordId = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String?> translation = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => CustomWordsCompanion(
                id: id,
                profileId: profileId,
                wordId: wordId,
                word: word,
                definition: definition,
                translation: translation,
                emoji: emoji,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                Value<String?> wordId = const Value.absent(),
                required String word,
                Value<String> definition = const Value.absent(),
                Value<String?> translation = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                required DateTime addedAt,
              }) => CustomWordsCompanion.insert(
                id: id,
                profileId: profileId,
                wordId: wordId,
                word: word,
                definition: definition,
                translation: translation,
                emoji: emoji,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomWordsTable, CustomWordRow>(table),
                  $$CustomWordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$CustomWordsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$CustomWordsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomWordsTable,
      CustomWordRow,
      $$CustomWordsTableFilterComposer,
      $$CustomWordsTableOrderingComposer,
      $$CustomWordsTableAnnotationComposer,
      $$CustomWordsTableCreateCompanionBuilder,
      $$CustomWordsTableUpdateCompanionBuilder,
      (CustomWordRow, $$CustomWordsTableReferences),
      CustomWordRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaRow,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaRow,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>,
          ),
          AppMetaRow,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTable, AppMetaRow>(table),
                  BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaRow,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
      AppMetaRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$TranslationsTableTableManager get translations =>
      $$TranslationsTableTableManager(_db, _db.translations);
  $$ParentAccountsTableTableManager get parentAccounts =>
      $$ParentAccountsTableTableManager(_db, _db.parentAccounts);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$WordProgressTableTableManager get wordProgress =>
      $$WordProgressTableTableManager(_db, _db.wordProgress);
  $$SessionLogsTableTableManager get sessionLogs =>
      $$SessionLogsTableTableManager(_db, _db.sessionLogs);
  $$QuizLogsTableTableManager get quizLogs =>
      $$QuizLogsTableTableManager(_db, _db.quizLogs);
  $$CustomWordsTableTableManager get customWords =>
      $$CustomWordsTableTableManager(_db, _db.customWords);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
}
