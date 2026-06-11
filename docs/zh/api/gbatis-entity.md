# GBatisEntity API 参考

`GBatisEntity` 是 GBatis ORM 使用的实体类基类。

**类**: `RefCounted`  
**命名空间**: `GDSQL.GBatisEntity`  
**源码**: `addons/gdsql/gbatis/gbatis_entity.gd`

## 创建实体

### 手动创建

```gdscript
class_name HeroEntity extends RefCounted

var id: int = 0
var name: String = ""
var hp: int = 0
var mp: int = 0
```

### 自动生成

映射图编辑器自动生成实体类，包含类型化属性和注释。

## 类型映射

| 数据库列类型 | GDScript 属性类型 |
|------------|-----------------|
| int | int |
| float | float |
| String | String |
| bool | bool |
| Vector2/3 | Vector2/3 |
| Color | Color |

## 使用示例

```gdscript
var heroes: Array[HeroEntity] = HeroMapper.new().select_all()
for hero in heroes:
    print(hero.name, " - HP:", hero.hp)
```

## 最佳实践

- 始终使用类型化属性（`var name: String`）
- 设置默认值防止空引用
- 使用 `class_name` 全局注册
- 实体类保持简单——只放数据，不放业务逻辑
