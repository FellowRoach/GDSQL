# SQL 查询引擎

GDSQL 内置了一个纯 GDScript 实现的完整 SQL 查询引擎。它解析标准 SQL 语法并在基于 ConfigFile 的数据存储上执行。

## 支持的 SQL 语句

### SELECT

```sql
SELECT column1, column2 FROM table_name
SELECT * FROM table_name WHERE condition
SELECT column1, COUNT(*) FROM table_name GROUP BY column1 HAVING COUNT(*) > 1
SELECT a.*, b.name FROM table_a a LEFT JOIN table_b b ON a.id = b.a_id
SELECT * FROM table_name ORDER BY column1 DESC LIMIT 10 OFFSET 5
SELECT * FROM table_a UNION ALL SELECT * FROM table_b
```

**支持的子句：**
- `SELECT` — 列列表、`*`、表达式、聚合函数
- `FROM` — 表名，可选别名
- `WHERE` — 条件：AND、OR、IN、NOT IN、BETWEEN、LIKE、IS NULL
- `ORDER BY` — 升序/降序，多列排序
- `GROUP BY` — 含 `HAVING` 子句
- `LIMIT` / `OFFSET` — 分页
- `LEFT JOIN` — ON 条件，链式多表连接
- `UNION ALL` — 合并结果集
- **子查询** — 相关子查询和非相关子查询

### INSERT

```sql
INSERT INTO table_name VALUES (value1, value2, value3)
INSERT INTO table_name (col1, col2) VALUES (value1, value2)
INSERT IGNORE INTO table_name VALUES (value1, value2)
INSERT INTO table_name VALUES (value1) ON DUPLICATE KEY UPDATE col1 = VALUES(col1)
```

### UPDATE

```sql
UPDATE table_name SET col1 = value1, col2 = value2
UPDATE table_name SET col1 = value1 WHERE condition
```

### DELETE

```sql
DELETE FROM table_name
DELETE FROM table_name WHERE condition
```

### REPLACE

```sql
REPLACE INTO table_name VALUES (value1, value2)
REPLACE INTO table_name (col1, col2) VALUES (value1, value2)
```

## 条件表达式

WHERE 子句支持：

| 运算符 | 示例 |
|--------|------|
| 比较 | `hp > 100`、`name = '英雄'` |
| AND / OR | `hp > 100 AND mp < 200` |
| IN / NOT IN | `id IN (1, 2, 3)` |
| BETWEEN | `hp BETWEEN 100 AND 200` |
| LIKE | `name LIKE '战%'` |
| IS NULL / IS NOT NULL | `mp IS NULL` |

## 聚合函数

| 函数 | 说明 |
|------|------|
| `COUNT(*)` | 计数行 |
| `SUM(column)` | 求和 |
| `AVG(column)` | 平均值 |
| `MIN(column)` | 最小值 |
| `MAX(column)` | 最大值 |
| `GROUP_CONCAT(column)` | 拼接值 |

## LRU 缓存

SQL 解析器内置 LRU 缓存，自动缓存最近解析的 1024 条 SQL 语句。重复查询的解析速度更快。

## 在代码中使用 SQL

可以通过 `SQLParser` 直接执行 SQL 字符串：

```gdscript
var dao = GDSQL.SQLParser.parse_to_dao("SELECT * FROM c_hero WHERE hp > 100")
var result = dao.query()
```

或使用 [链式 DAO API](./dao-api) 以更结构化的方式构建查询。
