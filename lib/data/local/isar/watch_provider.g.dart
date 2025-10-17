// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_provider.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWatchProviderEntityCollection on Isar {
  IsarCollection<WatchProviderEntity> get watchProviderEntitys =>
      this.collection();
}

const WatchProviderEntitySchema = CollectionSchema(
  name: r'WatchProviderEntity',
  id: 7888000997629210359,
  properties: {
    r'displayPriority': PropertySchema(
      id: 0,
      name: r'displayPriority',
      type: IsarType.long,
    ),
    r'providerId': PropertySchema(
      id: 1,
      name: r'providerId',
      type: IsarType.long,
    )
  },
  estimateSize: _watchProviderEntityEstimateSize,
  serialize: _watchProviderEntitySerialize,
  deserialize: _watchProviderEntityDeserialize,
  deserializeProp: _watchProviderEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'providerId': IndexSchema(
      id: -1675978104265523206,
      name: r'providerId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'providerId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _watchProviderEntityGetId,
  getLinks: _watchProviderEntityGetLinks,
  attach: _watchProviderEntityAttach,
  version: '3.1.0+1',
);

int _watchProviderEntityEstimateSize(
  WatchProviderEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _watchProviderEntitySerialize(
  WatchProviderEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.displayPriority);
  writer.writeLong(offsets[1], object.providerId);
}

WatchProviderEntity _watchProviderEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WatchProviderEntity();
  object.displayPriority = reader.readLongOrNull(offsets[0]);
  object.id = id;
  object.providerId = reader.readLong(offsets[1]);
  return object;
}

P _watchProviderEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _watchProviderEntityGetId(WatchProviderEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _watchProviderEntityGetLinks(
    WatchProviderEntity object) {
  return [];
}

void _watchProviderEntityAttach(
    IsarCollection<dynamic> col, Id id, WatchProviderEntity object) {
  object.id = id;
}

extension WatchProviderEntityByIndex on IsarCollection<WatchProviderEntity> {
  Future<WatchProviderEntity?> getByProviderId(int providerId) {
    return getByIndex(r'providerId', [providerId]);
  }

  WatchProviderEntity? getByProviderIdSync(int providerId) {
    return getByIndexSync(r'providerId', [providerId]);
  }

  Future<bool> deleteByProviderId(int providerId) {
    return deleteByIndex(r'providerId', [providerId]);
  }

  bool deleteByProviderIdSync(int providerId) {
    return deleteByIndexSync(r'providerId', [providerId]);
  }

  Future<List<WatchProviderEntity?>> getAllByProviderId(
      List<int> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'providerId', values);
  }

  List<WatchProviderEntity?> getAllByProviderIdSync(
      List<int> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'providerId', values);
  }

  Future<int> deleteAllByProviderId(List<int> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'providerId', values);
  }

  int deleteAllByProviderIdSync(List<int> providerIdValues) {
    final values = providerIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'providerId', values);
  }

  Future<Id> putByProviderId(WatchProviderEntity object) {
    return putByIndex(r'providerId', object);
  }

  Id putByProviderIdSync(WatchProviderEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'providerId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProviderId(List<WatchProviderEntity> objects) {
    return putAllByIndex(r'providerId', objects);
  }

  List<Id> putAllByProviderIdSync(List<WatchProviderEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'providerId', objects, saveLinks: saveLinks);
  }
}

extension WatchProviderEntityQueryWhereSort
    on QueryBuilder<WatchProviderEntity, WatchProviderEntity, QWhere> {
  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhere>
      anyProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'providerId'),
      );
    });
  }
}

