extends GdUnitTestSuite

## GDSQL.ConditionWrapper is a chainable condition builder for SQL WHERE clauses.
##
## Tests cover: basic conditions, AND/OR chaining, nested combinations,
## string comparisons, missing table detection, and subquery results.

# ---------------------------------------------------------------------------
# Basic condition tests
# ---------------------------------------------------------------------------

func test_basic_condition_true() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.age >= 20", {"t": {true: ["age"]}})
	var result = cw.check([], {"t": {"age": 25}})
	assert_bool(result).is_true()


func test_basic_condition_false() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.age >= 20", {"t": {true: ["age"]}})
	var result = cw.check([], {"t": {"age": 15}})
	assert_bool(result).is_false()


func test_basic_condition_equal() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.level == 10", {"t": {true: ["level"]}})
	assert_bool(cw.check([], {"t": {"level": 10}})).is_true()
	assert_bool(cw.check([], {"t": {"level": 11}})).is_false()


func test_basic_condition_not_equal() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.level != 0", {"t": {true: ["level"]}})
	assert_bool(cw.check([], {"t": {"level": 1}})).is_true()
	assert_bool(cw.check([], {"t": {"level": 0}})).is_false()


# ---------------------------------------------------------------------------
# String comparison tests
# ---------------------------------------------------------------------------

func test_string_equality() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.name == 'Alice'", {"t": {true: ["name"]}})
	assert_bool(cw.check([], {"t": {"name": "Alice"}})).is_true()
	assert_bool(cw.check([], {"t": {"name": "Bob"}})).is_false()


func test_string_begins_with() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.name.begins_with('Ali')", {"t": {true: ["name"]}})
	assert_bool(cw.check([], {"t": {"name": "Alice"}})).is_true()
	assert_bool(cw.check([], {"t": {"name": "Bob"}})).is_false()


# ---------------------------------------------------------------------------
# AND chaining tests
# ---------------------------------------------------------------------------

func test_and_chaining_both_true() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.a > 5", {"t": {true: ["a", "b"]}})
	cw.and_(GDSQL.ConditionWrapper.new().cond("t.b < 10", {"t": {true: ["a", "b"]}}))
	var result = cw.check([], {"t": {"a": 7, "b": 5}})
	assert_bool(result).is_true()


func test_and_chaining_first_false() -> void:
	# When the first condition is false, AND short-circuits and returns false.
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.a > 5", {"t": {true: ["a", "b"]}})
	cw.and_(GDSQL.ConditionWrapper.new().cond("t.b < 10", {"t": {true: ["a", "b"]}}))
	var result = cw.check([], {"t": {"a": 3, "b": 5}})
	assert_bool(result).is_false()


func test_and_chaining_second_false() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.a > 5", {"t": {true: ["a", "b"]}})
	cw.and_(GDSQL.ConditionWrapper.new().cond("t.b < 10", {"t": {true: ["a", "b"]}}))
	var result = cw.check([], {"t": {"a": 7, "b": 15}})
	assert_bool(result).is_false()


func test_and_chaining_both_false() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.a > 5", {"t": {true: ["a", "b"]}})
	cw.and_(GDSQL.ConditionWrapper.new().cond("t.b < 10", {"t": {true: ["a", "b"]}}))
	var result = cw.check([], {"t": {"a": 1, "b": 20}})
	assert_bool(result).is_false()


func test_and_three_conditions() -> void:
	# a > 0 AND b > 0 AND c > 0  (nested chain)
	var cw_c = GDSQL.ConditionWrapper.new().cond("t.c > 0", {"t": {true: ["c"]}})
	var cw_bc = GDSQL.ConditionWrapper.new().cond("t.b > 0", {"t": {true: ["a", "b", "c"]}})
	cw_bc.and_(cw_c)
	var cw_abc = GDSQL.ConditionWrapper.new().cond("t.a > 0", {"t": {true: ["a", "b", "c"]}})
	cw_abc.and_(cw_bc)

	var data = {"t": {"a": 1, "b": 2, "c": 3}}
	assert_bool(cw_abc.check([], data)).is_true()

	data = {"t": {"a": 0, "b": 2, "c": 3}}
	assert_bool(cw_abc.check([], data)).is_false()


