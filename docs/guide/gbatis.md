# GBatis ORM Framework

GBatis is GDSQL's built-in ORM framework, inspired by [MyBatis 3](https://mybatis.org/mybatis-3/). It separates SQL statements from GDScript code by defining them in XML mapping files — ideal for complex queries and team collaboration.

## Overview

GBatis supports two working modes:

1. **Manual authoring** — Write XML and entity code by hand for full control
2. **Visual generation** — Use the Mapper Graph editor to generate initial code, then refine manually

Both approaches can be combined freely.

## XML Mapping File Structure

```xml
<mapper namespace="HeroMapper">
    <!-- Result Map: defines how query results map to object properties -->
    <resultMap id="heroResult" type="HeroEntity">
        <id property="id" column="id"/>
        <result property="name" column="name"/>
        <result property="hp" column="hp"/>
        <result property="mp" column="mp"/>
    </resultMap>

    <!-- SELECT statement -->
    <select id="selectHeroesByHp" resultMap="heroResult">
        SELECT * FROM c_hero WHERE hp > #{minHp} ORDER BY hp DESC
    </select>

    <!-- INSERT statement -->
    <insert id="insertHero">
        INSERT INTO c_hero (id, name, hp, mp) VALUES (#{id}, #{name}, #{hp}, #{mp})
    </insert>

    <!-- UPDATE statement -->
    <update id="updateHeroHp">
        UPDATE c_hero SET hp = #{hp} WHERE id = #{id}
    </update>

    <!-- DELETE statement -->
    <delete id="deleteHero">
        DELETE FROM c_hero WHERE id = #{id}
    </delete>
</mapper>
```

## Dynamic SQL

GBatis supports dynamic SQL elements, similar to MyBatis:

### `<if>` — Conditional Inclusion

```xml
<select id="searchHeroes" resultType="HeroEntity">
    SELECT * FROM c_hero
    <where>
        <if test="name != null">AND name = #{name}</if>
        <if test="minHp != null">AND hp >= #{minHp}</if>
    </where>
</select>
```

### `<where>` — Smart WHERE Clause

Automatically adds `WHERE` and removes leading `AND`/`OR`.

### `<set>` — Smart SET Clause

For UPDATE statements. Automatically adds `SET` and removes trailing commas.

```xml
<update id="updateHero">
    UPDATE c_hero
    <set>
        <if test="name != null">name = #{name},</if>
        <if test="hp != null">hp = #{hp},</if>
    </set>
    WHERE id = #{id}
</update>
```

### `<foreach>` — Iteration

```xml
<select id="selectByIds" resultType="HeroEntity">
    SELECT * FROM c_hero WHERE id IN
    <foreach item="id" collection="ids" open="(" separator="," close=")">
        #{id}
    </foreach>
</select>
```

### `<trim>` — Custom Trimming

```xml
<trim prefix="WHERE" prefixOverrides="AND |OR ">
    ...
</trim>
```

### `<bind>` — Variable Binding

```xml
<bind name="pattern" value="'%' + name + '%'" />
SELECT * FROM c_hero WHERE name LIKE #{pattern}
```

## Result Mapping

### `<resultMap>`

Define complex object mappings:

```xml
<resultMap id="heroWithSkills" type="HeroEntity">
    <id property="id" column="hero_id"/>
    <result property="name" column="hero_name"/>
    <collection property="skills" ofType="SkillEntity">
        <id property="id" column="skill_id"/>
        <result property="name" column="skill_name"/>
    </collection>
</resultMap>
```

### `<association>` — One-to-One

```xml
<resultMap id="heroWithGuild" type="HeroEntity">
    <id property="id" column="hero_id"/>
    <association property="guild" javaType="GuildEntity">
        <id property="id" column="guild_id"/>
        <result property="name" column="guild_name"/>
    </association>
</resultMap>
```

### `<collection>` — One-to-Many

```xml
<collection property="items" ofType="ItemEntity">
    <id property="id" column="item_id"/>
    <result property="name" column="item_name"/>
</collection>
```

### `<discriminator>` — Polymorphic Mapping

```xml
<discriminator column="type">
    <case value="warrior" resultType="WarriorEntity"/>
    <case value="mage" resultType="MageEntity"/>
</discriminator>
```

## Using GBatisMapper

Create a class that extends `GBatisMapper`:

```gdscript
class_name HeroMapper extends GBatisMapper

var mapper_xml = "res://mappers/HeroMapper.xml"

func selectHeroesByHp(minHp: int) -> Array[HeroEntity]:
    pass  # Implemented by GBatis

func insertHero(hero: HeroEntity) -> void:
    pass  # Implemented by GBatis
```

GBatis reads the XML file and auto-implements the methods based on the `id` attribute of each SQL element.

## Caching

### L1 Cache (Session-level)
Enabled by default. Caches results within a single query session.

### L2 Cache (Mapper-level)
Configurable per statement with `useCache` and `flushCache` attributes.

```xml
<select id="selectAll" useCache="true" resultType="HeroEntity">
    SELECT * FROM c_hero
</select>
```

## Auto-Mapping Levels

- `NONE` — Only explicitly mapped columns are set
- `PARTIAL` — Unmapped columns are auto-mapped to matching property names

## useGeneratedKeys

Automatically populate auto-increment primary keys after insert:

```xml
<insert id="insertHero" useGeneratedKeys="true" keyProperty="id">
    INSERT INTO c_hero (name, hp) VALUES (#{name}, #{hp})
</insert>
```

## Fluent DAO vs GBatis

| Scenario | Recommended | Why |
|----------|-------------|-----|
| Simple CRUD | Fluent DAO | Concise, no extra files |
| Complex queries / joins | GBatis | SQL-code separation, powerful mapping |
| Team collaboration | GBatis | DBA handles XML, devs call methods |
| Rapid prototyping | Fluent DAO | Zero config, write and use |
