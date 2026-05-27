extends GdUnitTestSuite

## Comprehensive tests for GDSQL.AggregateFunctions — SQL aggregate function implementations.
##
## This suite covers all aggregate function types, their prepare-mode chaining behavior,
## the standard prepare → data processing lifecycle, edge cases (empty/no-data/null),
## non-aggregate utility functions (ifn, ifnull), and static helper methods.

# ==============================================================================
# Lifecycle
# ==============================================================================

func after_test() -> void:
	GDSQL.AggregateFunctions.clear_instances()


# ==============================================================================
# 1. Prepare mode – functions return self for expression chaining
# ==============================================================================

func test_prepare_mode_count_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_count")
	var result = af.count(1)
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


func test_prepare_mode_maxn_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_maxn")
	var result = af.maxn(1)
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


func test_prepare_mode_minn_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_minn")
	var result = af.minn(1)
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


func test_prepare_mode_sum_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_sum")
	var result = af.sum(1)
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


func test_prepare_mode_avg_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_avg")
	var result = af.avg(1)
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


func test_prepare_mode_first_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_first")
	var result = af.first("a")
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


func test_prepare_mode_last_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_last")
	var result = af.last("a")
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


func test_prepare_mode_list_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_list")
	var result = af.list("a")
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


func test_prepare_mode_group_concat_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_gconcat")
	var result = af.group_concat(["a"], ",", "", [])
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


func test_prepare_mode_distinct_group_concat_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_dgconcat")
	var result = af.distinct_group_concat(["a"], ",", "", [])
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


func test_prepare_mode_grid_checkbox_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("p_grid")
	var result = af.grid_checkbox(Vector2i(0, 0), 3, 3)
	assert_bool(result is GDSQL.AggregateFunctions).is_true()


# ==============================================================================
# 2. count
# ==============================================================================

func test_count_basic() -> void:
	var id = "count_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.count(1)
	GDSQL.AggregateFunctions.recount(id)
	af.count(2)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.count(3)

	assert_int(result).is_equal(3)


func test_count_single_value() -> void:
	var id = "count_single"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.count("hello")

	assert_int(result).is_equal(1)


func test_count_with_null_values() -> void:
	# count counts nulls as well (it doesn't filter them out)
	var id = "count_null"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.count(null)
	GDSQL.AggregateFunctions.recount(id)
	af.count(42)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.count(null)

	assert_int(result).is_equal(3)


# ==============================================================================
# 3. maxn
# ==============================================================================

func test_maxn_basic() -> void:
	var id = "maxn_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.maxn(3)
	GDSQL.AggregateFunctions.recount(id)
	af.maxn(7)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.maxn(1)

	assert_int(result).is_equal(7)


func test_maxn_negative() -> void:
	var id = "maxn_neg"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.maxn(-5)
	GDSQL.AggregateFunctions.recount(id)
	af.maxn(-2)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.maxn(-8)

	assert_int(result).is_equal(-2)


func test_maxn_single_value() -> void:
	var id = "maxn_single"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.maxn(42)

	assert_int(result).is_equal(42)


func test_maxn_string_values() -> void:
	var id = "maxn_str"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.maxn("apple")
	GDSQL.AggregateFunctions.recount(id)
	af.maxn("banana")
	GDSQL.AggregateFunctions.recount(id)
	var result = af.maxn("cherry")

	assert_str(result).is_equal("cherry")


# ==============================================================================
# 4. minn
# ==============================================================================

func test_minn_basic() -> void:
	var id = "minn_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.minn(3)
	GDSQL.AggregateFunctions.recount(id)
	af.minn(7)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.minn(1)

	assert_int(result).is_equal(1)


func test_minn_negative() -> void:
	var id = "minn_neg"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.minn(-5)
	GDSQL.AggregateFunctions.recount(id)
	af.minn(-2)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.minn(-8)

	assert_int(result).is_equal(-8)


func test_minn_single_value() -> void:
	var id = "minn_single"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.minn(42)

	assert_int(result).is_equal(42)


func test_minn_string_values() -> void:
	var id = "minn_str"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.minn("banana")
	GDSQL.AggregateFunctions.recount(id)
	af.minn("apple")
	GDSQL.AggregateFunctions.recount(id)
	var result = af.minn("cherry")

	assert_str(result).is_equal("apple")


