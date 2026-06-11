# GBatisMapper API 参考

`GBatisMapper` 是创建 ORM 映射器的基类，桥接 GDScript 代码和 XML 映射文件。

**类**: `RefCounted`  
**命名空间**: `GDSQL.GBatisMapper`  
**源码**: `addons/gdsql/gbatis/gbatis_mapper.gd`

## 创建映射器

```gdscript
class_name HeroMapper extends GBatisMapper

var mapper_xml = "res://mappers/HeroMapper.xml"

func select_all() -> Array[HeroEntity]:
    pass  # 由 GBatis 自动实现

func select_by_id(id: int) -> HeroEntity:
    pass
```

## 属性

### `mapper_xml: String`
XML 映射文件路径。

### `return_type_undefined_behavior: String`
- `"ARRAY_WHEN_NECESSARY"`（默认）— 单行返回对象，多行返回数组
- `"ALWAYS_ARRAY"` — 始终返回数组

## 参数绑定

XML 中使用 `#{paramName}`，参数名需匹配方法参数名。

## 返回类型

| 方法返回类型 | 行为 |
|------------|------|
| `Array[EntityType]` | 返回类型化实体数组 |
| `EntityType` | 返回单个实体 |
| `Dictionary` | 返回原始字典 |
| `QueryResult` | 返回原始查询结果 |
| `void` | 用于 INSERT/UPDATE/DELETE |

## 缓存控制

```xml
<select id="select_all" useCache="true" resultMap="heroResult">
    SELECT * FROM c_hero
</select>
```
