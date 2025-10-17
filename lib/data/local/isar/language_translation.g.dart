// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_translation.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLanguageTranslationEntityCollection on Isar {
  IsarCollection<LanguageTranslationEntity> get languageTranslationEntitys =>
      this.collection();
}

const LanguageTranslationEntitySchema = CollectionSchema(
  name: r'LanguageTranslationEntity',
  id: 4443322735694385585,
  properties: {
    r'iso639_1': PropertySchema(
      id: 0,
      name: r'iso639_1',
      type: IsarType.string,
    ),
    r'locale': PropertySchema(id: 1, name: r'locale', type: IsarType.string),
    r'name': PropertySchema(id: 2, name: r'name', type: IsarType.string),
  },
  estimateSize: _languageTranslationEntityEstimateSize,
  serialize: _languageTranslationEntitySerialize,
  deserialize: _languageTranslationEntityDeserialize,
  deserializeProp: _languageTranslationEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'iso639_1_locale': IndexSchema(
      id: 6415971232823092188,
      name: r'iso639_1_locale',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'iso639_1',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'locale',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'locale': IndexSchema(
      id: -8287102531631808820,
      name: r'locale',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'locale',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _languageTranslationEntityGetId,
  getLinks: _languageTranslationEntityGetLinks,
  attach: _languageTranslationEntityAttach,
  version: '3.1.0+1',
);

int _languageTranslationEntityEstimateSize(
  LanguageTranslationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.iso639_1.length * 3;
  bytesCount += 3 + object.locale.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _languageTranslationEntitySerialize(
  LanguageTranslationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.iso639_1);
  writer.writeString(offsets[1], object.locale);
  writer.writeString(offsets[2], object.name);
}

LanguageTranslationEntity _languageTranslationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LanguageTranslationEntity();
  object.id = id;
  object.iso639_1 = reader.readString(offsets[0]);
  object.locale = reader.readString(offsets[1]);
  object.name = reader.readString(offsets[2]);
  return object;
}

P _languageTranslationEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _languageTranslationEntityGetId(LanguageTranslationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _languageTranslationEntityGetLinks(
  LanguageTranslationEntity object,
) {
  return [];
}

void _languageTranslationEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  LanguageTranslationEntity object,
) {
  object.id = id;
}

extension LanguageTranslationEntityByIndex
    on IsarCollection<LanguageTranslationEntity> {
  Future<LanguageTranslationEntity?> getByIso639_1Locale(
    String iso639_1,
    String locale,
  ) {
    return getByIndex(r'iso639_1_locale', [iso639_1, locale]);
  }

  LanguageTranslationEntity? getByIso639_1LocaleSync(
    String iso639_1,
    String locale,
  ) {
    return getByIndexSync(r'iso639_1_locale', [iso639_1, locale]);
  }

  Future<bool> deleteByIso639_1Locale(String iso639_1, String locale) {
    return deleteByIndex(r'iso639_1_locale', [iso639_1, locale]);
  }

  bool deleteByIso639_1LocaleSync(String iso639_1, String locale) {
    return deleteByIndexSync(r'iso639_1_locale', [iso639_1, locale]);
  }

  Future<List<LanguageTranslationEntity?>> getAllByIso639_1Locale(
    List<String> iso639_1Values,
    List<String> localeValues,
  ) {
    final len = iso639_1Values.length;
    assert(
      localeValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([iso639_1Values[i], localeValues[i]]);
    }

    return getAllByIndex(r'iso639_1_locale', values);
  }

  List<LanguageTranslationEntity?> getAllByIso639_1LocaleSync(
    List<String> iso639_1Values,
    List<String> localeValues,
  ) {
    final len = iso639_1Values.length;
    assert(
      localeValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([iso639_1Values[i], localeValues[i]]);
    }

    return getAllByIndexSync(r'iso639_1_locale', values);
  }

  Future<int> deleteAllByIso639_1Locale(
    List<String> iso639_1Values,
    List<String> localeValues,
  ) {
    final len = iso639_1Values.length;
    assert(
      localeValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([iso639_1Values[i], localeValues[i]]);
    }

    return deleteAllByIndex(r'iso639_1_locale', values);
  }

  int deleteAllByIso639_1LocaleSync(
    List<String> iso639_1Values,
    List<String> localeValues,
  ) {
    final len = iso639_1Values.length;
    assert(
      localeValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([iso639_1Values[i], localeValues[i]]);
    }

    return deleteAllByIndexSync(r'iso639_1_locale', values);
  }

  Future<Id> putByIso639_1Locale(LanguageTranslationEntity object) {
    return putByIndex(r'iso639_1_locale', object);
  }

  Id putByIso639_1LocaleSync(
    LanguageTranslationEntity object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'iso639_1_locale', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIso639_1Locale(
    List<LanguageTranslationEntity> objects,
  ) {
    return putAllByIndex(r'iso639_1_locale', objects);
  }

  List<Id> putAllByIso639_1LocaleSync(
    List<LanguageTranslationEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'iso639_1_locale', objects, saveLinks: saveLinks);
  }
}

extension LanguageTranslationEntityQueryWhereSort
    on
        QueryBuilder<
          LanguageTranslationEntity,
          LanguageTranslationEntity,
          QWhere
        > {
  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LanguageTranslationEntityQueryWhere
    on
        QueryBuilder<
          LanguageTranslationEntity,
          LanguageTranslationEntity,
          QWhereClause
        > {
  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  iso639_1EqualToAnyLocale(String iso639_1) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'iso639_1_locale',
          value: [iso639_1],
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  iso639_1NotEqualToAnyLocale(String iso639_1) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'iso639_1_locale',
                lower: [],
                upper: [iso639_1],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'iso639_1_locale',
                lower: [iso639_1],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'iso639_1_locale',
                lower: [iso639_1],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'iso639_1_locale',
                lower: [],
                upper: [iso639_1],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  iso639_1LocaleEqualTo(String iso639_1, String locale) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'iso639_1_locale',
          value: [iso639_1, locale],
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  iso639_1EqualToLocaleNotEqualTo(String iso639_1, String locale) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'iso639_1_locale',
                lower: [iso639_1],
                upper: [iso639_1, locale],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'iso639_1_locale',
                lower: [iso639_1, locale],
                includeLower: false,
                upper: [iso639_1],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'iso639_1_locale',
                lower: [iso639_1, locale],
                includeLower: false,
                upper: [iso639_1],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'iso639_1_locale',
                lower: [iso639_1],
                upper: [iso639_1, locale],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  localeEqualTo(String locale) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'locale', value: [locale]),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterWhereClause
  >
  localeNotEqualTo(String locale) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'locale',
                lower: [],
                upper: [locale],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'locale',
                lower: [locale],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'locale',
                lower: [locale],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'locale',
                lower: [],
                upper: [locale],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension LanguageTranslationEntityQueryFilter
    on
        QueryBuilder<
          LanguageTranslationEntity,
          LanguageTranslationEntity,
          QFilterCondition
        > {
  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  iso639_1EqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'iso639_1',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  iso639_1GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'iso639_1',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  iso639_1LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'iso639_1',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  iso639_1Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'iso639_1',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  iso639_1StartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'iso639_1',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  iso639_1EndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'iso639_1',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  iso639_1Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'iso639_1',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  iso639_1Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'iso639_1',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  iso639_1IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'iso639_1', value: ''),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  iso639_1IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'iso639_1', value: ''),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  localeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'locale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  localeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'locale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  localeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'locale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  localeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'locale',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  localeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'locale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  localeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'locale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  localeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'locale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  localeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'locale',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  localeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'locale', value: ''),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  localeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'locale', value: ''),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterFilterCondition
  >
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }
}

