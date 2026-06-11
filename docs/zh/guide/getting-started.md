# 快速开始

本指南带你完成创建第一个数据库、定义数据表、插入数据和查询——包括可视化操作和代码两种方式。

## 第一步：打开工作台

点击 Godot 编辑器顶部的 **GDSQL** 按钮，打开数据库工作台。

## 第二步：创建数据库

在工作台中点击 **新建数据库** 按钮，输入数据库名称，例如 `game_config`。

## 第三步：创建数据表

选中数据库后，点击 **新建表**。定义一个名为 `c_hero` 的表，包含以下列：

| 列名 | 类型 | 说明 |
|------|------|------|
| `id` | int | 主键 |
| `name` | String | 英雄名称 |
| `hp` | int | 气血值 |
| `mp` | int | 魔法值 |

## 第四步：添加数据

切换到 **数据** 标签页，点击 **添加行**，填入示例数据：

| id | name | hp | mp |
|----|------|----|----|
| 1 | 战士 | 200 | 50 |
| 2 | 法师 | 80 | 300 |
| 3 | 弓箭手 | 150 | 100 |

## 第五步：SQL 查询

打开 **SQL 编辑器** 标签页，编写并执行：

```sql
SELECT name, hp FROM c_hero WHERE hp > 100 ORDER BY hp DESC
```

结果会显示在下方的结果面板中。

## 第六步：代码查询

在任意 GDScript 文件中使用链式 DAO API：

```gdscript
extends Node

func _ready():
    # 查询气血大于100的英雄
    var result = GDSQL.BaseDao.new() \
        .use_db("game_config") \
        .select("name, hp") \
        .from("c_hero") \
        .where("hp > 100") \
        .order_by("hp DESC") \
        .query()

    # result 是 QueryResult 对象
    var data = result.get_data()
    for row in data:
        print(row)
```

## 第七步：代码插入数据

```gdscript
GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .insert_into("c_hero") \
    .values({"id": 4, "name": "圣骑士", "hp": 180, "mp": 120}) \
    .query()
```

## 下一步

掌握基础后，继续探索：

- [链式 DAO API](./dao-api) — 链式查询完整 API 参考
- [GBatis ORM](./gbatis) — 基于 XML 映射的复杂查询
- [数据加密](./encryption) — 保护敏感游戏数据