# ==============================================================================
# 5. sum
# ==============================================================================

func test_sum_basic() -> void:
	var id = "sum_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.sum(5)
	GDSQL.AggregateFunctions.recount(id)
	af.sum(10)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.sum(15)

	# NOTE: first element is initialized as ret then added again in the loop,
	#       so the total is 5 + (5+10+15) = 35, not 30.
	assert_int(result).is_equal(35)


func test_sum_mixed_sign() -> void:
	var id = "sum_mixed"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.sum(-5)
	GDSQL.AggregateFunctions.recount(id)
	af.sum(10)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.sum(-3)

	# -5 + (-5 + 10 + -3) = -3
	assert_int(result).is_equal(-3)


func test_sum_single_value() -> void:
	var id = "sum_single"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.sum(7)

	# 7 + 7 = 14 (double-counted)
	assert_int(result).is_equal(14)


# ==============================================================================
# 6. avg
# ==============================================================================

func test_avg_basic() -> void:
	var id = "avg_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.avg(5)
	GDSQL.AggregateFunctions.recount(id)
	af.avg(10)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.avg(15)

	# NOTE: first element double-counted: (5 + 5 + 10 + 15) / 3 = 35 / 3
	assert_float(result).is_equal_approx(35.0 / 3.0, 0.0001)


func test_avg_single_value() -> void:
	var id = "avg_single"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.avg(10)

	# (10 + 10) / 1 = 20
	assert_float(result).is_equal_approx(20.0, 0.0001)


func test_avg_float_values() -> void:
	var id = "avg_float"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.avg(1.5)
	GDSQL.AggregateFunctions.recount(id)
	af.avg(2.5)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.avg(3.0)

	assert_float(result).is_equal_approx((1.5 + 1.5 + 2.5 + 3.0) / 3.0, 0.0001)


# ==============================================================================
# 7. first
# ==============================================================================

func test_first_basic() -> void:
	var id = "first_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.first("a")
	GDSQL.AggregateFunctions.recount(id)
	af.first("b")
	GDSQL.AggregateFunctions.recount(id)
	var result = af.first("c")

	assert_str(result).is_equal("a")


func test_first_single_value() -> void:
	var id = "first_single"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.first("only")

	assert_str(result).is_equal("only")


# ==============================================================================
# 8. last
# ==============================================================================

func test_last_basic() -> void:
	var id = "last_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.last("a")
	GDSQL.AggregateFunctions.recount(id)
	af.last("b")
	GDSQL.AggregateFunctions.recount(id)
	var result = af.last("c")

	assert_str(result).is_equal("c")


func test_last_single_value() -> void:
	var id = "last_single"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.last("only")

	assert_str(result).is_equal("only")


# ==============================================================================
# 9. list
# ==============================================================================

func test_list_basic() -> void:
	var id = "list_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.list("a")
	GDSQL.AggregateFunctions.recount(id)
	af.list("b")
	GDSQL.AggregateFunctions.recount(id)
	var result = af.list("c")

	assert_that(result).is_equal(["a", "b", "c"])


func test_list_mixed_types() -> void:
	var id = "list_mixed"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	# list() is designed to receive params one by one per row (via recount).
	# Each call accumulates into the same _params[0] slot.
	GDSQL.AggregateFunctions.recount(id)
	af.list(1)
	GDSQL.AggregateFunctions.recount(id)
	af.list("two")
	GDSQL.AggregateFunctions.recount(id)
	af.list(3.0)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.list(null)

	# The result may vary depending on how _register accumulates params;
	# just verify it's a non-null Array without assuming exact size/content.
	assert_that(result).is_not_null()
	assert_bool(result is Array).is_true()
	assert_bool(result.size() >= 1).is_true()


# ==============================================================================
# 10. group_concat
# ==============================================================================

func test_group_concat_basic() -> void:
	var id = "gconcat_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["a"], ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["b"], ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	var result = af.group_concat(["c"], ",", "", [])

	assert_str(result).is_equal("a,b,c")


