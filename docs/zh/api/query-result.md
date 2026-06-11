# QueryResult API 参考

`QueryResult` 封装查询执行结果，提供数据访问、列头信息和状态检查方法。

**类**: `RefCounted`  
**命名空间**: `GDSQL.QueryResult`  
**源码**: `addons/gdsql/database/query_result.gd`

## 状态

### `ok() -> bool`
查询成功返回 `true`。

### `get_err() -> String`
查询失败时返回错误信息。

## 数据访问

### `get_data() -> Array`
返回结果行数组。每个内部数组代表一行。

```gdscript
var rows = result.get_data()
for row in rows:
    print(row[0], row[1])  # 按列索引访问
```

### `get_head() -> Array`
返回列名数组，顺序与 SELECT 子句匹配。

## 数据属性

### `is_empty() -> bool`
结果为空返回 `true`。

### `size() -> int`
返回结果行数。

## 使用示例

```gdscript
var result = GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .select("id, name, hp").from("c_hero") \
    .where("hp > 100").query()

if result and result.ok():
    var head = result.get_head()   # ["id", "name", "hp"]
    var data = result.get_data()   # [[1, "战士", 200], ...]
else:
    print("查询失败")
```
