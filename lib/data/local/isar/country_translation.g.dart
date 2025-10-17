// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_translation.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCountryTranslationEntityCollection on Isar {
  IsarCollection<CountryTranslationEntity> get countryTranslationEntitys =>
      this.collection();
}

const CountryTranslationEntitySchema = CollectionSchema(
  name: r'CountryTranslationEntity',
  id: -2013486865922696118,
  properties: {
    r'iso3166_1': PropertySchema(
      id: 0,
      name: r'iso3166_1',
      type: IsarType.string,
    ),
    r'locale': PropertySchema(
      id: 1,
      name: r'locale',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _countryTranslationEntityEstimateSize,
  serialize: _countryTranslationEntitySerialize,
  deserialize: _countryTranslationEntityDeserialize,
  deserializeProp: _countryTranslationEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'iso3166_1_locale': IndexSchema(
      id: -1777727100910144982,
      name: r'iso3166_1_locale',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'iso3166_1',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'locale',
          type: IndexType.hash,
          caseSensitive: true,
        )
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _countryTranslationEntityGetId,
  getLinks: _countryTranslationEntityGetLinks,
  attach: _countryTranslationEntityAttach,
  version: '3.1.0+1',
);

int _countryTranslationEntityEstimateSize(
  CountryTranslationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.iso3166_1.length * 3;
  bytesCount += 3 + object.locale.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _countryTranslationEntitySerialize(
  CountryTranslationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.iso3166_1);
  writer.writeString(offsets[1], object.locale);
  writer.writeString(offsets[2], object.name);
}

CountryTranslationEntity _countryTranslationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CountryTranslationEntity();
  object.id = id;
  object.iso3166_1 = reader.readString(offsets[0]);
  object.locale = reader.readString(offsets[1]);
  object.name = reader.readString(offsets[2]);
  return object;
}

P _countryTranslationEntityDeserializeProp<P>(
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

Id _countryTranslationEntityGetId(CountryTranslationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _countryTranslationEntityGetLinks(
    CountryTranslationEntity object) {
  return [];
}

void _countryTranslationEntityAttach(
    IsarCollection<dynamic> col, Id id, CountryTranslationEntity object) {
  object.id = id;
}

extension CountryTranslationEntityByIndex
    on IsarCollection<CountryTranslationEntity> {
  Future<CountryTranslationEntity?> getByIso3166_1Locale(
      String iso3166_1, String locale) {
    return getByIndex(r'iso3166_1_locale', [iso3166_1, locale]);
  }

  CountryTranslationEntity? getByIso3166_1LocaleSync(
      String iso3166_1, String locale) {
    return getByIndexSync(r'iso3166_1_locale', [iso3166_1, locale]);
  }

  Future<bool> deleteByIso3166_1Locale(String iso3166_1, String locale) {
    return deleteByIndex(r'iso3166_1_locale', [iso3166_1, locale]);
  }

  bool deleteByIso3166_1LocaleSync(String iso3166_1, String locale) {
    return deleteByIndexSync(r'iso3166_1_locale', [iso3166_1, locale]);
  }

  Future<List<CountryTranslationEntity?>> getAllByIso3166_1Locale(
      List<String> iso3166_1Values, List<String> localeValues) {
    final len = iso3166_1Values.length;
    assert(localeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([iso3166_1Values[i], localeValues[i]]);
    }

    return getAllByIndex(r'iso3166_1_locale', values);
  }

  List<CountryTranslationEntity?> getAllByIso3166_1LocaleSync(
      List<String> iso3166_1Values, List<String> localeValues) {
    final len = iso3166_1Values.length;
    assert(localeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([iso3166_1Values[i], localeValues[i]]);
    }

    return getAllByIndexSync(r'iso3166_1_locale', values);
  }

  Future<int> deleteAllByIso3166_1Locale(
      List<String> iso3166_1Values, List<String> localeValues) {
    final len = iso3166_1Values.length;
    assert(localeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([iso3166_1Values[i], localeValues[i]]);
    }

    return deleteAllByIndex(r'iso3166_1_locale', values);
  }

  int deleteAllByIso3166_1LocaleSync(
      List<String> iso3166_1Values, List<String> localeValues) {
    final len = iso3166_1Values.length;
    assert(localeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([iso3166_1Values[i], localeValues[i]]);
    }

    return deleteAllByIndexSync(r'iso3166_1_locale', values);
  }

  Future<Id> putByIso3166_1Locale(CountryTranslationEntity object) {
    return putByIndex(r'iso3166_1_locale', object);
  }

  Id putByIso3166_1LocaleSync(CountryTranslationEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'iso3166_1_locale', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIso3166_1Locale(
      List<CountryTranslationEntity> objects) {
    return putAllByIndex(r'iso3166_1_locale', objects);
  }

  List<Id> putAllByIso3166_1LocaleSync(List<CountryTranslationEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'iso3166_1_locale', objects,
        saveLinks: saveLinks);
  }
}

extension CountryTranslationEntityQueryWhereSort on QueryBuilder<
    CountryTranslationEntity, CountryTranslationEntity, QWhere> {
  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CountryTranslationEntityQueryWhere on QueryBuilder<
    CountryTranslationEntity, CountryTranslationEntity, QWhereClause> {
  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterWhereClause> iso3166_1EqualToAnyLocale(String iso3166_1) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'iso3166_1_locale',
        value: [iso3166_1],
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterWhereClause> iso3166_1NotEqualToAnyLocale(String iso3166_1) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1_locale',
              lower: [],
              upper: [iso3166_1],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1_locale',
              lower: [iso3166_1],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1_locale',
              lower: [iso3166_1],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1_locale',
              lower: [],
              upper: [iso3166_1],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
          QAfterWhereClause>
      iso3166_1LocaleEqualTo(String iso3166_1, String locale) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'iso3166_1_locale',
        value: [iso3166_1, locale],
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
          QAfterWhereClause>
      iso3166_1EqualToLocaleNotEqualTo(String iso3166_1, String locale) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1_locale',
              lower: [iso3166_1],
              upper: [iso3166_1, locale],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1_locale',
              lower: [iso3166_1, locale],
              includeLower: false,
              upper: [iso3166_1],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1_locale',
              lower: [iso3166_1, locale],
              includeLower: false,
              upper: [iso3166_1],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1_locale',
              lower: [iso3166_1],
              upper: [iso3166_1, locale],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterWhereClause> localeEqualTo(String locale) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'locale',
        value: [locale],
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterWhereClause> localeNotEqualTo(String locale) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locale',
              lower: [],
              upper: [locale],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locale',
              lower: [locale],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locale',
              lower: [locale],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locale',
              lower: [],
              upper: [locale],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CountryTranslationEntityQueryFilter on QueryBuilder<
    CountryTranslationEntity, CountryTranslationEntity, QFilterCondition> {
  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> iso3166_1EqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iso3166_1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> iso3166_1GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iso3166_1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> iso3166_1LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iso3166_1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> iso3166_1Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iso3166_1',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> iso3166_1StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iso3166_1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> iso3166_1EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iso3166_1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
          QAfterFilterCondition>
      iso3166_1Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iso3166_1',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
          QAfterFilterCondition>
      iso3166_1Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iso3166_1',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> iso3166_1IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iso3166_1',
        value: '',
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> iso3166_1IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iso3166_1',
        value: '',
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> localeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> localeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> localeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> localeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locale',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> localeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> localeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
          QAfterFilterCondition>
      localeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
          QAfterFilterCondition>
      localeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locale',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> localeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> localeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension CountryTranslationEntityQueryObject on QueryBuilder<
    CountryTranslationEntity, CountryTranslationEntity, QFilterCondition> {}

extension CountryTranslationEntityQueryLinks on QueryBuilder<
    CountryTranslationEntity, CountryTranslationEntity, QFilterCondition> {}

extension CountryTranslationEntityQuerySortBy on QueryBuilder<
    CountryTranslationEntity, CountryTranslationEntity, QSortBy> {
  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      sortByIso3166_1() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso3166_1', Sort.asc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      sortByIso3166_1Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso3166_1', Sort.desc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      sortByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      sortByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension CountryTranslationEntityQuerySortThenBy on QueryBuilder<
    CountryTranslationEntity, CountryTranslationEntity, QSortThenBy> {
  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      thenByIso3166_1() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso3166_1', Sort.asc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      thenByIso3166_1Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso3166_1', Sort.desc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      thenByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      thenByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension CountryTranslationEntityQueryWhereDistinct on QueryBuilder<
    CountryTranslationEntity, CountryTranslationEntity, QDistinct> {
  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QDistinct>
      distinctByIso3166_1({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iso3166_1', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QDistinct>
      distinctByLocale({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CountryTranslationEntity, CountryTranslationEntity, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension CountryTranslationEntityQueryProperty on QueryBuilder<
    CountryTranslationEntity, CountryTranslationEntity, QQueryProperty> {
  QueryBuilder<CountryTranslationEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CountryTranslationEntity, String, QQueryOperations>
      iso3166_1Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iso3166_1');
    });
  }

  QueryBuilder<CountryTranslationEntity, String, QQueryOperations>
      localeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locale');
    });
  }

  QueryBuilder<CountryTranslationEntity, String, QQueryOperations>
      nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