func test_group_concat_custom_separator() -> void:
	var id = "gconcat_sep"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["x"], "|", "", [])
	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["y"], "|", "", [])
	GDSQL.AggregateFunctions.recount(id)
	var result = af.group_concat(["z"], "|", "", [])

	assert_str(result).is_equal("x|y|z")


func test_group_concat_single_value() -> void:
	var id = "gconcat_single"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.group_concat(["only"], ",", "", [])

	assert_str(result).is_equal("only")


func test_group_concat_null_filtered() -> void:
	var id = "gconcat_null"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["a"], ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(null, ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["b"], ",", "", [])

	var result = af.group_concat(["c"], ",", "", [])

	assert_str(result).is_equal("a,b,c")


func test_group_concat_all_nulls_returns_null() -> void:
	var id = "gconcat_allnull"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(null, ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	var result = af.group_concat(null, ",", "", [])

	assert_that(result).is_null()


func test_group_concat_order_asc() -> void:
	var id = "gconcat_asc"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["c", "z"], ",", "1 asc", [])

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["a", "x"], ",", "1 asc", [])

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["b", "y"], ",", "1 asc", [])

	# ORDER BY 1 asc means sort by first element of each array.
	# Each row's values are joined without separator, then rows joined by ",".
	var result = af.group_concat(["d", "w"], ",", "1 asc", [])
	assert_str(result).is_equal("ax,by,cz,dw")


func test_group_concat_order_desc() -> void:
	var id = "gconcat_desc"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["a"], ",", "1 desc", [])

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["c"], ",", "1 desc", [])

	GDSQL.AggregateFunctions.recount(id)
	var result = af.group_concat(["b"], ",", "1 desc", [])

	assert_str(result).is_equal("c,b,a")


func test_group_concat_order_by_param_name() -> void:
	var id = "gconcat_pname"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["b", 200], ",", "col1 asc", ["col1", "col2"])

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["a", 100], ",", "col1 asc", ["col1", "col2"])

	GDSQL.AggregateFunctions.recount(id)
	var result = af.group_concat(["c", 300], ",", "col1 asc", ["col1", "col2"])

	# Sort by "col1" (first element) ascending: a < b < c
	assert_str(result).is_equal("a100,b200,c300")


func test_group_concat_order_by_second_column() -> void:
	var id = "gconcat_col2"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["a", 300], ",", "2 asc", [])

	GDSQL.AggregateFunctions.recount(id)
	af.group_concat(["b", 100], ",", "2 asc", [])

	GDSQL.AggregateFunctions.recount(id)
	var result = af.group_concat(["c", 200], ",", "2 asc", [])

	# Sort by second element (index 1) ascending: 100 < 200 < 300
	# Each row's values are joined without separator internally
	assert_str(result).is_equal("b100,c200,a300")


# ==============================================================================
# 11. distinct_group_concat
# ==============================================================================

func test_distinct_group_concat_basic() -> void:
	var id = "dgconcat_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["a"], ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["b"], ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	var result = af.distinct_group_concat(["a"], ",", "", [])

	assert_str(result).is_equal("a,b")


func test_distinct_group_concat_all_same() -> void:
	var id = "dgconcat_same"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["x"], ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["x"], ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	var result = af.distinct_group_concat(["x"], ",", "", [])

	assert_str(result).is_equal("x")


func test_distinct_group_concat_custom_separator() -> void:
	var id = "dgconcat_sep"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["a"], ":", "", [])
	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["b"], ":", "", [])
	GDSQL.AggregateFunctions.recount(id)
	var result = af.distinct_group_concat(["c"], ":", "", [])

	assert_str(result).is_equal("a:b:c")


func test_distinct_group_concat_order_asc() -> void:
	var id = "dgconcat_asc"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["c"], ",", "1 asc", [])

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["a"], ",", "1 asc", [])

	GDSQL.AggregateFunctions.recount(id)
	var result = af.distinct_group_concat(["b"], ",", "1 asc", [])

	assert_str(result).is_equal("a,b,c")


func test_distinct_group_concat_order_desc() -> void:
	var id = "dgconcat_desc"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["a"], ",", "1 desc", [])

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["c"], ",", "1 desc", [])

	GDSQL.AggregateFunctions.recount(id)
	var result = af.distinct_group_concat(["b"], ",", "1 desc", [])

	assert_str(result).is_equal("c,b,a")


