extends GdUnitTestSuite

## Tests for GDSQL.SQLParser — SQL statement parsing.

# ============================================================================
# Helpers
# ============================================================================

func _find_keyword(arr: Array, keyword: String) -> String:
	for item in arr:
		if item[0].to_lower() == keyword.to_lower():
			return item[1]
	return ""


# ============================================================================
# parse_select — returns Array of [keyword, value] pairs
# ============================================================================

## 测试: SELECT 简单
func test_parse_select_simple() -> void:
	var r = GDSQL.SQLParser.parse_select("select * from t")
	assert_str(r[0][1]).is_equal("*")   # select fields
	assert_str(r[1][1]).is_equal("t")   # from table


## 测试: SELECT db.table
func test_parse_select_db_table() -> void:
	var r = GDSQL.SQLParser.parse_select("select id, name from mydb.t")
	assert_str(r[0][1]).is_equal("id, name")
	assert_str(r[1][1]).is_equal("mydb.t")


## 测试: SELECT WHERE
func test_parse_select_where() -> void:
	var r = GDSQL.SQLParser.parse_select("select * from user where age > 18")
	assert_str(r[2][1]).is_equal("age > 18")


## 测试: SELECT ORDER BY
func test_parse_select_order_by() -> void:
	var r = GDSQL.SQLParser.parse_select("select * from t order by name asc")
	var val = _find_keyword(r, "order by")
	assert_str(val).is_equal("name asc")


## 测试: SELECT LIMIT
func test_parse_select_limit() -> void:
	var r = GDSQL.SQLParser.parse_select("select * from t limit 10")
	var val = _find_keyword(r, "limit")
	assert_str(val).is_equal("10")


## 测试: SELECT LEFT JOIN
func test_parse_select_join() -> void:
	var r = GDSQL.SQLParser.parse_select("select a.* from a left join b on a.id == b.id")
	# Find the join keyword
	var join_idx = -1
	for i in r.size():
		if r[i][0].containsn("join"):
			join_idx = i
			break
	assert_bool(join_idx >= 0).is_true()


## 测试: SELECT 大小写不敏感
func test_parse_select_case_insensitive() -> void:
	var r = GDSQL.SQLParser.parse_select("SELECT * FROM t WHERE x == 1")
	assert_str(r[2][1]).is_equal("x == 1")


# ============================================================================
# parse_update
# ============================================================================

## 测试: UPDATE 简单
func test_parse_update_simple() -> void:
	var r = GDSQL.SQLParser.parse_update("update t set name = 'a' where id == 1")
	assert_str(r[0][1]).is_equal("t")
	assert_str(r[1][1]).is_equal("name = 'a'")
	assert_str(r[2][1]).is_equal("id == 1")


## 测试: UPDATE 无 WHERE
func test_parse_update_no_where() -> void:
	var r = GDSQL.SQLParser.parse_update("update t set name = 'a'")
	assert_str(r[1][1]).is_equal("name = 'a'")
	assert_int(r.size()).is_equal(2)


# ============================================================================
# parse_delete
# ============================================================================

## 测试: DELETE 简单
func test_parse_delete_simple() -> void:
	var r = GDSQL.SQLParser.parse_delete("delete from t where id == 1")
	assert_str(r[0][1]).is_equal("t")
	assert_str(r[1][1]).is_equal("id == 1")


## 测试: DELETE 无 WHERE
func test_parse_delete_no_where() -> void:
	var r = GDSQL.SQLParser.parse_delete("delete from t")
	assert_str(r[0][1]).is_equal("t")
	assert_int(r.size()).is_equal(1)


# ============================================================================
# parse_insert — returns [keyword, table, columns?, values, on_dup?, dup_data?]
# ============================================================================

## 测试: INSERT INTO 简单
func test_parse_insert_simple() -> void:
	var r = GDSQL.SQLParser.parse_insert("insert into t values(1, 'a')")
	assert_str(r[1]).is_equal("t")


## 测试: INSERT INTO 带列名
func test_parse_insert_with_columns() -> void:
	var r = GDSQL.SQLParser.parse_insert("insert into t(id, name) values(1, 'a')")
	assert_str(r[1]).is_equal("t")


## 测试: INSERT IGNORE
func test_parse_insert_ignore() -> void:
	var r = GDSQL.SQLParser.parse_insert("insert ignore into t values(1)")
	assert_str(r[1]).is_equal("t")


