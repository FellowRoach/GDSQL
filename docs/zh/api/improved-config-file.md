# ImprovedConfigFile API 参考

`ImprovedConfigFile` 扩展 Godot 的 `ConfigFile`，增加索引和增强数据访问功能。

**类**: `ConfigFile`  
**命名空间**: `GDSQL.ImprovedConfigFile`  
**源码**: `addons/gdsql/database/improved_config_file.gd`

## 概述

`ImprovedConfigFile` 是 GDSQL 表的底层存储引擎，封装了 Godot 标准 `ConfigFile`，增加：
- 内存索引加速查找
- 增强的数据操作方法
- 表结构管理

## 核心方法

### `set_indexed_props(properties: Array)`
在指定属性（列）上创建内存索引，加速 WHERE 条件求值。

```gdscript
var config = GDSQL.ImprovedConfigFile.new()
config.load("res://data/my_db/c_hero.cfg")
config.set_indexed_props(["id"])
# 按 "id" 过滤的查询会更快
```

## 数据结构

每个表存储为 ConfigFile，其中：
- **节（Section）** 是行索引（`"0"`, `"1"`, `"2"`, ...）
- **键（Key）** 是列名
- **值（Value）** 是单元格数据

```ini
[0]
id=1
name="战士"
hp=200
```

## 性能说明

- 首次访问时所有数据加载到内存
- 索引在内存中维护，每次加载时重建
- 对大表，索引最常查询的列可显著提升 WHERE 性能
