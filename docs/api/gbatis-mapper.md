# GBatisMapper API Reference

`GBatisMapper` is the base class for creating ORM mapper classes that bridge GDScript code and XML mapping files.

**Class**: `RefCounted`  
**Namespace**: `GDSQL.GBatisMapper`  
**Source**: `addons/gdsql/gbatis/gbatis_mapper.gd`

## Overview

Extend `GBatisMapper` and define methods that match the `id` attributes in your XML mapping file. GBatis auto-implements these methods at runtime.

## Properties

### `mapper_xml: String`
Path to the XML mapping file. Must be set before calling any mapper methods.

```gdscript
class_name HeroMapper extends GBatisMapper

var mapper_xml = "res://mappers/HeroMapper.xml"
```

### `return_type_undefined_behavior: String`
Controls behavior when a mapper method's return type is not defined.

**Values:**
- `"ARRAY_WHEN_NECESSARY"` (default) — Returns a single object when result has one row, array otherwise
- `"ALWAYS_ARRAY"` — Always returns an array

## Creating a Mapper

```gdscript
class_name HeroMapper extends GBatisMapper

var mapper_xml = "res://mappers/HeroMapper.xml"

# Method name must match the <select id="..."> in XML
func select_all() -> Array[HeroEntity]:
    pass  # Auto-implemented by GBatis

func select_by_id(id: int) -> HeroEntity:
    pass

func insert_hero(hero: HeroEntity) -> void:
    pass

func update_hp(id: int, hp: int) -> void:
    pass

func delete_hero(id: int) -> void:
    pass
```

## XML Mapping File

```xml
<mapper namespace="HeroMapper">
    <resultMap id="heroResult" type="HeroEntity">
        <id property="id" column="id"/>
        <result property="name" column="name"/>
        <result property="hp" column="hp"/>
    </resultMap>

    <select id="select_all" resultMap="heroResult">
        SELECT * FROM c_hero
    </select>

    <select id="select_by_id" resultMap="heroResult">
        SELECT * FROM c_hero WHERE id = #{id}
    </select>

    <insert id="insert_hero">
        INSERT INTO c_hero (id, name, hp) VALUES (#{id}, #{name}, #{hp})
    </insert>
</mapper>
```

## Parameter Binding

### Named Parameters

Use `#{paramName}` in XML. The parameter name must match the method argument name.

```xml
<select id="search" resultType="HeroEntity">
    SELECT * FROM c_hero WHERE name = #{name} AND hp > #{minHp}
</select>
```

```gdscript
func search(name: String, minHp: int) -> Array[HeroEntity]:
    pass
```

## Return Types

| Method Return Type | Behavior |
|-------------------|----------|
| `Array[EntityType]` | Returns typed array of entities |
| `EntityType` | Returns single entity (error if multiple rows) |
| `Dictionary` | Returns raw row as dictionary |
| `QueryResult` | Returns raw query result |
| `void` | For INSERT/UPDATE/DELETE |

## Caching

Control caching per statement in XML:

```xml
<select id="select_all" useCache="true" resultMap="heroResult">
    SELECT * FROM c_hero
</select>

<insert id="insert_hero" flushCache="true">
    INSERT INTO c_hero VALUES (#{id}, #{name})
</insert>
```
