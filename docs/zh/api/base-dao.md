# BaseDao API 参考

`GDSQL.BaseDao` 是通过链式 API 构建和执行数据库查询的核心类。

**类**: `RefCounted`  
**命名空间**: `GDSQL.BaseDao`  
**源码**: `addons/gdsql/database/base_dao.gd`

## 创建实例

```gdscript
var dao = GDSQL.BaseDao.new()
```

## 数据库选择

### `use_db(database_name_or_path: String) -> BaseDao`
按名称或路径选择数据库。含 `/` 的自动识别为路径。

### `use_db_name(database_name: String) -> BaseDao`
按名称选择数据库。

### `use_user_db() -> BaseDao`
使用 `user://` 目录。

### `use_conf_db() -> BaseDao`
使用项目设置中配置的数据库。

### `get_db() -> String`
获取当前数据库名称。

## 认证

### `set_password(password: String) -> BaseDao`
设置加密表访问密码。

## 事务控制

### `auto_commit(auto: bool) -> BaseDao`
启用/禁用自动提交。禁用时更改仅保留在内存中。

### `commit() -> void`
手动保存更改到磁盘。

### `discard() -> void`
丢弃未提交的内存更改。

## SELECT 操作

### `select(fields: String, reset: bool = true) -> BaseDao`
设置查询列。`"*"` 查所有列。

### `from(table: String, alias: String = "") -> BaseDao`
设置源表。

### `where(condition: String) -> BaseDao`
设置 WHERE 条件。

### `order_by(field: String, ascending: bool = true) -> BaseDao`
添加 ORDER BY。

### `order_by_str(order_string: String) -> BaseDao`
从字符串设置 ORDER BY。

### `group_by(fields: String) -> BaseDao`
设置 GROUP BY。

### `limit(offset: int, count: int) -> BaseDao`
设置分页。

### `left_join(db, table, alias, on, extra) -> BaseDao`
添加 LEFT JOIN。

### `union_all() -> BaseDao`
开始 UNION ALL，返回新的 BaseDao 用于第二个查询。

## INSERT 操作

### `insert_into(table: String) -> BaseDao`
### `insert_ignore(table: String) -> BaseDao`
### `insert_or_update(table: String) -> BaseDao`
### `values(data) -> BaseDao` — 接受 Dictionary 或 Array
### `on_duplicate_update(fields: Array) -> BaseDao`

## UPDATE 操作

### `update(table: String) -> BaseDao`
### `sets(data: Dictionary) -> BaseDao`

## DELETE 操作

### `delete_from(table: String) -> BaseDao`

## REPLACE 操作

### `replace_into(table: String) -> BaseDao`

## 执行

### `query() -> QueryResult`
执行查询并返回 `QueryResult` 对象。

```gdscript
var result = dao.query()
if result and result.ok():
    var data = result.get_data()
    for row in data:
        print(row)
```
