# SQLParser API 参考

`GDSQL.SQLParser` 将 SQL 字符串解析为可执行的 `BaseDao` 对象，内置 LRU 缓存提升性能。

**类**: `RefCounted`  
**命名空间**: `GDSQL.SQLParser`  
**源码**: `addons/gdsql/database/sql_parser.gd`

## 核心方法

### `parse_to_dao(sql: String) -> BaseDao`
解析 SQL 字符串，返回配置好的 `BaseDao` 对象。

```gdscript
var dao = GDSQL.SQLParser.parse_to_dao("SELECT * FROM c_hero WHERE hp > 100")
if dao:
    var result = dao.query()
```

### `parse_select(sql: String) -> Array`
解析 SELECT 语句为组件数组。

### `parse_update / parse_delete / parse_insert / parse_replace`
分别解析对应的 SQL 语句。

## LRU 缓存

自动缓存最近 **1024** 条解析过的 SQL 语句，无需配置。

## 支持的 SQL

| 语句 | 支持 |
|------|------|
| SELECT | 完整支持 — WHERE、JOIN、GROUP BY、ORDER BY、LIMIT、UNION ALL、子查询 |
| INSERT | 完整支持 — INSERT IGNORE、ON DUPLICATE KEY UPDATE |
| UPDATE / DELETE | 完整支持 |
| REPLACE | 完整支持 |
| CREATE/ALTER/DROP | 不支持 — 请使用可视化编辑器 |
