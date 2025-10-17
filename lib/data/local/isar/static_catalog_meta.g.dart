// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'static_catalog_meta.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStaticCatalogMetaEntityCollection on Isar {
  IsarCollection<StaticCatalogMetaEntity> get staticCatalogMetaEntitys =>
      this.collection();
}

const StaticCatalogMetaEntitySchema = CollectionSchema(
  name: r'StaticCatalogMetaEntity',
  id: -8150840489294966516,
  properties: {
    r'key': PropertySchema(
      id: 0,
      name: r'key',
      type: IsarType.string,
    ),
    r'lastUpdatedMs': PropertySchema(
      id: 1,
      name: r'lastUpdatedMs',
      type: IsarType.long,
    ),
    r'localesCsv': PropertySchema(
      id: 2,
      name: r'localesCsv',
      type: IsarType.string,
    )
  },
  estimateSize: _staticCatalogMetaEntityEstimateSize,
  serialize: _staticCatalogMetaEntitySerialize,
  deserialize: _staticCatalogMetaEntityDeserialize,
  deserializeProp: _staticCatalogMetaEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _staticCatalogMetaEntityGetId,
  getLinks: _staticCatalogMetaEntityGetLinks,
  attach: _staticCatalogMetaEntityAttach,
  version: '3.1.0+1',
);

int _staticCatalogMetaEntityEstimateSize(
  StaticCatalogMetaEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.localesCsv.length * 3;
  return bytesCount;
}

void _staticCatalogMetaEntitySerialize(
  StaticCatalogMetaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.key);
  writer.writeLong(offsets[1], object.lastUpdatedMs);
  writer.writeString(offsets[2], object.localesCsv);
}

StaticCatalogMetaEntity _staticCatalogMetaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StaticCatalogMetaEntity();
  object.id = id;
  object.key = reader.readString(offsets[0]);
  object.lastUpdatedMs = reader.readLong(offsets[1]);
  object.localesCsv = reader.readString(offsets[2]);
  return object;
}

P _staticCatalogMetaEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _staticCatalogMetaEntityGetId(StaticCatalogMetaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _staticCatalogMetaEntityGetLinks(
    StaticCatalogMetaEntity object) {
  return [];
}

void _staticCatalogMetaEntityAttach(
    IsarCollection<dynamic> col, Id id, StaticCatalogMetaEntity object) {
  object.id = id;
}

extension StaticCatalogMetaEntityByIndex
    on IsarCollection<StaticCatalogMetaEntity> {
  Future<StaticCatalogMetaEntity?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  StaticCatalogMetaEntity? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<StaticCatalogMetaEntity?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<StaticCatalogMetaEntity?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(StaticCatalogMetaEntity object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(StaticCatalogMetaEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<StaticCatalogMetaEntity> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<StaticCatalogMetaEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension StaticCatalogMetaEntityQueryWhereSort
    on QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QWhere> {
  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StaticCatalogMetaEntityQueryWhere on QueryBuilder<
    StaticCatalogMetaEntity, StaticCatalogMetaEntity, QWhereClause> {
  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
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

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
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

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterWhereClause> keyEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'key',
        value: [key],
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterWhereClause> keyNotEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ));
      }
    });
  }
}

extension StaticCatalogMetaEntityQueryFilter on QueryBuilder<
    StaticCatalogMetaEntity, StaticCatalogMetaEntity, QFilterCondition> {
  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
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

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
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

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
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

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
          QAfterFilterCondition>
      keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
          QAfterFilterCondition>
      keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> lastUpdatedMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdatedMs',
        value: value,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> lastUpdatedMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdatedMs',
        value: value,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> lastUpdatedMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdatedMs',
        value: value,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> lastUpdatedMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdatedMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> localesCsvEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localesCsv',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> localesCsvGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localesCsv',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> localesCsvLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localesCsv',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> localesCsvBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localesCsv',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> localesCsvStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localesCsv',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> localesCsvEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localesCsv',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
          QAfterFilterCondition>
      localesCsvContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localesCsv',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
          QAfterFilterCondition>
      localesCsvMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localesCsv',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> localesCsvIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localesCsv',
        value: '',
      ));
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity,
      QAfterFilterCondition> localesCsvIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localesCsv',
        value: '',
      ));
    });
  }
}

extension StaticCatalogMetaEntityQueryObject on QueryBuilder<
    StaticCatalogMetaEntity, StaticCatalogMetaEntity, QFilterCondition> {}

extension StaticCatalogMetaEntityQueryLinks on QueryBuilder<
    StaticCatalogMetaEntity, StaticCatalogMetaEntity, QFilterCondition> {}

extension StaticCatalogMetaEntityQuerySortBy
    on QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QSortBy> {
  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      sortByLastUpdatedMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedMs', Sort.asc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      sortByLastUpdatedMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedMs', Sort.desc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      sortByLocalesCsv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localesCsv', Sort.asc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      sortByLocalesCsvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localesCsv', Sort.desc);
    });
  }
}

extension StaticCatalogMetaEntityQuerySortThenBy on QueryBuilder<
    StaticCatalogMetaEntity, StaticCatalogMetaEntity, QSortThenBy> {
  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      thenByLastUpdatedMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedMs', Sort.asc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      thenByLastUpdatedMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedMs', Sort.desc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      thenByLocalesCsv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localesCsv', Sort.asc);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QAfterSortBy>
      thenByLocalesCsvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localesCsv', Sort.desc);
    });
  }
}

extension StaticCatalogMetaEntityQueryWhereDistinct on QueryBuilder<
    StaticCatalogMetaEntity, StaticCatalogMetaEntity, QDistinct> {
  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QDistinct>
      distinctByKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QDistinct>
      distinctByLastUpdatedMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdatedMs');
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, StaticCatalogMetaEntity, QDistinct>
      distinctByLocalesCsv({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localesCsv', caseSensitive: caseSensitive);
    });
  }
}

extension StaticCatalogMetaEntityQueryProperty on QueryBuilder<
    StaticCatalogMetaEntity, StaticCatalogMetaEntity, QQueryProperty> {
  QueryBuilder<StaticCatalogMetaEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, String, QQueryOperations>
      keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, int, QQueryOperations>
      lastUpdatedMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdatedMs');
    });
  }

  QueryBuilder<StaticCatalogMetaEntity, String, QQueryOperations>
      localesCsvProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localesCsv');
    });
  }
}