extension LanguageTranslationEntityQueryObject
    on
        QueryBuilder<
          LanguageTranslationEntity,
          LanguageTranslationEntity,
          QFilterCondition
        > {}

extension LanguageTranslationEntityQueryLinks
    on
        QueryBuilder<
          LanguageTranslationEntity,
          LanguageTranslationEntity,
          QFilterCondition
        > {}

extension LanguageTranslationEntityQuerySortBy
    on
        QueryBuilder<
          LanguageTranslationEntity,
          LanguageTranslationEntity,
          QSortBy
        > {
  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  sortByIso639_1() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso639_1', Sort.asc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  sortByIso639_1Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso639_1', Sort.desc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  sortByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  sortByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension LanguageTranslationEntityQuerySortThenBy
    on
        QueryBuilder<
          LanguageTranslationEntity,
          LanguageTranslationEntity,
          QSortThenBy
        > {
  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  thenByIso639_1() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso639_1', Sort.asc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  thenByIso639_1Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso639_1', Sort.desc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  thenByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  thenByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<
    LanguageTranslationEntity,
    LanguageTranslationEntity,
    QAfterSortBy
  >
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension LanguageTranslationEntityQueryWhereDistinct
    on
        QueryBuilder<
          LanguageTranslationEntity,
          LanguageTranslationEntity,
          QDistinct
        > {
  QueryBuilder<LanguageTranslationEntity, LanguageTranslationEntity, QDistinct>
  distinctByIso639_1({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iso639_1', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LanguageTranslationEntity, LanguageTranslationEntity, QDistinct>
  distinctByLocale({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LanguageTranslationEntity, LanguageTranslationEntity, QDistinct>
  distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension LanguageTranslationEntityQueryProperty
    on
        QueryBuilder<
          LanguageTranslationEntity,
          LanguageTranslationEntity,
          QQueryProperty
        > {
  QueryBuilder<LanguageTranslationEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LanguageTranslationEntity, String, QQueryOperations>
  iso639_1Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iso639_1');
    });
  }

  QueryBuilder<LanguageTranslationEntity, String, QQueryOperations>
  localeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locale');
    });
  }

  QueryBuilder<LanguageTranslationEntity, String, QQueryOperations>
  nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
