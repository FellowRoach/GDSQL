extends GdUnitTestSuite

## Integration tests for GDSQL.AdminDao — database/table administration API.

const TEST_DIR = "user://test_gdsql_admin/"
const TEST_ROOT_CFG = TEST_DIR + "config.cfg"

var _dao: GDSQL.AdminDao
var _original_root_cfg_path: String

# --------------------------------------------------------------------------
# Setup / Teardown
# --------------------------------------------------------------------------

func before_test() -> void:
	# Clean up from previous interrupted runs
	var dir_abs = ProjectSettings.globalize_path(TEST_DIR)
	if DirAccess.dir_exists_absolute(dir_abs):
		_clean_dir(dir_abs)
	DirAccess.make_dir_recursive_absolute(dir_abs)

	# Redirect RootConfig to test config
	var rc = GDSQL.RootConfig
	_original_root_cfg_path = rc.path
	var test_cfg_abs = ProjectSettings.globalize_path(TEST_ROOT_CFG)
	if not FileAccess.file_exists(test_cfg_abs):
		var cf = ConfigFile.new()
		cf.save(TEST_ROOT_CFG)
	rc.set_path(TEST_ROOT_CFG)

	_dao = GDSQL.AdminDao.new()


func after_test() -> void:
	_dao = null
	var rc = GDSQL.RootConfig
	rc.set_path(_original_root_cfg_path)


## Delete all files/subdirs under `path` (keeps `path` itself).
func _clean_dir(path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var f = dir.get_next()
	while f != "":
		if f == "." or f == "..":
			f = dir.get_next()
			continue
		if dir.current_is_dir():
			_remove_subdir(path.path_join(f))
		else:
			dir.remove(f)
		f = dir.get_next()
	dir.list_dir_end()


## Recursively delete a subdirectory and all its contents.
func _remove_subdir(path: String) -> void:
	_clean_dir(path)
	OS.move_to_trash(path)


# --------------------------------------------------------------------------
# create_database
# --------------------------------------------------------------------------

## 测试: 创建数据库
func test_create_database() -> void:
	var db_name = "_test_create"
	var db_path = TEST_DIR + db_name + "/"
	assert_int(_dao.create_database(db_name, db_path)).is_equal(OK)

	assert_bool(GDSQL.RootConfig.has_section(db_name)).is_true()
	assert_str(GDSQL.RootConfig.get_database_data_path(db_name)).is_equal(db_path)

	var cfg_path = GDSQL.RootConfig.get_database_config_path(db_name)
	assert_bool(DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(cfg_path))).is_true()


## 测试: 创建同名数据库报错
func test_create_database_duplicate_name() -> void:
	var n = "_test_dup"
	var p = TEST_DIR + n + "/"
	assert_int(_dao.create_database(n, p)).is_equal(OK)
	var _e = _dao.create_database(n, p)
	assert_bool(_e != OK).is_true()


## 测试: 空名称报错
func test_create_database_empty_name() -> void:
	var _e = _dao.create_database("", TEST_DIR + "x/")
	assert_bool(_e != OK).is_true()


## 测试: 重复路径报错
func test_create_database_duplicate_path() -> void:
	var p = TEST_DIR + "shared/"
	assert_int(_dao.create_database("_test_d1", p)).is_equal(OK)
	var _e = _dao.create_database("_test_d2", p)
	assert_bool(_e != OK).is_true()


# --------------------------------------------------------------------------
# alter_database
# --------------------------------------------------------------------------

## 测试: 重命名数据库
func test_alter_database_rename() -> void:
	var o = "_test_old"
	var n = "_test_new"
	assert_int(_dao.create_database(o, TEST_DIR + o + "/")).is_equal(OK)
	assert_int(await _dao.alter_database(o, n)).is_equal(OK)
	assert_bool(GDSQL.RootConfig.has_section(o)).is_false()
	assert_bool(GDSQL.RootConfig.has_section(n)).is_true()


## 测试: 改名成自己报错
func test_alter_database_same_name() -> void:
	var n = "_test_same"
	assert_int(_dao.create_database(n, TEST_DIR + n + "/")).is_equal(OK)
	var _e = await _dao.alter_database(n, n)
	assert_bool(_e != OK).is_true()


# --------------------------------------------------------------------------
# drop_database
# --------------------------------------------------------------------------