extension WatchProviderEntityQueryWhere
    on QueryBuilder<WatchProviderEntity, WatchProviderEntity, QWhereClause> {
  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhereClause>
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

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhereClause>
      providerIdEqualTo(int providerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'providerId',
        value: [providerId],
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhereClause>
      providerIdNotEqualTo(int providerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhereClause>
      providerIdGreaterThan(
    int providerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerId',
        lower: [providerId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhereClause>
      providerIdLessThan(
    int providerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerId',
        lower: [],
        upper: [providerId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterWhereClause>
      providerIdBetween(
    int lowerProviderId,
    int upperProviderId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerId',
        lower: [lowerProviderId],
        includeLower: includeLower,
        upper: [upperProviderId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WatchProviderEntityQueryFilter on QueryBuilder<WatchProviderEntity,
    WatchProviderEntity, QFilterCondition> {
  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      displayPriorityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'displayPriority',
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      displayPriorityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'displayPriority',
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      displayPriorityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayPriority',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      displayPriorityGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayPriority',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      displayPriorityLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayPriority',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      displayPriorityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayPriority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      providerIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      providerIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerId',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      providerIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerId',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterFilterCondition>
      providerIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WatchProviderEntityQueryObject on QueryBuilder<WatchProviderEntity,
    WatchProviderEntity, QFilterCondition> {}

extension WatchProviderEntityQueryLinks on QueryBuilder<WatchProviderEntity,
    WatchProviderEntity, QFilterCondition> {}

extension WatchProviderEntityQuerySortBy
    on QueryBuilder<WatchProviderEntity, WatchProviderEntity, QSortBy> {
  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterSortBy>
      sortByDisplayPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayPriority', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterSortBy>
      sortByDisplayPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayPriority', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterSortBy>
      sortByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterSortBy>
      sortByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }
}

extension WatchProviderEntityQuerySortThenBy
    on QueryBuilder<WatchProviderEntity, WatchProviderEntity, QSortThenBy> {
  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterSortBy>
      thenByDisplayPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayPriority', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterSortBy>
      thenByDisplayPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayPriority', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterSortBy>
      thenByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QAfterSortBy>
      thenByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }
}

extension WatchProviderEntityQueryWhereDistinct
    on QueryBuilder<WatchProviderEntity, WatchProviderEntity, QDistinct> {
  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QDistinct>
      distinctByDisplayPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayPriority');
    });
  }

  QueryBuilder<WatchProviderEntity, WatchProviderEntity, QDistinct>
      distinctByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerId');
    });
  }
}

extension WatchProviderEntityQueryProperty
    on QueryBuilder<WatchProviderEntity, WatchProviderEntity, QQueryProperty> {
  QueryBuilder<WatchProviderEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WatchProviderEntity, int?, QQueryOperations>
      displayPriorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayPriority');
    });
  }

  QueryBuilder<WatchProviderEntity, int, QQueryOperations>
      providerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWatchProviderTranslationEntityCollection on Isar {
  IsarCollection<WatchProviderTranslationEntity>
      get watchProviderTranslationEntitys => this.collection();
}

const WatchProviderTranslationEntitySchema = CollectionSchema(
  name: r'WatchProviderTranslationEntity',
  id: 2862989751487615727,
  properties: {
    r'locale': PropertySchema(
      id: 0,
      name: r'locale',
      type: IsarType.string,
    ),
    r'providerId': PropertySchema(
      id: 1,
      name: r'providerId',
      type: IsarType.long,
    ),
    r'providerName': PropertySchema(
      id: 2,
      name: r'providerName',
      type: IsarType.string,
    )
  },
  estimateSize: _watchProviderTranslationEntityEstimateSize,
  serialize: _watchProviderTranslationEntitySerialize,
  deserialize: _watchProviderTranslationEntityDeserialize,
  deserializeProp: _watchProviderTranslationEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'providerId': IndexSchema(
      id: -1675978104265523206,
      name: r'providerId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'providerId',
          type: IndexType.value,
          caseSensitive: false,
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
  getId: _watchProviderTranslationEntityGetId,
  getLinks: _watchProviderTranslationEntityGetLinks,
  attach: _watchProviderTranslationEntityAttach,
  version: '3.1.0+1',
);

int _watchProviderTranslationEntityEstimateSize(
  WatchProviderTranslationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.locale.length * 3;
  bytesCount += 3 + object.providerName.length * 3;
  return bytesCount;
}

void _watchProviderTranslationEntitySerialize(
  WatchProviderTranslationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.locale);
  writer.writeLong(offsets[1], object.providerId);
  writer.writeString(offsets[2], object.providerName);
}

