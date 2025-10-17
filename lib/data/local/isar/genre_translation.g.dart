// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre_translation.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGenreTranslationEntityCollection on Isar {
  IsarCollection<GenreTranslationEntity> get genreTranslationEntitys =>
      this.collection();
}

const GenreTranslationEntitySchema = CollectionSchema(
  name: r'GenreTranslationEntity',
  id: -2744077845624491195,
  properties: {
    r'genreId': PropertySchema(
      id: 0,
      name: r'genreId',
      type: IsarType.long,
    ),
    r'locale': PropertySchema(
      id: 1,
      name: r'locale',
      type: IsarType.string,
    ),
    r'mediaType': PropertySchema(
      id: 2,
      name: r'mediaType',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _genreTranslationEntityEstimateSize,
  serialize: _genreTranslationEntitySerialize,
  deserialize: _genreTranslationEntityDeserialize,
  deserializeProp: _genreTranslationEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'genreId': IndexSchema(
      id: 3212228459756463684,
      name: r'genreId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'genreId',
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
  getId: _genreTranslationEntityGetId,
  getLinks: _genreTranslationEntityGetLinks,
  attach: _genreTranslationEntityAttach,
  version: '3.1.0+1',
);

int _genreTranslationEntityEstimateSize(
  GenreTranslationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.locale.length * 3;
  bytesCount += 3 + object.mediaType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _genreTranslationEntitySerialize(
  GenreTranslationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.genreId);
  writer.writeString(offsets[1], object.locale);
  writer.writeString(offsets[2], object.mediaType);
  writer.writeString(offsets[3], object.name);
}

GenreTranslationEntity _genreTranslationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GenreTranslationEntity();
  object.genreId = reader.readLong(offsets[0]);
  object.id = id;
  object.locale = reader.readString(offsets[1]);
  object.mediaType = reader.readString(offsets[2]);
  object.name = reader.readString(offsets[3]);
  return object;
}

P _genreTranslationEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _genreTranslationEntityGetId(GenreTranslationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _genreTranslationEntityGetLinks(
    GenreTranslationEntity object) {
  return [];
}

void _genreTranslationEntityAttach(
    IsarCollection<dynamic> col, Id id, GenreTranslationEntity object) {
  object.id = id;
}

extension GenreTranslationEntityQueryWhereSort
    on QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QWhere> {
  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterWhere>
      anyGenreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'genreId'),
      );
    });
  }
}

extension GenreTranslationEntityQueryWhere on QueryBuilder<
    GenreTranslationEntity, GenreTranslationEntity, QWhereClause> {
  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterWhereClause> genreIdEqualTo(int genreId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'genreId',
        value: [genreId],
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterWhereClause> genreIdNotEqualTo(int genreId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'genreId',
              lower: [],
              upper: [genreId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'genreId',
              lower: [genreId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'genreId',
              lower: [genreId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'genreId',
              lower: [],
              upper: [genreId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterWhereClause> genreIdGreaterThan(
    int genreId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'genreId',
        lower: [genreId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterWhereClause> genreIdLessThan(
    int genreId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'genreId',
        lower: [],
        upper: [genreId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterWhereClause> genreIdBetween(
    int lowerGenreId,
    int upperGenreId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'genreId',
        lower: [lowerGenreId],
        includeLower: includeLower,
        upper: [upperGenreId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterWhereClause> localeEqualTo(String locale) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'locale',
        value: [locale],
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

extension GenreTranslationEntityQueryFilter on QueryBuilder<
    GenreTranslationEntity, GenreTranslationEntity, QFilterCondition> {
  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> genreIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genreId',
        value: value,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> genreIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genreId',
        value: value,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> genreIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genreId',
        value: value,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> genreIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genreId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> localeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> localeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> mediaTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> mediaTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> mediaTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> mediaTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> mediaTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> mediaTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
          QAfterFilterCondition>
      mediaTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
          QAfterFilterCondition>
      mediaTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> mediaTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaType',
        value: '',
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> mediaTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaType',
        value: '',
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
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

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension GenreTranslationEntityQueryObject on QueryBuilder<
    GenreTranslationEntity, GenreTranslationEntity, QFilterCondition> {}

extension GenreTranslationEntityQueryLinks on QueryBuilder<
    GenreTranslationEntity, GenreTranslationEntity, QFilterCondition> {}

extension GenreTranslationEntityQuerySortBy
    on QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QSortBy> {
  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      sortByGenreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genreId', Sort.asc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      sortByGenreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genreId', Sort.desc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      sortByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      sortByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      sortByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      sortByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension GenreTranslationEntityQuerySortThenBy on QueryBuilder<
    GenreTranslationEntity, GenreTranslationEntity, QSortThenBy> {
  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      thenByGenreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genreId', Sort.asc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      thenByGenreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genreId', Sort.desc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      thenByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      thenByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      thenByMediaType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.asc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      thenByMediaTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaType', Sort.desc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension GenreTranslationEntityQueryWhereDistinct
    on QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QDistinct> {
  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QDistinct>
      distinctByGenreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genreId');
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QDistinct>
      distinctByLocale({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QDistinct>
      distinctByMediaType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GenreTranslationEntity, GenreTranslationEntity, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension GenreTranslationEntityQueryProperty on QueryBuilder<
    GenreTranslationEntity, GenreTranslationEntity, QQueryProperty> {
  QueryBuilder<GenreTranslationEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GenreTranslationEntity, int, QQueryOperations>
      genreIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genreId');
    });
  }

  QueryBuilder<GenreTranslationEntity, String, QQueryOperations>
      localeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locale');
    });
  }

  QueryBuilder<GenreTranslationEntity, String, QQueryOperations>
      mediaTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaType');
    });
  }

  QueryBuilder<GenreTranslationEntity, String, QQueryOperations>
      nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
