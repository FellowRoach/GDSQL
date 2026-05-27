extends GdUnitTestSuite

## Integration tests for GBatisMapperParser.query() with a real script class.

const TEST_DIR = "user://test_gdsql_mapper_query/"
const TEST_ROOT_CFG = TEST_DIR + "config.cfg"
const TEST_XML = TEST_DIR + "test_mapper.xml"
const TEST_SCRIPT = TEST_DIR + "TestItemMapper.gd"
const TEST_DB = "_test_mapper_query"
const TEST_TABLE = "items"
const TEST_DB_PATH = TEST_DIR + TEST_DB + "/"

var _dao: GDSQL.AdminDao
var _original_root_cfg_path: String

var _columns = [
	{"Column Name": "id",   "Data Type": TYPE_INT,    "PK": true,  "NN": true,  "AI": true,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	{"Column Name": "name", "Data Type": TYPE_STRING, "PK": false, "NN": true,  "AI": false,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	{"Column Name": "price","Data Type": TYPE_FLOAT,  "PK": false, "NN": false, "AI": false,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
]


func before_test() -> void:
	var rc = GDSQL.RootConfig
	_original_root_cfg_path = rc.path
	var dir_abs = ProjectSettings.globalize_path(TEST_DIR)
	if not DirAccess.dir_exists_absolute(dir_abs):
		DirAccess.make_dir_recursive_absolute(dir_abs)
	var cfg_abs = ProjectSettings.globalize_path(TEST_ROOT_CFG)
	if not FileAccess.file_exists(cfg_abs):
		ConfigFile.new().save(TEST_ROOT_CFG)
	rc.set_path(TEST_ROOT_CFG)
	_dao = GDSQL.AdminDao.new()
	if GDSQL.RootConfig.has_section(TEST_DB):
		await _dao.drop_database(TEST_DB)
	assert_int(_dao.create_database(TEST_DB, TEST_DB_PATH)).is_equal(OK)
	assert_int(await _dao.create_table(TEST_DB, TEST_TABLE, _columns)).is_equal(OK)


func after_test() -> void:
	if GDSQL.RootConfig.has_section(TEST_DB):
		await _dao.drop_database(TEST_DB)
	_dao = null
	GDSQL.RootConfig.set_path(_original_root_cfg_path)


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

func _write_xml(content: String) -> void:
	var f = FileAccess.open(TEST_XML, FileAccess.WRITE)
	f.store_string(content)
	f.close()

func _bd() -> GDSQL.BaseDao:
	var bd = GDSQL.BaseDao.new()
	bd.use_db(TEST_DB)
	return bd


# --------------------------------------------------------------------------
# Tests
# --------------------------------------------------------------------------

## 测试: Mapper SELECT all via mapper_parser
func test_select_all() -> void:
	_bd().insert_into(TEST_TABLE).values({"name": "A", "price": 10}).query()
	_bd().insert_into(TEST_TABLE).values({"name": "B", "price": 20}).query()

	_write_xml("""<?xml version="1.0" encoding="UTF-8"?>
<mapper namespace="GBatisMapper">
	<resultMap type="Dictionary" id="itemMap" autoMapping="true">
		<id property="id" column="id"/>
		<result property="name" column="name"/>
	</resultMap>
	<select id="select_all" resultMap="itemMap">
		select * from %s.%s
	</select>
</mapper>""" % [TEST_DB, TEST_TABLE])

	var gxml = load(TEST_XML) as GXML
	var parser = GDSQL.GBatisMapperParser.new()
	parser.config = gxml
	# Provide proper method list with return info
	parser.set_method_list([{
		"name": "select_all", "args": [],
		"return": {"type": TYPE_ARRAY, "class_name": &"", "hint": 0, "hint_string": "", "usage": 0}
	}])

	var result = parser.query("select_all", {})
	assert_that(result).is_not_null()
	assert_bool(result is Array).is_true()
	assert_int(result.size()).is_equal(2)


## 测试: Mapper SELECT by id
func test_select_by_id() -> void:
	_bd().insert_into(TEST_TABLE).values({"name": "Target", "price": 99}).query()

	_write_xml("""<?xml version="1.0" encoding="UTF-8"?>
<mapper namespace="GBatisMapper">
	<resultMap type="Dictionary" id="itemMap" autoMapping="true">
		<id property="id" column="id"/>
	</resultMap>
	<select id="select_by_id" resultMap="itemMap">
		select * from %s.%s where id == #{id}
	</select>
</mapper>""" % [TEST_DB, TEST_TABLE])

	var gxml = load(TEST_XML) as GXML
	var parser = GDSQL.GBatisMapperParser.new()
	parser.config = gxml
	parser.set_method_list([{
		"name": "select_by_id", "args": [{"name": "id"}],
		"return": {"type": TYPE_DICTIONARY, "class_name": &"", "hint": 0, "hint_string": "", "usage": 0}
	}])

	var result = parser.query("select_by_id", {"id": 1})
	assert_that(result).is_not_null()
	assert_str(result["name"]).is_equal("Target")


## 测试: Mapper INSERT
func test_mapper_insert() -> void:
	_write_xml("""<?xml version="1.0" encoding="UTF-8"?>
<mapper namespace="GBatisMapper">
	<insert id="insert_item" useGeneratedKeys="true" databaseId="%s">
		insert into %s(name, price) values(#{name}, #{price})
	</insert>
</mapper>""" % [TEST_DB, TEST_TABLE])

	var gxml = load(TEST_XML) as GXML
	var parser = GDSQL.GBatisMapperParser.new()
	parser.config = gxml
	parser.set_method_list([{
		"name": "insert_item", "args": [{"name": "name"}, {"name": "price"}],
		"return": {"type": TYPE_INT, "class_name": &"", "hint": 0, "hint_string": "", "usage": 0}
	}])

	parser.query("insert_item", {"name": "Inserted", "price": 55.5})

	var rows = _bd().select("name", false).from(TEST_TABLE).query().get_data()
	assert_int(rows.size()).is_equal(1)
	assert_str(rows[0][0]).is_equal("Inserted")