# ---------------------------------------------------------------------------
# OR chaining tests
# ---------------------------------------------------------------------------

func test_or_chaining_both_false() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.a > 5", {"t": {true: ["a", "b"]}})
	cw.or_(GDSQL.ConditionWrapper.new().cond("t.b > 10", {"t": {true: ["a", "b"]}}))
	var result = cw.check([], {"t": {"a": 3, "b": 5}})
	assert_bool(result).is_false()


func test_or_chaining_first_true() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.a > 5", {"t": {true: ["a", "b"]}})
	cw.or_(GDSQL.ConditionWrapper.new().cond("t.b > 10", {"t": {true: ["a", "b"]}}))
	var result = cw.check([], {"t": {"a": 7, "b": 5}})
	assert_bool(result).is_true()


func test_or_chaining_second_true() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.a > 5", {"t": {true: ["a", "b"]}})
	cw.or_(GDSQL.ConditionWrapper.new().cond("t.b > 10", {"t": {true: ["a", "b"]}}))
	var result = cw.check([], {"t": {"a": 3, "b": 15}})
	assert_bool(result).is_true()


func test_or_chaining_both_true() -> void:
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.a > 5", {"t": {true: ["a", "b"]}})
	cw.or_(GDSQL.ConditionWrapper.new().cond("t.b > 10", {"t": {true: ["a", "b"]}}))
	var result = cw.check([], {"t": {"a": 7, "b": 15}})
	assert_bool(result).is_true()


# ---------------------------------------------------------------------------
# Nested AND/OR combination tests
# ---------------------------------------------------------------------------

func test_nested_and_or_or() -> void:
	# Condition: t.a > 5 AND (t.b < 10 OR t.c == 1)
	# The AND wrapper wraps an OR wrapper.
	var cw_or = GDSQL.ConditionWrapper.new()
	cw_or.cond("t.b < 10", {"t": {true: ["a", "b", "c"]}})
	cw_or.or_(GDSQL.ConditionWrapper.new().cond("t.c == 1", {"t": {true: ["a", "b", "c"]}}))

	var cw_and = GDSQL.ConditionWrapper.new()
	cw_and.cond("t.a > 5", {"t": {true: ["a", "b", "c"]}})
	cw_and.and_(cw_or)

	# a > 5 is true, b < 10 is true => overall true
	assert_bool(cw_and.check([], {"t": {"a": 7, "b": 3, "c": 0}})).is_true()

	# a > 5 is true, b < 10 is false, c == 1 is true => overall true (OR inside AND)
	assert_bool(cw_and.check([], {"t": {"a": 7, "b": 20, "c": 1}})).is_true()

	# a > 5 is false => overall false (AND short-circuit)
	assert_bool(cw_and.check([], {"t": {"a": 3, "b": 3, "c": 1}})).is_false()

	# a > 5 is true, b < 10 is false, c == 1 is false => overall false
	assert_bool(cw_and.check([], {"t": {"a": 7, "b": 20, "c": 0}})).is_false()


func test_nested_or_and_and() -> void:
	# Condition: t.a > 5 OR (t.b < 10 AND t.c > 0)
	var cw_and = GDSQL.ConditionWrapper.new()
	cw_and.cond("t.b < 10", {"t": {true: ["a", "b", "c"]}})
	cw_and.and_(GDSQL.ConditionWrapper.new().cond("t.c > 0", {"t": {true: ["a", "b", "c"]}}))

	var cw_or = GDSQL.ConditionWrapper.new()
	cw_or.cond("t.a > 5", {"t": {true: ["a", "b", "c"]}})
	cw_or.or_(cw_and)

	# a > 5 is false, b < 10 AND c > 0 is true => overall true
	assert_bool(cw_or.check([], {"t": {"a": 1, "b": 5, "c": 3}})).is_true()

	# a > 5 is true => overall true (OR short-circuit)
	assert_bool(cw_or.check([], {"t": {"a": 7, "b": 20, "c": 0}})).is_true()

	# a > 5 is false, b < 10 AND c > 0 is false => overall false
	assert_bool(cw_or.check([], {"t": {"a": 1, "b": 20, "c": 0}})).is_false()


