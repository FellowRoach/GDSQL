# 链式 DAO API

链式 DAO API 通过 GDScript 方法链构建数据库查询——不需要 SQL 字符串，不需要 XML 文件。每个方法都返回 DAO 对象本身，实现简洁、可读的链式调用。

## 基本用法

```gdscript
var result = GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .select("id, name, hp") \
    .from("c_hero") \
    .where("hp > 100") \
    .order_by("hp DESC") \
    .limit(10) \
    .query()
```

## 数据库选择

### `use_db(database_name_or_path: String)`
按名称或路径选择数据库。系统自动判断传入的是名称还是路径（含 `/` 的为路径）。

### `use_db_name(database_name: String)`
按名称选择数据库。

### `use_user_db()`
使用 `user://` 目录作为数据库。

### `use_conf_db()`
使用项目设置中配置的数据库。

## SELECT 查询

### `select(fields: String, reset: bool = true)`
指定查询列。传 `"*"` 查所有列。

```gdscript
.select("id, name, hp")
.select("*")
.select("COUNT(*) as total")
```

### `from(table: String, alias: String = "")`
指定数据来源表。

### `where(condition: String)`
设置筛选条件。

```gdscript
.where("hp > 100 AND mp >= 50")
.where("name LIKE '战%'")
.where("id IN (1, 2, 3)")
```

### `order_by(field: String, ascending: bool = true)`
按字段排序。

### `limit(offset: int, count: int)`
分页。

### `group_by(fields: String)`
分组。

### `left_join(db, table, alias, on, extra)`
左连接。

```gdscript
GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .select("h.name, s.skill_name") \
    .from("c_hero", "h") \
    .left_join("", "c_skill", "s", "h.id = s.hero_id") \
    .query()
```

### `union_all()`
与另一个 SELECT 合并结果。

## INSERT 操作

```gdscript
GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .insert_into("c_hero") \
    .values({"id": 101, "name": "新英雄", "hp": 200}) \
    .query()
```

- `insert_into(table)` — 插入
- `insert_ignore(table)` — 主键存在则跳过
- `insert_or_update(table)` — 主键存在则更新（upsert）

## UPDATE 操作

```gdscript
GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .update("c_hero") \
    .sets({"hp": 300, "mp": 150}) \
    .where("id = 101") \
    .query()
```

## DELETE 操作

```gdscript
GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .delete_from("c_hero") \
    .where("id = 101") \
    .query()
```

## 执行查询

### `query()`
执行查询并返回 `QueryResult` 对象。

```gdscript
var result = dao.query()
if result.ok():
    var data = result.get_data()   # 数据行数组
    var head = result.get_head()   # 列名
else:
    print(result.get_err())        # 错误信息
```

## 事务控制

### `auto_commit(auto: bool)`
控制是否自动保存到磁盘。

### `commit()`
手动保存更改到磁盘。

### `discard()`
丢弃未提交的内存更改。

## 密码

### `set_password(password: String)`
设置访问加密表的密码。

详见 [API 参考](../api/base-dao) 获取完整方法列表。
