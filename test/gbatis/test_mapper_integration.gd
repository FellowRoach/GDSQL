extends GdUnitTestSuite

## Tests for GBatis mapper — XML Mapper parsing, placeholder replacement, and format loader.

const TEST_DIR = "user://test_gdsql_gbatis/"
const TEST_ROOT_CFG = TEST_DIR + "config.cfg"
const TEST_DB = "_test_gbatis"
const TEST_TABLE_SKILL = "c_skill"
const TEST_TABLE_BUFF = "c_skill_buff"
const TEST_DB_PATH = TEST_DIR + TEST_DB + "/"

var _dao: GDSQL.AdminDao
var _original_root_cfg_path: String

var _skill_columns = [
	{"Column Name": "id",   "Data Type": TYPE_INT,    "PK": true,  "NN": true,  "AI": true,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	{"Column Name": "name", "Data Type": TYPE_STRING, "PK": false, "NN": false, "AI": false,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	{"Column Name": "icon", "Data Type": TYPE_STRING, "PK": false, "NN": false, "AI": false,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	{"Column Name": "desc",  "Data Type": TYPE_STRING, "PK": false, "NN": false, "AI": false,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	{"Column Name": "max_level", "Data Type": TYPE_INT, "PK": false, "NN": false, "AI": false,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
]

var _buff_columns = [
	{"Column Name": "id",   "Data Type": TYPE_INT,    "PK": true,  "NN": true,  "AI": true,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	{"Column Name": "sid",  "Data Type": TYPE_INT,    "PK": false, "NN": false, "AI": false,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	{"Column Name": "eid",  "Data Type": TYPE_INT,    "PK": false, "NN": false, "AI": false,
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
	assert_int(await _dao.create_table(TEST_DB, TEST_TABLE_SKILL, _skill_columns)).is_equal(OK)
	assert_int(await _dao.create_table(TEST_DB, TEST_TABLE_BUFF, _buff_columns)).is_equal(OK)


func after_test() -> void:
	if GDSQL.RootConfig.has_section(TEST_DB):
		await _dao.drop_database(TEST_DB)
	_dao = null
	GDSQL.RootConfig.set_path(_original_root_cfg_path)


# --------------------------------------------------------------------------
# Placeholder regex
# --------------------------------------------------------------------------

## 测试: #{id} 占位符匹配
func test_placeholder_simple() -> void:
	var sql = "select * from t where id == #{id}"
	var re = GDSQL.GBatisMapperParser.re_placeholder
	var matches = re.search_all(sql)
	assert_int(matches.size()).is_equal(1)
	assert_str(matches[0].get_string(2)).is_equal("id")


## 测试: #{obj.prop} 占位符
func test_placeholder_dot() -> void:
	var sql = "where name == #{user.name}"
	var matches = GDSQL.GBatisMapperParser.re_placeholder.search_all(sql)
	assert_int(matches.size()).is_equal(1)
	assert_str(matches[0].get_string(2)).is_equal("user.name")


## 测试: #{list[0]} 占位符
func test_placeholder_index() -> void:
	var sql = "where id == #{list[0]}"
	var matches = GDSQL.GBatisMapperParser.re_placeholder.search_all(sql)
	assert_int(matches.size()).is_equal(1)
	assert_str(matches[0].get_string(2)).is_equal("list[0]")


## 测试: ${ } 替换占位符
func test_placeholder_dollar() -> void:
	var sql = "${table_name}.id == #{id}"
	var matches = GDSQL.GBatisMapperParser.re_placeholder.search_all(sql)
	assert_int(matches.size()).is_equal(2)
	# First is ${table_name}
	assert_str(matches[0].get_string(1)).is_equal("${")
	assert_str(matches[0].get_string(2)).is_equal("table_name")
	# Second is #{id}
	assert_str(matches[1].get_string(1)).is_equal("#{")


## 测试: 多个占位符
func test_placeholder_multi() -> void:
	var sql = "where a == #{a} and b == #{b} and c == #{c}"
	var matches = GDSQL.GBatisMapperParser.re_placeholder.search_all(sql)
	assert_int(matches.size()).is_equal(3)


## 测试: #{map[key]} 占位符
func test_placeholder_map_key() -> void:
	var sql = "where val == #{map[key]}"
	var matches = GDSQL.GBatisMapperParser.re_placeholder.search_all(sql)
	assert_int(matches.size()).is_equal(1)