# ---------------------------------------------------------------------------
# Empty condition test
# ---------------------------------------------------------------------------

func test_empty_condition() -> void:
	# When no condition is set, check() returns true.
	var cw = GDSQL.ConditionWrapper.new()
	var result = cw.check([], {})
	assert_bool(result).is_true()


# ---------------------------------------------------------------------------
# Missing tables detection tests
# ---------------------------------------------------------------------------

func test_missing_table() -> void:
	# When a table referenced in the condition is not in sql_input_names,
	# check() returns null and get_lacking_tables() reports the missing table.
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("no_such_table.age >= 20")
	var result = cw.check([], {})
	assert_that(result).is_null()
	var lacking = cw.get_lacking_tables()
	assert_that(lacking.size()).is_equal(1)
	assert_str(lacking[0]).is_equal("no_such_table")


func test_missing_table_with_and() -> void:
	# Main condition passes, but the AND wrapper has a missing table.
	# The lacking table should propagate to the parent wrapper.
	var cw_main = GDSQL.ConditionWrapper.new()
	cw_main.cond("t.a > 5", {"t": {true: ["a"]}})

	var cw_and = GDSQL.ConditionWrapper.new()
	cw_and.cond("missing_tbl.flag == 1")  # table is not in sql_input_names

	cw_main.and_(cw_and)
	var result = cw_main.check([], {"t": {"a": 7}})
	assert_that(result).is_null()
	var lacking = cw_main.get_lacking_tables()
	assert_that(lacking.size()).is_equal(1)
	assert_str(lacking[0]).is_equal("missing_tbl")


func test_missing_table_with_or() -> void:
	# Main condition evaluates to false, then the OR wrapper has a missing table.
	var cw_main = GDSQL.ConditionWrapper.new()
	cw_main.cond("t.a > 100", {"t": {true: ["a"]}})  # false

	var cw_or = GDSQL.ConditionWrapper.new()
	cw_or.cond("missing_tbl.flag == 1")  # table is not in sql_input_names

	cw_main.or_(cw_or)
	var result = cw_main.check([], {"t": {"a": 7}})
	assert_that(result).is_null()
	var lacking = cw_main.get_lacking_tables()
	assert_that(lacking.size()).is_equal(1)
	assert_str(lacking[0]).is_equal("missing_tbl")


# ---------------------------------------------------------------------------
# Subquery result tests
# ---------------------------------------------------------------------------

func test_subquery_returns_true_value() -> void:
	# When check() receives a QueryResult from evaluate_command_with_sql_expression,
	# it extracts the single value. A truthy value (1) becomes true.
	var qr = GDSQL.QueryResult.new()
	qr._has_head = false
	qr._columns_count = 1
	qr._data = [[1]]

	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("my_subquery", {}, {"my_subquery": qr})
	var result = cw.check([], {})
	assert_bool(result).is_true()


func test_subquery_returns_false_value() -> void:
	# When the subquery returns 0 or false, the condition evaluates to false.
	var qr = GDSQL.QueryResult.new()
	qr._has_head = false
	qr._columns_count = 1
	qr._data = [[0]]

	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("my_subquery", {}, {"my_subquery": qr})
	var result = cw.check([], {})
	assert_bool(result).is_false()


func test_subquery_empty_result_returns_false() -> void:
	# An empty subquery result (no rows) means the condition is false.
	var qr = GDSQL.QueryResult.new()
	qr._has_head = false
	qr._columns_count = 0
	qr._data = []

	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("subquery", {}, {"subquery": qr})
	var result = cw.check([], {})
	assert_bool(result).is_false()


func test_subquery_with_and_chaining() -> void:
	# Main condition (t.a > 5) AND subquery result.
	var qr = GDSQL.QueryResult.new()
	qr._has_head = false
	qr._columns_count = 1
	qr._data = [[1]]

	var cw_sub = GDSQL.ConditionWrapper.new()
	cw_sub.cond("valid_flag", {}, {"valid_flag": qr})

	var cw_main = GDSQL.ConditionWrapper.new()
	cw_main.cond("t.a > 5", {"t": {true: ["a"]}})
	cw_main.and_(cw_sub)

	# Both conditions true => true
	assert_bool(cw_main.check([], {"t": {"a": 7}})).is_true()

	# Main condition false => AND short-circuits to false
	assert_bool(cw_main.check([], {"t": {"a": 1}})).is_false()