## 测试: 删除数据库
func test_drop_database() -> void:
	var n = "_test_drop"
	assert_int(_dao.create_database(n, TEST_DIR + n + "/")).is_equal(OK)
	assert_int(await _dao.drop_database(n)).is_equal(OK)
	assert_bool(GDSQL.RootConfig.has_section(n)).is_false()


## 测试: 删除不存在的报错
func test_drop_database_missing() -> void:
	var _e = await _dao.drop_database("_test_nonexistent")
	assert_bool(_e != OK).is_true()


# --------------------------------------------------------------------------
# create_table
# --------------------------------------------------------------------------

## 测试: 创建表
func test_create_table() -> void:
	var dn = "_test_db_tbl"
	assert_int(_dao.create_database(dn, TEST_DIR + dn + "/")).is_equal(OK)

	var cols = [
		{"Column Name": "id", "Data Type": TYPE_INT, "PK": true, "NN": true, "AI": true,
		 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
		{"Column Name": "name", "Data Type": TYPE_STRING, "PK": false, "NN": false, "AI": false,
		 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	]
	assert_int(await _dao.create_table(dn, "mytbl", cols)).is_equal(OK)

	var cp = GDSQL.RootConfig.get_table_config_path(dn, "mytbl")
	assert_bool(FileAccess.file_exists(ProjectSettings.globalize_path(cp))).is_true()


## 测试: 创建重复表报错
func test_create_table_duplicate() -> void:
	var dn = "_test_tbl_dup"
	assert_int(_dao.create_database(dn, TEST_DIR + dn + "/")).is_equal(OK)
	var cols = [
		{"Column Name": "id", "Data Type": TYPE_INT, "PK": true, "NN": true, "AI": false,
		 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	]
	assert_int(await _dao.create_table(dn, "_test_x", cols)).is_equal(OK)
	var _e = await _dao.create_table(dn, "_test_x", cols)
	assert_bool(_e != OK).is_true()


# --------------------------------------------------------------------------
# alter_table
# --------------------------------------------------------------------------

## 测试: 重命名表
func test_alter_table_rename() -> void:
	var dn = "_test_alt_tbl"
	assert_int(_dao.create_database(dn, TEST_DIR + dn + "/")).is_equal(OK)
	var cols = [
		{"Column Name": "id", "Data Type": TYPE_INT, "PK": true, "NN": true, "AI": false,
		 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	]
	assert_int(await _dao.create_table(dn, "_test_old_tbl", cols)).is_equal(OK)
	assert_int(await _dao.alter_table(dn, "_test_old_tbl", "_test_new_tbl", cols)).is_equal(OK)


# --------------------------------------------------------------------------
# drop_table
# --------------------------------------------------------------------------

## 测试: 删除表
func test_drop_table() -> void:
	var dn = "_test_drop_tbl"
	assert_int(_dao.create_database(dn, TEST_DIR + dn + "/")).is_equal(OK)
	var cols = [
		{"Column Name": "id", "Data Type": TYPE_INT, "PK": true, "NN": true, "AI": false,
		 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	]
	assert_int(await _dao.create_table(dn, "_test_x", cols)).is_equal(OK)
	assert_int(await _dao.drop_table(dn, "_test_x")).is_equal(OK)


# --------------------------------------------------------------------------
# truncate_table
# --------------------------------------------------------------------------

## 测试: 清空空表
func test_truncate_table_empty() -> void:
	var dn = "_test_trunc"
	assert_int(_dao.create_database(dn, TEST_DIR + dn + "/")).is_equal(OK)
	var cols = [
		{"Column Name": "id", "Data Type": TYPE_INT, "PK": true, "NN": true, "AI": false,
		 "UQ": false, "Index": false, "Default(Expression)": "", "Comment": ""},
	]
	assert_int(await _dao.create_table(dn, "_test_x", cols)).is_equal(OK)
	assert_int(await _dao.truncate_table(dn, "_test_x")).is_equal(OK)


# --------------------------------------------------------------------------
# Password
# --------------------------------------------------------------------------

## 测试: 设置密码（无交互时返回ERR_UNAUTHORIZED）
func test_set_db_password() -> void:
	var n = "_test_pwd"
	assert_int(_dao.create_database(n, TEST_DIR + n + "/")).is_equal(OK)
	var err = _dao.set_db_password(n, "secret")
	assert_bool(err == OK or err == ERR_UNAUTHORIZED).is_true()
