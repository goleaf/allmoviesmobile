// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_provider_region.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWatchProviderRegionEntityCollection on Isar {
  IsarCollection<WatchProviderRegionEntity> get watchProviderRegionEntitys =>
      this.collection();
}

const WatchProviderRegionEntitySchema = CollectionSchema(
  name: r'WatchProviderRegionEntity',
  id: -7295825730063972728,
  properties: {
    r'englishName': PropertySchema(
      id: 0,
      name: r'englishName',
      type: IsarType.string,
    ),
    r'iso3166_1': PropertySchema(
      id: 1,
      name: r'iso3166_1',
      type: IsarType.string,
    ),
    r'nativeName': PropertySchema(
      id: 2,
      name: r'nativeName',
      type: IsarType.string,
    )
  },
  estimateSize: _watchProviderRegionEntityEstimateSize,
  serialize: _watchProviderRegionEntitySerialize,
  deserialize: _watchProviderRegionEntityDeserialize,
  deserializeProp: _watchProviderRegionEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'iso3166_1': IndexSchema(
      id: -8619592972702828730,
      name: r'iso3166_1',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'iso3166_1',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _watchProviderRegionEntityGetId,
  getLinks: _watchProviderRegionEntityGetLinks,
  attach: _watchProviderRegionEntityAttach,
  version: '3.1.0+1',
);

int _watchProviderRegionEntityEstimateSize(
  WatchProviderRegionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.englishName.length * 3;
  bytesCount += 3 + object.iso3166_1.length * 3;
  {
    final value = object.nativeName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _watchProviderRegionEntitySerialize(
  WatchProviderRegionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.englishName);
  writer.writeString(offsets[1], object.iso3166_1);
  writer.writeString(offsets[2], object.nativeName);
}

WatchProviderRegionEntity _watchProviderRegionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WatchProviderRegionEntity();
  object.englishName = reader.readString(offsets[0]);
  object.id = id;
  object.iso3166_1 = reader.readString(offsets[1]);
  object.nativeName = reader.readStringOrNull(offsets[2]);
  return object;
}

P _watchProviderRegionEntityDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _watchProviderRegionEntityGetId(WatchProviderRegionEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _watchProviderRegionEntityGetLinks(
    WatchProviderRegionEntity object) {
  return [];
}

void _watchProviderRegionEntityAttach(
    IsarCollection<dynamic> col, Id id, WatchProviderRegionEntity object) {
  object.id = id;
}

extension WatchProviderRegionEntityByIndex
    on IsarCollection<WatchProviderRegionEntity> {
  Future<WatchProviderRegionEntity?> getByIso3166_1(String iso3166_1) {
    return getByIndex(r'iso3166_1', [iso3166_1]);
  }

  WatchProviderRegionEntity? getByIso3166_1Sync(String iso3166_1) {
    return getByIndexSync(r'iso3166_1', [iso3166_1]);
  }

  Future<bool> deleteByIso3166_1(String iso3166_1) {
    return deleteByIndex(r'iso3166_1', [iso3166_1]);
  }

  bool deleteByIso3166_1Sync(String iso3166_1) {
    return deleteByIndexSync(r'iso3166_1', [iso3166_1]);
  }

  Future<List<WatchProviderRegionEntity?>> getAllByIso3166_1(
      List<String> iso3166_1Values) {
    final values = iso3166_1Values.map((e) => [e]).toList();
    return getAllByIndex(r'iso3166_1', values);
  }

  List<WatchProviderRegionEntity?> getAllByIso3166_1Sync(
      List<String> iso3166_1Values) {
    final values = iso3166_1Values.map((e) => [e]).toList();
    return getAllByIndexSync(r'iso3166_1', values);
  }

  Future<int> deleteAllByIso3166_1(List<String> iso3166_1Values) {
    final values = iso3166_1Values.map((e) => [e]).toList();
    return deleteAllByIndex(r'iso3166_1', values);
  }

  int deleteAllByIso3166_1Sync(List<String> iso3166_1Values) {
    final values = iso3166_1Values.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'iso3166_1', values);
  }

  Future<Id> putByIso3166_1(WatchProviderRegionEntity object) {
    return putByIndex(r'iso3166_1', object);
  }

  Id putByIso3166_1Sync(WatchProviderRegionEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'iso3166_1', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIso3166_1(List<WatchProviderRegionEntity> objects) {
    return putAllByIndex(r'iso3166_1', objects);
  }

  List<Id> putAllByIso3166_1Sync(List<WatchProviderRegionEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'iso3166_1', objects, saveLinks: saveLinks);
  }
}

extension WatchProviderRegionEntityQueryWhereSort on QueryBuilder<
    WatchProviderRegionEntity, WatchProviderRegionEntity, QWhere> {
  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WatchProviderRegionEntityQueryWhere on QueryBuilder<
    WatchProviderRegionEntity, WatchProviderRegionEntity, QWhereClause> {
  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterWhereClause> iso3166_1EqualTo(String iso3166_1) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'iso3166_1',
        value: [iso3166_1],
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterWhereClause> iso3166_1NotEqualTo(String iso3166_1) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1',
              lower: [],
              upper: [iso3166_1],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1',
              lower: [iso3166_1],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1',
              lower: [iso3166_1],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'iso3166_1',
              lower: [],
              upper: [iso3166_1],
              includeUpper: false,
            ));
      }
    });
  }
}