## 测试: INSERT ON DUPLICATE KEY UPDATE
func test_parse_insert_on_duplicate() -> void:
	var r = GDSQL.SQLParser.parse_insert("insert into t values(1) on duplicate key update name = 'x'")
	assert_str(r[1]).is_equal("t")


# ============================================================================
# parse_replace
# ============================================================================

# ============================================================================
# _get_db_table / _get_db_table_alias
# ============================================================================

## 测试: 提取 db.table
func test_get_db_table() -> void:
	var r = GDSQL.SQLParser._get_db_table("mydb.t")
	assert_int(r.size()).is_equal(2)
	assert_str(r[0]).is_equal("mydb")
	assert_str(r[1]).is_equal("t")


## 测试: 提取纯表名（无数据库，返回含空 db）
func test_get_db_table_no_db() -> void:
	var r = GDSQL.SQLParser._get_db_table("t")
	assert_int(r.size()).is_equal(2)
	assert_str(r[0]).is_equal("")   # db 为空
	assert_str(r[1]).is_equal("t")


## 测试: 提取别名（不支持 as 关键字，用空格分隔）
func test_get_db_table_alias() -> void:
	var r = GDSQL.SQLParser._get_db_table_alias("mydb.t a")
	assert_int(r.size()).is_equal(3)
	assert_str(r[0]).is_equal("mydb")
	assert_str(r[1]).is_equal("t")
	assert_str(r[2]).is_equal("a")


## 测试: 提取别名（无 as）
func test_get_db_table_alias_no_as() -> void:
	var r = GDSQL.SQLParser._get_db_table_alias("t x")
	assert_int(r.size()).is_equal(3)
	assert_str(r[1]).is_equal("t")
	assert_str(r[2]).is_equal("x")


# ============================================================================
# _remove_last_semicolon
# ============================================================================

## 测试: 去掉末尾分号
func test_remove_semicolon() -> void:
	assert_str(GDSQL.SQLParser._remove_last_semicolon("select * from t;")).is_equal("select * from t")


## 测试: 无分号
func test_remove_semicolon_none() -> void:
	assert_str(GDSQL.SQLParser._remove_last_semicolon("select * from t")).is_equal("select * from t")


## 测试: 多个分号只去末尾
func test_remove_semicolon_multi() -> void:
	assert_str(GDSQL.SQLParser._remove_last_semicolon("a; b;")).is_equal("a; b")


# ============================================================================
# _get_field_list / _get_value_list
# ============================================================================

## 测试: 解析字段列表
func test_get_field_list() -> void:
	var r = GDSQL.SQLParser._get_field_list("id, name, score")
	assert_int(r.size()).is_equal(3)


## 测试: 解析字段列表（函数内逗号）
func test_get_field_list_with_function() -> void:
	var r = GDSQL.SQLParser._get_field_list("id, max(score), name")
	assert_int(r.size()).is_equal(3)


## 测试: 解析值列表
func test_get_value_list() -> void:
	var r = GDSQL.SQLParser._get_value_list("(1,'a',3.5)", true)
	assert_int(r.size()).is_equal(3)


# ============================================================================
# prepare_sql / restore
# ============================================================================

## 测试: prepare 替换字符串
func test_prepare_sql() -> void:
	var r = GDSQL.SQLParser.prepare_sql("name = 'alice'")
	assert_str(r[0]).is_equal("name = ___Rep0___")
	assert_bool(r[1].has("___Rep0___")).is_true()


## 测试: prepare 数字不变
func test_prepare_sql_numbers() -> void:
	var r = GDSQL.SQLParser.prepare_sql("age == 18")
	assert_str(r[0]).is_equal("age == 18")


## 测试: restore 还原
func test_restore() -> void:
	var p = GDSQL.SQLParser.prepare_sql("name = 'hello'")
	assert_str(GDSQL.SQLParser.restore(p[0], p[1])).is_equal("name = 'hello'")


# ============================================================================
# _extract_bracket / _remove_outer_quotes
# ============================================================================

## 测试: 提取括号内容
func test_extract_bracket() -> void:
	assert_str(GDSQL.SQLParser._extract_bracket("(a, b)")).is_equal("a, b")


## 测试: 移除外层引号
func test_remove_outer_quotes() -> void:
	var r = GDSQL.SQLParser._remove_outer_quotes("'hello'")
	assert_int(r.size()).is_equal(3)
	assert_str(r[0]).is_equal("'")
	assert_str(r[1]).is_equal("hello")
	assert_str(r[2]).is_equal("'")
