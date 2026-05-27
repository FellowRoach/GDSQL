extends GdUnitTestSuite

## Tests for GDSQL.GBatisEntityDB — entity cache singleton.

const TEST_ENTITY_ID = "_test_ent_id"
const TEST_ENTITY_NAME = "_test_ent_name"

## 测试: has_entity 空时返回 false
func test_has_entity_empty() -> void:
	assert_bool(GDSQL.GBatisEntityDB.has_entity("TestClass", "id", 1)).is_false()


## 测试: set 后 has 返回 true
func test_set_then_has() -> void:
	var e = _make_entity({"id": 1, "name": "test"})
	GDSQL.GBatisEntityDB.set_entity("TestClass", "id", 1, e)
	assert_bool(GDSQL.GBatisEntityDB.has_entity("TestClass", "id", 1)).is_true()


## 测试: get 返回之前 set 的对象
func test_set_then_get() -> void:
	var e = _make_entity({"id": 42, "name": "answer"})
	GDSQL.GBatisEntityDB.set_entity("TestClass", "id", 42, e)
	var got = GDSQL.GBatisEntityDB.get_entity("TestClass", "id", 42)
	assert_that(got).is_equal(e)


## 测试: 不存在的实体返回 null
func test_get_non_existent() -> void:
	var got = GDSQL.GBatisEntityDB.get_entity("NoSuch", "id", 999)
	assert_that(got).is_null()


## 测试: 不同主键的实体独立存储
func test_different_primary_keys() -> void:
	var e1 = _make_entity({"id": 1})
	var e2 = _make_entity({"id": 2})
	GDSQL.GBatisEntityDB.set_entity("Test", "id", 1, e1)
	GDSQL.GBatisEntityDB.set_entity("Test", "id", 2, e2)
	assert_that(GDSQL.GBatisEntityDB.get_entity("Test", "id", 1)).is_equal(e1)
	assert_that(GDSQL.GBatisEntityDB.get_entity("Test", "id", 2)).is_equal(e2)


## 测试: 不同类名独立存储
func test_different_classes() -> void:
	var e_a = _make_entity({"id": 1})
	var e_b = _make_entity({"id": 1})
	GDSQL.GBatisEntityDB.set_entity("ClassA", "id", 1, e_a)
	GDSQL.GBatisEntityDB.set_entity("ClassB", "id", 1, e_b)
	assert_that(GDSQL.GBatisEntityDB.get_entity("ClassA", "id", 1)).is_equal(e_a)
	assert_that(GDSQL.GBatisEntityDB.get_entity("ClassB", "id", 1)).is_equal(e_b)


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
