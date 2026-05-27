extends GdUnitTestSuite

## Unit tests for GDSQL.GBatisEntity — entity base class.

## 测试: 新建实体默认属性未设置
func test_new_entity_all_null() -> void:
	var e = _make_entity({})
	assert_bool(e.is_all_propeties_set()).is_false()


## 测试: 设置所有属性后检查通过
func test_entity_all_set() -> void:
	var e = _make_entity({"id": 1, "name": "test"})
	assert_bool(e.is_all_propeties_set()).is_true()


## 测试: 部分属性未设置
func test_entity_partial_set() -> void:
	var e = _make_entity({"id": 1})
	assert_bool(e.is_all_propeties_set()).is_false()


## 测试: 检查单个属性已设置
func test_is_property_set_true() -> void:
	var e = _make_entity({"id": 1})
	assert_bool(e.is_property_set("id")).is_true()


## 测试: 检查单个属性未设置
func test_is_property_set_false() -> void:
	var e = _make_entity({})
	assert_bool(e.is_property_set("id")).is_false()


## 测试: 检查多个属性全部设置
func test_is_properties_set_all() -> void:
	var e = _make_entity({"id": 1, "name": "x"})
	assert_bool(e.is_properties_set(["id", "name"])).is_true()


## 测试: 检查多个属性部分未设置
func test_is_properties_set_partial() -> void:
	var e = _make_entity({"id": 1})
	assert_bool(e.is_properties_set(["id", "name"])).is_false()


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

func _make_entity(vals: Dictionary) -> GDSQL.GBatisEntity:
	var script = GDScript.new()
	script.source_code = """extends GDSQL.GBatisEntity
var id = GDSQL.GBatisEntity.NULL
var name = GDSQL.GBatisEntity.NULL
"""
	script.reload()
	var e = script.new() as GDSQL.GBatisEntity
	for k in vals:
		e.set_indexed(k, vals[k])
	return e