WatchProviderTranslationEntity _watchProviderTranslationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WatchProviderTranslationEntity();
  object.id = id;
  object.locale = reader.readString(offsets[0]);
  object.providerId = reader.readLong(offsets[1]);
  object.providerName = reader.readString(offsets[2]);
  return object;
}

P _watchProviderTranslationEntityDeserializeProp<P>(
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

Id _watchProviderTranslationEntityGetId(WatchProviderTranslationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _watchProviderTranslationEntityGetLinks(
    WatchProviderTranslationEntity object) {
  return [];
}

void _watchProviderTranslationEntityAttach(
    IsarCollection<dynamic> col, Id id, WatchProviderTranslationEntity object) {
  object.id = id;
}

extension WatchProviderTranslationEntityQueryWhereSort on QueryBuilder<
    WatchProviderTranslationEntity, WatchProviderTranslationEntity, QWhere> {
  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhere> anyProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'providerId'),
      );
    });
  }
}

extension WatchProviderTranslationEntityQueryWhere on QueryBuilder<
    WatchProviderTranslationEntity,
    WatchProviderTranslationEntity,
    QWhereClause> {
  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhereClause> providerIdEqualTo(int providerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'providerId',
        value: [providerId],
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhereClause> providerIdNotEqualTo(int providerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [providerId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerId',
              lower: [],
              upper: [providerId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhereClause> providerIdGreaterThan(
    int providerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerId',
        lower: [providerId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhereClause> providerIdLessThan(
    int providerId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerId',
        lower: [],
        upper: [providerId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhereClause> providerIdBetween(
    int lowerProviderId,
    int upperProviderId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'providerId',
        lower: [lowerProviderId],
        includeLower: includeLower,
        upper: [upperProviderId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterWhereClause> localeEqualTo(String locale) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'locale',
        value: [locale],
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

extension WatchProviderTranslationEntityQueryFilter on QueryBuilder<
    WatchProviderTranslationEntity,
    WatchProviderTranslationEntity,
    QFilterCondition> {
  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
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

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> localeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> localeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerId',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerId',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerId',
        value: value,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
          QAfterFilterCondition>
      providerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
          QAfterFilterCondition>
      providerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerName',
        value: '',
      ));
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterFilterCondition> providerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerName',
        value: '',
      ));
    });
  }
}

extension WatchProviderTranslationEntityQueryObject on QueryBuilder<
    WatchProviderTranslationEntity,
    WatchProviderTranslationEntity,
    QFilterCondition> {}

extension WatchProviderTranslationEntityQueryLinks on QueryBuilder<
    WatchProviderTranslationEntity,
    WatchProviderTranslationEntity,
    QFilterCondition> {}

extension WatchProviderTranslationEntityQuerySortBy on QueryBuilder<
    WatchProviderTranslationEntity, WatchProviderTranslationEntity, QSortBy> {
  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> sortByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> sortByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> sortByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> sortByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> sortByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> sortByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }
}

extension WatchProviderTranslationEntityQuerySortThenBy on QueryBuilder<
    WatchProviderTranslationEntity,
    WatchProviderTranslationEntity,
    QSortThenBy> {
  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> thenByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> thenByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> thenByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> thenByProviderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerId', Sort.desc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> thenByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QAfterSortBy> thenByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }
}

extension WatchProviderTranslationEntityQueryWhereDistinct on QueryBuilder<
    WatchProviderTranslationEntity, WatchProviderTranslationEntity, QDistinct> {
  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QDistinct> distinctByLocale({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QDistinct> distinctByProviderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerId');
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, WatchProviderTranslationEntity,
      QDistinct> distinctByProviderName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerName', caseSensitive: caseSensitive);
    });
  }
}

extension WatchProviderTranslationEntityQueryProperty on QueryBuilder<
    WatchProviderTranslationEntity,
    WatchProviderTranslationEntity,
    QQueryProperty> {
  QueryBuilder<WatchProviderTranslationEntity, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, String, QQueryOperations>
      localeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locale');
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, int, QQueryOperations>
      providerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerId');
    });
  }

  QueryBuilder<WatchProviderTranslationEntity, String, QQueryOperations>
      providerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerName');
    });
  }
}
