# GBatis ORM 框架

GBatis 是 GDSQL 内置的 ORM 框架，灵感来自 [MyBatis 3](https://mybatis.org/mybatis-3/)。它将 SQL 语句定义在 XML 映射文件中，与 GDScript 代码完全分离——适合复杂查询和团队协作。

## 概述

GBatis 支持两种工作模式：

1. **手动编写** — 手动编写 XML 和实体代码，完全控制细节
2. **可视化生成** — 使用映射图编辑器生成初始代码，然后手动微调

两种方式可以灵活组合。

## XML 映射文件结构

```xml
<mapper namespace="HeroMapper">
    <resultMap id="heroResult" type="HeroEntity">
        <id property="id" column="id"/>
        <result property="name" column="name"/>
        <result property="hp" column="hp"/>
    </resultMap>

    <select id="selectHeroesByHp" resultMap="heroResult">
        SELECT * FROM c_hero WHERE hp > #{minHp} ORDER BY hp DESC
    </select>

    <insert id="insertHero">
        INSERT INTO c_hero (id, name, hp) VALUES (#{id}, #{name}, #{hp})
    </insert>
</mapper>
```

## 动态 SQL

### `<if>` — 条件包含

```xml
<select id="searchHeroes" resultType="HeroEntity">
    SELECT * FROM c_hero
    <where>
        <if test="name != null">AND name = #{name}</if>
        <if test="minHp != null">AND hp >= #{minHp}</if>
    </where>
</select>
```

### `<where>` — 智能 WHERE

自动添加 `WHERE` 并去除开头的 `AND`/`OR`。

### `<set>` — 智能 SET

用于 UPDATE 语句，自动添加 `SET` 并去除末尾逗号。

### `<foreach>` — 迭代

```xml
SELECT * FROM c_hero WHERE id IN
<foreach item="id" collection="ids" open="(" separator="," close=")">
    #{id}
</foreach>
```

### `<trim>` / `<bind>`

自定义修剪和变量绑定。

## 结果映射

### `<resultMap>` — 对象映射

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

### `<association>` — 一对一
### `<collection>` — 一对多
### `<discriminator>` — 多态映射

## 使用 GBatisMapper

创建继承 `GBatisMapper` 的类：

```gdscript
class_name HeroMapper extends GBatisMapper

var mapper_xml = "res://mappers/HeroMapper.xml"

func selectHeroesByHp(minHp: int) -> Array[HeroEntity]:
    pass  # 由 GBatis 自动实现

func insertHero(hero: HeroEntity) -> void:
    pass
```

## 缓存

### L1 缓存（会话级）
默认开启，缓存单次查询会话内的结果。

### L2 缓存（映射器级）
通过 `useCache` 和 `flushCache` 属性配置。

## 链式 DAO vs GBatis

| 场景 | 推荐方式 | 原因 |
|------|---------|------|
| 简单 CRUD | 链式 DAO | 简洁，无需额外文件 |
| 复杂查询 / 多表关联 | GBatis | SQL 与代码分离，结果映射强大 |
| 团队协作 | GBatis | DBA 维护 XML，程序只管调用 |
| 快速原型 | 链式 DAO | 零配置，即写即用 |