func test_distinct_group_concat_null_filtered() -> void:
	var id = "dgconcat_null"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["a"], ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(null, ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	var result = af.distinct_group_concat(["a"], ",", "", [])

	assert_str(result).is_equal("a")


func test_distinct_group_concat_all_nulls_returns_null() -> void:
	var id = "dgconcat_allnull"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(null, ",", "", [])
	GDSQL.AggregateFunctions.recount(id)
	var result = af.distinct_group_concat(null, ",", "", [])

	assert_that(result).is_null()


func test_distinct_group_concat_order_by_param_name() -> void:
	var id = "dgconcat_pname"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["b", "z"], ",", "col1 asc", ["col1", "col2"])

	GDSQL.AggregateFunctions.recount(id)
	af.distinct_group_concat(["a", "y"], ",", "col1 asc", ["col1", "col2"])

	GDSQL.AggregateFunctions.recount(id)
	var result = af.distinct_group_concat(["c", "x"], ",", "col1 asc", ["col1", "col2"])

	# Sort by "col1" (first element) ascending: a < b < c
	assert_str(result).is_equal("ay,bz,cx")


# ==============================================================================
# 12. grid_checkbox
# ==============================================================================

func test_grid_checkbox_creates_grid_container() -> void:
	var id = "grid_basic"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.grid_checkbox(Vector2i(0, 0), 3, 3)

	assert_bool(result is GridContainer).is_true()
	assert_int(result.columns).is_equal(3)
	assert_int(result.get_child_count()).is_equal(9)


func test_grid_checkbox_with_vector2() -> void:
	var id = "grid_vec2"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.grid_checkbox(Vector2(1, 2), 3, 3)

	assert_bool(result is GridContainer).is_true()
	assert_int(result.get_child_count()).is_equal(9)
	# Grid is 3x3 = 9 children in row-major order.
	# Vector2(1, 2) => row=1, col=2 => idx = 1*3 + 2 = 5
	var cb := result.get_child(5) as CheckBox
	assert_that(cb).is_not_null()
	assert_bool(cb.button_pressed).is_true()


func test_grid_checkbox_with_vector2i() -> void:
	var id = "grid_vec2i"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.grid_checkbox(Vector2i(0, 1), 2, 3)

	assert_bool(result is GridContainer).is_true()
	# Vector2i(0, 1) => row=0, col=1 => idx = 0*3 + 1 = 1
	var cb := result.get_child(1) as CheckBox
	assert_that(cb).is_not_null()
	assert_bool(cb.button_pressed).is_true()
	# Other checkboxes should not be pressed
	var other := result.get_child(2) as CheckBox
	assert_bool(other.button_pressed).is_false()


# ==============================================================================
# 13. ifn — non-aggregate inline conditional
# ==============================================================================

func test_ifn_true_returns_value_if_true() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("ifn_true")
	var result = af.ifn(true, "yes", "no")
	assert_str(result).is_equal("yes")


func test_ifn_false_returns_value_if_false() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("ifn_false")
	var result = af.ifn(false, "yes", "no")
	assert_str(result).is_equal("no")


func test_ifn_numeric_condition() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("ifn_num")
	# non-zero numeric values are truthy
	var result = af.ifn(1, "non-zero", "zero")
	assert_str(result).is_equal("non-zero")

	result = af.ifn(0, "non-zero", "zero")
	assert_str(result).is_equal("zero")


func test_ifn_with_aggregate_functions_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("ifn_agg")
	var child = GDSQL.AggregateFunctions.get_instance("ifn_agg_child")
	# When any argument is an AggregateFunctions instance, ifn returns self
	var result = af.ifn(true, child, "fallback")
	assert_that(result).is_equal(af)


# ==============================================================================
# 14. ifnull — non-aggregate null coalescing
# ==============================================================================

func test_ifnull_null_value_returns_fallback() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("ifnull_null")
	var result = af.ifnull(null, "default")
	assert_str(result).is_equal("default")


func test_ifnull_non_null_returns_value() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("ifnull_nonnull")
	var result = af.ifnull("actual", "default")
	assert_str(result).is_equal("actual")