extension WatchProviderRegionEntityQueryFilter on QueryBuilder<
    WatchProviderRegionEntity, WatchProviderRegionEntity, QFilterCondition> {
  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> englishNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'englishName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> englishNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'englishName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> englishNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'englishName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> englishNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'englishName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> englishNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'englishName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> englishNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'englishName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
          QAfterFilterCondition>
      englishNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'englishName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
          QAfterFilterCondition>
      englishNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'englishName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> englishNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'englishName',
        value: '',
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> englishNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'englishName',
        value: '',
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
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

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> iso3166_1IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iso3166_1',
        value: '',
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> iso3166_1IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iso3166_1',
        value: '',
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> nativeNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nativeName',
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> nativeNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nativeName',
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> nativeNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nativeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> nativeNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nativeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> nativeNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nativeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> nativeNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nativeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> nativeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nativeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> nativeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nativeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
          QAfterFilterCondition>
      nativeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nativeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
          QAfterFilterCondition>
      nativeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nativeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> nativeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nativeName',
        value: '',
      ));
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterFilterCondition> nativeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nativeName',
        value: '',
      ));
    });
  }
}

extension WatchProviderRegionEntityQueryObject on QueryBuilder<
    WatchProviderRegionEntity, WatchProviderRegionEntity, QFilterCondition> {}

extension WatchProviderRegionEntityQueryLinks on QueryBuilder<
    WatchProviderRegionEntity, WatchProviderRegionEntity, QFilterCondition> {}

extension WatchProviderRegionEntityQuerySortBy on QueryBuilder<
    WatchProviderRegionEntity, WatchProviderRegionEntity, QSortBy> {
  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> sortByEnglishName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishName', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> sortByEnglishNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishName', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> sortByIso3166_1() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso3166_1', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> sortByIso3166_1Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso3166_1', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> sortByNativeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nativeName', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> sortByNativeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nativeName', Sort.desc);
    });
  }
}

extension WatchProviderRegionEntityQuerySortThenBy on QueryBuilder<
    WatchProviderRegionEntity, WatchProviderRegionEntity, QSortThenBy> {
  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> thenByEnglishName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishName', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> thenByEnglishNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishName', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> thenByIso3166_1() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso3166_1', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> thenByIso3166_1Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iso3166_1', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> thenByNativeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nativeName', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity,
      QAfterSortBy> thenByNativeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nativeName', Sort.desc);
    });
  }
}

extension WatchProviderRegionEntityQueryWhereDistinct on QueryBuilder<
    WatchProviderRegionEntity, WatchProviderRegionEntity, QDistinct> {
  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity, QDistinct>
      distinctByEnglishName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'englishName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity, QDistinct>
      distinctByIso3166_1({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iso3166_1', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WatchProviderRegionEntity, WatchProviderRegionEntity, QDistinct>
      distinctByNativeName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nativeName', caseSensitive: caseSensitive);
    });
  }
}

extension WatchProviderRegionEntityQueryProperty on QueryBuilder<
    WatchProviderRegionEntity, WatchProviderRegionEntity, QQueryProperty> {
  QueryBuilder<WatchProviderRegionEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WatchProviderRegionEntity, String, QQueryOperations>
      englishNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'englishName');
    });
  }

  QueryBuilder<WatchProviderRegionEntity, String, QQueryOperations>
      iso3166_1Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iso3166_1');
    });
  }

  QueryBuilder<WatchProviderRegionEntity, String?, QQueryOperations>
      nativeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nativeName');
    });
  }
}