func test_subquery_with_or_chaining() -> void:
	# Main condition (t.a > 100) OR subquery result.
	var qr = GDSQL.QueryResult.new()
	qr._has_head = false
	qr._columns_count = 1
	qr._data = [[1]]

	var cw_sub = GDSQL.ConditionWrapper.new()
	cw_sub.cond("valid_flag", {}, {"valid_flag": qr})

	var cw_main = GDSQL.ConditionWrapper.new()
	cw_main.cond("t.a > 100", {"t": {true: ["a"]}})
	cw_main.or_(cw_sub)

	# Main condition false, subquery true => OR evaluates to true
	assert_bool(cw_main.check([], {"t": {"a": 7}})).is_true()

	# Create a subquery that returns false
	var qr_false = GDSQL.QueryResult.new()
	qr_false._has_head = false
	qr_false._columns_count = 1
	qr_false._data = [[0]]

	var cw_sub2 = GDSQL.ConditionWrapper.new()
	cw_sub2.cond("valid_flag", {}, {"valid_flag": qr_false})

	var cw_main2 = GDSQL.ConditionWrapper.new()
	cw_main2.cond("t.a > 100", {"t": {true: ["a"]}})
	cw_main2.or_(cw_sub2)

	# Both false => false
	assert_bool(cw_main2.check([], {"t": {"a": 7}})).is_false()


# ---------------------------------------------------------------------------
# Chained return value tests
# ---------------------------------------------------------------------------

func test_and_returns_self() -> void:
	# and_() returns self for chaining.
	var cw = GDSQL.ConditionWrapper.new()
	var ret = cw.and_(GDSQL.ConditionWrapper.new())
	assert_that(ret).is_same(cw)


func test_or_returns_self() -> void:
	# or_() returns self for chaining.
	var cw = GDSQL.ConditionWrapper.new()
	var ret = cw.or_(GDSQL.ConditionWrapper.new())
	assert_that(ret).is_same(cw)


func test_cond_returns_self() -> void:
	# cond() returns self for chaining.
	var cw = GDSQL.ConditionWrapper.new()
	var ret = cw.cond("t.a == 1", {"t": {true: ["a"]}})
	assert_that(ret).is_same(cw)


# ---------------------------------------------------------------------------
# Static inputs tests (supplementary table data)
# ---------------------------------------------------------------------------

func test_with_static_inputs() -> void:
	# Supplementary table data is passed via static_inputs.
	# sql_input_names maps the supplementary table alias to {false: index}
	# where index is the position in static_inputs.
	# The condition uses dot notation: supp_table.field_name
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t.a > s.threshold", {"t": {true: ["a"]}, "s": {false: 0}})
	var static_inputs = [{"threshold": 5}]
	var data = {"t": {"a": 7}}
	assert_bool(cw.check(static_inputs, data)).is_true()

	data = {"t": {"a": 3}}
	assert_bool(cw.check(static_inputs, data)).is_false()


# ---------------------------------------------------------------------------
# Multiple table references in single condition
# ---------------------------------------------------------------------------

func test_multi_table_condition() -> void:
	# Condition comparing fields from two tables.
	var sql_input_names = {
		"t1": {true: ["id", "name"]},
		"t2": {true: ["id", "ref_id"]},
	}
	var cw = GDSQL.ConditionWrapper.new()
	cw.cond("t1.id == t2.ref_id", sql_input_names)

	var data = {"t1": {"id": 5, "name": "Alice"}, "t2": {"id": 10, "ref_id": 5}}
	assert_bool(cw.check([], data)).is_true()

	data = {"t1": {"id": 99, "name": "Bob"}, "t2": {"id": 10, "ref_id": 5}}
	assert_bool(cw.check([], data)).is_false()