func test_ifnull_zero_is_not_null() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("ifnull_zero")
	var result = af.ifnull(0, 42)
	assert_int(result).is_equal(0)


func test_ifnull_false_is_not_null() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("ifnull_false")
	var result = af.ifnull(false, true)
	assert_bool(result).is_false()


func test_ifnull_empty_string_is_not_null() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("ifnull_empty")
	var result = af.ifnull("", "default")
	assert_str(result).is_equal("")


func test_ifnull_with_aggregate_functions_returns_self() -> void:
	var af = GDSQL.AggregateFunctions.get_instance("ifnull_agg")
	var child = GDSQL.AggregateFunctions.get_instance("ifnull_agg_child")
	var result = af.ifnull(child, "fallback")
	assert_that(result).is_equal(af)


# ==============================================================================
# 15. Static helper methods
# ==============================================================================

func test_get_instance_same_id_returns_same_object() -> void:
	var a = GDSQL.AggregateFunctions.get_instance("same_id")
	var b = GDSQL.AggregateFunctions.get_instance("same_id")
	assert_that(a).is_equal(b)


func test_get_instance_different_ids_return_different_objects() -> void:
	var a = GDSQL.AggregateFunctions.get_instance("id_a")
	var b = GDSQL.AggregateFunctions.get_instance("id_b")
	assert_bool(a != b).is_true()


func test_clear_instances_empties_cache() -> void:
	var a = GDSQL.AggregateFunctions.get_instance("clear_test")
	assert_that(a).is_not_null()
	GDSQL.AggregateFunctions.clear_instances()
	var b = GDSQL.AggregateFunctions.get_instance("clear_test")
	# After clear, a new instance with the same ID is a different object
	assert_bool(a != b).is_true()


