extends GdUnitTestSuite

## Integration tests for GDSQL.SQLParser.parse_to_dao — converting SQL to BaseDao.

const TEST_DIR = "user://test_gdsql_sqlparser/"
const TEST_ROOT_CFG = TEST_DIR + "config.cfg"
const TEST_DB = "_test_sqlparser"
const TEST_TABLE = "users"
const TEST_DB_PATH = TEST_DIR + TEST_DB + "/"

var _dao: GDSQL.AdminDao
var _original_root_cfg_path: String

var _columns = [
	{"Column Name": "id",   "Data Type": TYPE_INT,    "PK": true,  "NN": true,  "AI": true,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	{"Column Name": "name", "Data Type": TYPE_STRING, "PK": false, "NN": true,  "AI": false,
	 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	{"Column Name": "score","Data Type": TYPE_FLOAT,  "PK": false, "NN": false, "AI": false,
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


## 测试: parse_to_dao INSERT
func test_parse_to_dao_insert() -> void:
	var sql = "insert into %s.%s values(1, 'Alice', 95.5)" % [TEST_DB, TEST_TABLE]
	var dao = GDSQL.SQLParser.parse_to_dao(sql)
	assert_that(dao).is_not_null()
	var res = dao.query()
	assert_bool(res.ok()).is_true()

	# Verify via select
	var rows = _bd().select("*", false).from(TEST_TABLE).query().get_data()
	assert_int(rows.size()).is_equal(1)
	assert_float(rows[0][2]).is_equal(95.5)


## 测试: parse_to_dao SELECT
func test_parse_to_dao_select() -> void:
	# Insert data first
	_bd().insert_into(TEST_TABLE).values({"name": "X", "score": 10}).query()

	var sql = "select * from %s.%s where name == 'X'" % [TEST_DB, TEST_TABLE]
	var dao = GDSQL.SQLParser.parse_to_dao(sql)
	assert_that(dao).is_not_null()
	var res = dao.query()
	var rows = res.get_data()
	assert_int(rows.size()).is_equal(1)
	assert_str(rows[0][1]).is_equal("X")


## 测试: parse_to_dao UPDATE
func test_parse_to_dao_update() -> void:
	_bd().insert_into(TEST_TABLE).values({"name": "Target", "score": 50}).query()

	var sql = "update %s.%s set score = 99 where name == 'Target'" % [TEST_DB, TEST_TABLE]
	var dao = GDSQL.SQLParser.parse_to_dao(sql)
	assert_that(dao).is_not_null()
	dao.query()

	var rows = _bd().select("score", false).from(TEST_TABLE).where("name == 'Target'").query().get_data()
	assert_float(rows[0][0]).is_equal(99.0)


## 测试: parse_to_dao DELETE
func test_parse_to_dao_delete() -> void:
	_bd().insert_into(TEST_TABLE).values({"name": "Del", "score": 1}).query()

	var sql = "delete from %s.%s where name == 'Del'" % [TEST_DB, TEST_TABLE]
	var dao = GDSQL.SQLParser.parse_to_dao(sql)
	assert_that(dao).is_not_null()
	dao.query()

	var rows = _bd().select("*", false).from(TEST_TABLE).query().get_data()
	assert_int(rows.size()).is_equal(0)


func _bd() -> GDSQL.BaseDao:
	var bd = GDSQL.BaseDao.new()
	bd.use_db(TEST_DB)
	return bd
