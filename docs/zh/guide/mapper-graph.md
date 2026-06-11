# 映射图编辑器

映射图编辑器是一个可视化拖拽工具，用于设计表关联关系并生成 ORM 代码。

## 概述

映射图将数据库表显示为画布上的可视化节点。你可以：
- 将表拖到画布上
- 在相关表之间绘制连接线
- 一键生成实体类和 XML 映射文件

## 使用节点

### 添加表
从数据库树中拖拽表到画布上，每个表会显示为一个节点。

### 节点显示
每个节点显示：表名（标题）、列名和数据类型、主键标识。

### 移动节点
自由拖拽节点调整布局。位置保存在 `.gdmappergraph` 文件中。

## 定义关联

1. 点击一个表节点中的列
2. 拖拽到另一个表节点的列
3. 两个列之间会绘制连接线

## 代码生成

选择一个或多个节点，点击 **生成**。GDSQL 会创建：

1. **实体类（`.gd`）**：带 `class_name` 的 GDScript 类，类型化属性
2. **XML 映射文件（`.xml`）**：完整的 GBatis 映射文件
3. **Mapper Graph 文件（`.gdmappergraph`）**：保存布局和关系

### 生成的实体示例

```gdscript
class_name HeroEntity extends RefCounted

var id: int
var name: String
var hp: int
var mp: int
```

## 类型推导

| 数据库类型 | GDScript 类型 |
|-----------|--------------|
| int | int |
| float | float |
| String | String |
| bool | bool |
| Vector2 | Vector2 |

## 增量同步

当数据库结构发生变化时：
1. 打开映射图
2. 变更的节点会高亮显示
3. 审查差异
4. 选择性地同步或全量同步