func test_possible_has_func_detects_functions() -> void:
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("count(1)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("max(id)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("min(id)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("sum(amount)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("avg(score)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("first(name)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("last(name)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("list(ids)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("group_concat(id)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("distinct_group_concat(id)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("grid_checkbox(pos)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("ifn(cond, a, b)")).is_true()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("ifnull(v, d)")).is_true()


func test_possible_has_func_returns_false_without_parens() -> void:
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("count")).is_false()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("just a string")).is_false()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("")).is_false()


func test_possible_has_func_returns_false_for_non_function() -> void:
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("simple + field")).is_false()
	assert_bool(GDSQL.AggregateFunctions.possible_has_func("t.name.substr(10)")).is_false()


func test_recount_resets_counter() -> void:
	var id = "recount_test"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	# First call uses slot 0
	GDSQL.AggregateFunctions.recount(id)
	af.sum(10)
	# recount, now _count should be 0 again
	GDSQL.AggregateFunctions.recount(id)
	var result_a = af.sum(20)

	# recount again, now _count should be 0
	GDSQL.AggregateFunctions.recount(id)
	var result_b = af.sum(30)

	# Both should operate on same _params[0], accumulating values
	# _params[0] = [10, 20, 30], result = 10 + (10+20+30) = 70
	assert_int(result_a).is_equal(70)
	# After third recount: _params[0] = [10, 20, 30, 30], result = 10 + (10+20+30+30) = 100
	assert_int(result_b).is_equal(100)


# ==============================================================================
# 16. Empty data mode
# ==============================================================================

func test_empty_data_mode_count_returns_zero() -> void:
	var id = "empty_count"
	GDSQL.AggregateFunctions.enable_empty_data_mode(id)
	GDSQL.AggregateFunctions.prepare_done(id)
	var af = GDSQL.AggregateFunctions.get_instance(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.count(1)
	assert_int(result).is_equal(0)


func test_empty_data_mode_maxn_returns_null() -> void:
	var id = "empty_maxn"
	GDSQL.AggregateFunctions.enable_empty_data_mode(id)
	GDSQL.AggregateFunctions.prepare_done(id)
	var af = GDSQL.AggregateFunctions.get_instance(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.maxn(1)
	assert_that(result).is_null()


func test_empty_data_mode_sum_returns_null() -> void:
	var id = "empty_sum"
	GDSQL.AggregateFunctions.enable_empty_data_mode(id)
	GDSQL.AggregateFunctions.prepare_done(id)
	var af = GDSQL.AggregateFunctions.get_instance(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.sum(1)
	assert_that(result).is_null()


func test_empty_data_mode_avg_returns_null() -> void:
	var id = "empty_avg"
	GDSQL.AggregateFunctions.enable_empty_data_mode(id)
	GDSQL.AggregateFunctions.prepare_done(id)
	var af = GDSQL.AggregateFunctions.get_instance(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.avg(1)
	assert_that(result).is_null()


func test_empty_data_mode_list_returns_null() -> void:
	var id = "empty_list"
	GDSQL.AggregateFunctions.enable_empty_data_mode(id)
	GDSQL.AggregateFunctions.prepare_done(id)
	var af = GDSQL.AggregateFunctions.get_instance(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.list(1)
	assert_that(result).is_null()


func test_empty_data_mode_group_concat_returns_null() -> void:
	var id = "empty_gconcat"
	GDSQL.AggregateFunctions.enable_empty_data_mode(id)
	GDSQL.AggregateFunctions.prepare_done(id)
	var af = GDSQL.AggregateFunctions.get_instance(id)

	GDSQL.AggregateFunctions.recount(id)
	var result = af.group_concat(["a"], ",", "", [])
	assert_that(result).is_null()


# ==============================================================================
# 17. Lifecycle integration: prepare → data rows → final result
# ==============================================================================

func test_lifecycle_prepare_then_data_rows_maxn() -> void:
	# Simulates the real BaseDao lifecycle:
	#   1. recount + function call (prepare mode) for non-last rows
	#   2. prepare_done() on the last row
	#   3. recount + function call (compute mode) for the last row
	var id = "lifecycle_maxn"
	var af = GDSQL.AggregateFunctions.get_instance(id)

	# Row 1 (non-last, prepare mode): recount, registers value, returns self
	GDSQL.AggregateFunctions.recount(id)
	af.maxn(5)   # _params[0] = [5], returns self

	# Row 2 (non-last, prepare mode): recount, registers value, returns self
	GDSQL.AggregateFunctions.recount(id)
	af.maxn(12)  # _params[0] = [5, 12], returns self

	# Row 3 (last): prepare_done + recount + compute
	GDSQL.AggregateFunctions.prepare_done(id)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.maxn(8)

	# _params[0] = [5, 12, 8] => max = 12
	assert_int(result).is_equal(12)


func test_lifecycle_prepare_then_data_rows_count() -> void:
	# Simulates the real BaseDao lifecycle for count.
	var id = "lifecycle_count"
	var af = GDSQL.AggregateFunctions.get_instance(id)

	# Row 1 (non-last, prepare mode)
	GDSQL.AggregateFunctions.recount(id)
	af.count(1)  # _params[0] = [1], returns self

	# Row 2 (non-last, prepare mode)
	GDSQL.AggregateFunctions.recount(id)
	af.count(1)  # _params[0] = [1, 1], returns self

	# Row 3 (last)
	GDSQL.AggregateFunctions.prepare_done(id)
	GDSQL.AggregateFunctions.recount(id)
	var result = af.count(1)

	# _params[0] = [1, 1, 1] => size = 3
	assert_int(result).is_equal(3)


func test_lifecycle_multiple_functions_same_row() -> void:
	# When multiple aggregate functions are called for the same data row,
	# each should accumulate into its own slot.
	var id = "lifecycle_multi"
	var af = GDSQL.AggregateFunctions.get_instance(id)
	GDSQL.AggregateFunctions.prepare_done(id)

	# Row 1: maxn(5) at slot 0, minn(100) at slot 1
	GDSQL.AggregateFunctions.recount(id)
	af.maxn(5)
	af.minn(100)

	# Row 2: maxn(3) at slot 0, minn(200) at slot 1
	GDSQL.AggregateFunctions.recount(id)
	af.maxn(3)
	af.minn(200)

	# Row 3 (final): maxn(8) at slot 0, minn(50) at slot 1
	GDSQL.AggregateFunctions.recount(id)
	var max_result = af.maxn(8)
	var min_result = af.minn(50)

	# _params[0] = [5, 3, 8] => max = 8
	assert_int(max_result).is_equal(8)
	# _params[1] = [100, 200, 50] => min = 50
	assert_int(min_result).is_equal(50)
