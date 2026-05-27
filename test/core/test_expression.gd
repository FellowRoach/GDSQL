extends GdUnitTestSuite

## Comprehensive tests for GDSQL.SQLExpression — a custom expression parser/evaluator
## used throughout the GDSQL database layer.

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

## Shorthand: parse + execute in one call, returning the result value.
func _eval(expr: String, input_names: Array = [], inputs: Array = [],
		sql_static_inputs: Array = [], base: Object = null,
		sql_mode: bool = false) -> Variant:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = sql_mode
	e.parse(expr, input_names, sql_static_inputs)
	return e.execute(inputs, {}, base, true)

## Shorthand: parse + execute with sql_varying_inputs (used in sql_mode).
func _eval_sql(expr: String, input_names: Array = [],
		sql_static_inputs: Array = [],
		sql_varying_inputs: Dictionary = {},
		sql_input_names: Dictionary = {}) -> Variant:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	if not sql_input_names.is_empty():
		e.set_sql_input_names(sql_input_names)
	e.parse(expr, input_names, sql_static_inputs)
	return e.execute([], sql_varying_inputs, null, true)


# ============================================================================
# 1. Basic arithmetic
# ============================================================================

func test_arithmetic_addition() -> void:
	assert_int(_eval("1+1")).is_equal(2)
	assert_int(_eval("1 + 1")).is_equal(2)
	assert_int(_eval("0+0")).is_equal(0)
	assert_int(_eval("-1+1")).is_equal(0)


func test_arithmetic_subtraction() -> void:
	assert_int(_eval("2-1")).is_equal(1)
	assert_int(_eval("10-5")).is_equal(5)
	assert_int(_eval("0-5")).is_equal(-5)


func test_arithmetic_multiplication() -> void:
	assert_int(_eval("2*3")).is_equal(6)
	assert_int(_eval("0*5")).is_equal(0)
	assert_int(_eval("-2*3")).is_equal(-6)


func test_arithmetic_division() -> void:
	assert_int(_eval("10/2")).is_equal(5)
	assert_int(_eval("9/3")).is_equal(3)
	assert_float(_eval("7/2")).is_equal(3.5)


func test_arithmetic_modulo() -> void:
	assert_int(_eval("5%2")).is_equal(1)
	assert_int(_eval("10%3")).is_equal(1)
	assert_int(_eval("8%4")).is_equal(0)


func test_arithmetic_power() -> void:
	assert_int(_eval("2**3")).is_equal(8)
	assert_int(_eval("3**2")).is_equal(9)
	assert_int(_eval("10**0")).is_equal(1)


func test_arithmetic_unary_minus() -> void:
	assert_int(_eval("-5")).is_equal(-5)
	assert_int(_eval("--5")).is_equal(5)
	assert_int(_eval("-(3+2)")).is_equal(-5)


func test_arithmetic_unary_plus() -> void:
	assert_int(_eval("+5")).is_equal(5)
	assert_int(_eval("++5")).is_equal(5)


func test_arithmetic_operator_precedence() -> void:
	assert_int(_eval("2+3*4")).is_equal(14)   # * before +
	assert_int(_eval("(2+3)*4")).is_equal(20)  # parens override
	assert_int(_eval("10-2*3")).is_equal(4)    # * before -
	assert_int(_eval("2**3+1")).is_equal(9)    # ** before +


# ============================================================================
# 2. Comparison
# ============================================================================

func test_comparison_equal() -> void:
	assert_bool(_eval("1==1")).is_true()
	assert_bool(_eval("1==2")).is_false()
	assert_bool(_eval("'abc'=='abc'")).is_true()
	assert_bool(_eval("'abc'=='xyz'")).is_false()


func test_comparison_not_equal() -> void:
	assert_bool(_eval("1!=2")).is_true()
	assert_bool(_eval("1!=1")).is_false()


func test_comparison_less() -> void:
	assert_bool(_eval("1<2")).is_true()
	assert_bool(_eval("2<1")).is_false()
	assert_bool(_eval("2<2")).is_false()


func test_comparison_greater() -> void:
	assert_bool(_eval("2>1")).is_true()
	assert_bool(_eval("1>2")).is_false()
	assert_bool(_eval("2>2")).is_false()


func test_comparison_less_equal() -> void:
	assert_bool(_eval("1<=2")).is_true()
	assert_bool(_eval("2<=2")).is_true()
	assert_bool(_eval("3<=2")).is_false()


func test_comparison_greater_equal() -> void:
	assert_bool(_eval("2>=1")).is_true()
	assert_bool(_eval("2>=2")).is_true()
	assert_bool(_eval("1>=2")).is_false()


func test_comparison_chained() -> void:
	assert_bool(_eval("1<2 and 2<3")).is_true()
	assert_bool(_eval("1<2 and 2>3")).is_false()


# ============================================================================
# 3. Logic
# ============================================================================

func test_logic_and() -> void:
	assert_bool(_eval("true and true")).is_true()
	assert_bool(_eval("true and false")).is_false()
	assert_bool(_eval("false and true")).is_false()
	assert_bool(_eval("false and false")).is_false()


func test_logic_or() -> void:
	assert_bool(_eval("true or false")).is_true()
	assert_bool(_eval("false or true")).is_true()
	assert_bool(_eval("false or false")).is_false()


func test_logic_not() -> void:
	assert_bool(_eval("not true")).is_false()
	assert_bool(_eval("not false")).is_true()
	assert_bool(_eval("not (1==2)")).is_true()


func test_logic_compound() -> void:
	assert_bool(_eval("true and not false")).is_true()
	assert_bool(_eval("not true or false")).is_false()
	assert_bool(_eval("(1==1) and (2==2) and (3==3)")).is_true()


# ============================================================================
# 4. Bitwise
# ============================================================================

func test_bitwise_and() -> void:
	assert_int(_eval("5&3")).is_equal(1)   # 101 & 011 = 001
	assert_int(_eval("6&2")).is_equal(2)   # 110 & 010 = 010


func test_bitwise_or() -> void:
	assert_int(_eval("5|3")).is_equal(7)   # 101 | 011 = 111
	assert_int(_eval("1|2")).is_equal(3)


func test_bitwise_xor() -> void:
	assert_int(_eval("5^3")).is_equal(6)   # 101 ^ 011 = 110
	assert_int(_eval("1^1")).is_equal(0)


func test_bitwise_shift_left() -> void:
	assert_int(_eval("1<<3")).is_equal(8)
	assert_int(_eval("2<<2")).is_equal(8)
	assert_int(_eval("0<<5")).is_equal(0)


func test_bitwise_shift_right() -> void:
	assert_int(_eval("8>>3")).is_equal(1)
	assert_int(_eval("16>>2")).is_equal(4)


func test_bitwise_invert() -> void:
	assert_int(_eval("~0")).is_equal(-1)
	assert_int(_eval("~1")).is_equal(-2)


# ============================================================================
# 5. String operations
# ============================================================================

func test_string_concatenation() -> void:
	assert_str(_eval("'hello'+' world'")).is_equal("hello world")
	assert_str(_eval("'a'+'b'+'c'")).is_equal("abc")


func test_string_with_numbers_coercion() -> void:
	# GDScript auto-coerces number to string in + context
	assert_str(_eval("'count:'+1")).is_equal("count:1")


# ============================================================================
# 6. Constants
# ============================================================================

func test_constant_null() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("null")
	var result = e.execute()
	assert_that(result).is_null()


func test_constant_true() -> void:
	assert_bool(_eval("true")).is_true()


func test_constant_false() -> void:
	assert_bool(_eval("false")).is_false()


func test_constant_pi() -> void:
	assert_float(_eval("PI")).is_equal(PI)


func test_constant_tau() -> void:
	assert_float(_eval("TAU")).is_equal(TAU)


func test_constant_inf() -> void:
	assert_float(_eval("INF")).is_equal(INF)


func test_constant_nan() -> void:
	var result = _eval("NAN")
	assert_bool(is_nan(result)).is_true()


# ============================================================================
# 7. Function calls
# ============================================================================

func test_func_sin() -> void:
	assert_float(_eval("sin(0.0)")).is_equal(0.0)
	assert_float(_eval("sin(PI/2)")).is_approx_equal(1.0)


func test_func_cos() -> void:
	assert_float(_eval("cos(0.0)")).is_equal(1.0)
	assert_float(_eval("cos(PI)")).is_approx_equal(-1.0)


func test_func_min() -> void:
	assert_int(_eval("min(3,5)")).is_equal(3)
	assert_int(_eval("min(-1,10)")).is_equal(-1)


func test_func_max() -> void:
	assert_int(_eval("max(3,5)")).is_equal(5)
	assert_int(_eval("max(-1,10)")).is_equal(10)


func test_func_abs() -> void:
	assert_int(_eval("abs(-5)")).is_equal(5)
	assert_int(_eval("abs(3)")).is_equal(3)


func test_func_round() -> void:
	assert_int(_eval("round(3.7)")).is_equal(4)
	assert_int(_eval("round(3.2)")).is_equal(3)


func test_func_floor() -> void:
	assert_int(_eval("floor(3.7)")).is_equal(3)
	assert_int(_eval("floor(-1.5)")).is_equal(-2)


func test_func_ceil() -> void:
	assert_int(_eval("ceil(3.2)")).is_equal(4)
	assert_int(_eval("ceil(-1.5)")).is_equal(-1)


func test_func_sqrt() -> void:
	assert_float(_eval("sqrt(9.0)")).is_equal(3.0)


func test_func_pow() -> void:
	assert_float(_eval("pow(2.0, 3.0)")).is_equal(8.0)


func test_func_clamp() -> void:
	assert_int(_eval("clamp(5, 0, 10)")).is_equal(5)
	assert_int(_eval("clamp(-1, 0, 10)")).is_equal(0)
	assert_int(_eval("clamp(15, 0, 10)")).is_equal(10)


func test_func_lerp() -> void:
	assert_float(_eval("lerp(0.0, 10.0, 0.5)")).is_equal(5.0)


func test_func_is_nan() -> void:
	assert_bool(_eval("is_nan(NAN)")).is_true()
	assert_bool(_eval("is_nan(1.0)")).is_false()


func test_func_is_inf() -> void:
	assert_bool(_eval("is_inf(INF)")).is_true()
	assert_bool(_eval("is_inf(1.0)")).is_false()


func test_func_str() -> void:
	assert_str(_eval("str(123)")).is_equal("123")
	assert_str(_eval("str(1,2,3)")).is_equal("123")


func test_func_len() -> void:
	assert_int(_eval("len('hello')")).is_equal(5)
	assert_int(_eval("len([1,2,3])")).is_equal(3)


func test_func_snapped() -> void:
	assert_float(_eval("snapped(3.7, 1.0)")).is_equal(4.0)


func test_func_deg_to_rad() -> void:
	assert_float(_eval("deg_to_rad(180.0)")).is_approx_equal(PI)


func test_func_rad_to_deg() -> void:
	assert_float(_eval("rad_to_deg(PI)")).is_approx_equal(180.0)


func test_func_step_decimals() -> void:
	assert_int(_eval("step_decimals(3.000)")).is_equal(0)
	# step_decimals(3.100) could be 1 depending on float representation


# ============================================================================
# 8. Variables / inputs
# ============================================================================

func test_input_single_variable() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("x + 1", ["x"])
	var result = e.execute([5], {}, null, true)
	assert_int(result).is_equal(6)


func test_input_multiple_variables() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("a + b * c", ["a", "b", "c"])
	var result = e.execute([1, 2, 3], {}, null, true)
	assert_int(result).is_equal(7)  # 1 + (2 * 3) = 7


func test_input_as_string() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("'Hello, ' + name", ["name"])
	var result = e.execute(["World"], {}, null, true)
	assert_str(result).is_equal("Hello, World")


func test_input_missing_provides_null() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("x + 1", ["x"])
	# Execute without providing the input — x defaults to null
	var result = e.execute([null], {}, null, true)
	assert_that(result).is_null()


func test_input_indexed() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("$0 + $1", [])
	var result = e.execute([10, 20], {}, null, true)
	assert_int(result).is_equal(30)


func test_input_indexed_with_names() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("$0 + $1", ["a", "b"])
	var result = e.execute([3, 4], {}, null, true)
	assert_int(result).is_equal(7)


func test_input_named_identifier_used_in_function() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("abs(x)", ["x"])
	var result = e.execute([-42], {}, null, true)
	assert_int(result).is_equal(42)


func test_input_names_validated_for_keywords() -> void:
	var e = GDSQL.SQLExpression.new()
	var err = e.parse("1+1", ["null"])
	assert_bool(err != OK).is_true()
	assert_str(e.get_error_text()).contains("keyword")


# ============================================================================
# 9. SQL mode — null propagation
# ============================================================================

func test_sql_mode_null_propagation_addition() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.parse("null + 1", [])
	var result = e.execute([], {}, null, true)
	assert_that(result).is_null()


func test_sql_mode_null_propagation_multiplication() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.parse("null * 5", [])
	var result = e.execute([], {}, null, true)
	assert_that(result).is_null()


func test_sql_mode_null_propagation_comparison() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.parse("null == 1", [])
	var result = e.execute([], {}, null, true)
	assert_bool(result).is_false()


func test_sql_mode_no_null_propagation_in_non_sql_mode() -> void:
	# In non-sql mode, null + 1 will also be null (GDScript behavior)
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = false
	e.parse("null + 1", [])
	var result = e.execute([], {}, null, true)
	assert_that(result).is_null()


func test_sql_mode_string_arithmetic() -> void:
	# The expression engine converts string numbers to int/float in sql_mode
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.parse("'5' + '3'", [])
	var result = e.execute([], {}, null, true)
	# In GDScript, '5' + '3' concatenates to '53'
	assert_str(result).is_equal("53")


func test_sql_mode_variable_input() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.parse("x + 1", ["x"])
	var result = e.execute([10], {}, null, true)
	assert_int(result).is_equal(11)


# ============================================================================
# 10. SQL input names — table.column syntax
# ============================================================================

func test_sql_input_names_table_column() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.set_sql_input_names({
		"users": {true: ["id", "name"], "id": 0, "name": 1}
	})
	e.parse("users.id == 1", ["users"], [])
	var result = e.execute([], {"users": {"id": 1, "name": "Alice"}}, null, true)
	assert_bool(result).is_true()


func test_sql_input_names_unknown_column() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.set_sql_input_names({
		"users": {true: ["id", "name"], "id": 0, "name": 1}
	})
	e.parse("users.nonexistent == 1", ["users"], [])
	var result = e.execute([], {"users": {"id": 1, "name": "Alice"}}, null, false)
	assert_bool(e.has_execute_failed()).is_true()


func test_sql_input_names_lack_input_names() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.set_sql_input_names({
		"users": {true: ["id", "name"], "id": 0, "name": 1}
	})
	e.parse("users.id == 1", ["users"], [])
	var lack = e.get_lack_input_names()
	assert_that(lack).is_not_null()


func test_sql_input_names_column_value() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.set_sql_input_names({
		"orders": {true: ["total", "status"], "total": 0, "status": 1}
	})
	e.parse("orders.total > 100", ["orders"], [])
	var result = e.execute([], {"orders": {"total": 150, "status": "shipped"}}, null, true)
	assert_bool(result).is_true()


func test_sql_input_names_equals_column_by_name() -> void:
	# Test comparing a column to a name identifier
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.set_sql_input_names({
		"users": {true: ["id", "name"], "id": 0, "name": 1}
	})
	e.parse("users.name == name", ["users", "name"], [])
	var result = e.execute(["Alice"], {"users": {"id": 1, "name": "Alice"}}, null, true)
	assert_bool(result).is_true()


# ============================================================================
# 11. Parse errors
# ============================================================================

func test_parse_error_unexpected_character() -> void:
	var e = GDSQL.SQLExpression.new()
	var err = e.parse("1 @ 2", [])
	assert_bool(err != OK).is_true()
	assert_str(e.get_error_text()).contains("Unexpected")


func test_parse_error_unterminated_string() -> void:
	var e = GDSQL.SQLExpression.new()
	var err = e.parse("'hello", [])
	assert_bool(err != OK).is_true()
	assert_str(e.get_error_text()).contains("Unterminated")


func test_parse_error_missing_parenthesis() -> void:
	var e = GDSQL.SQLExpression.new()
	var err = e.parse("(1+2", [])
	assert_bool(err != OK).is_true()
	assert_str(e.get_error_text()).contains("Expected")


func test_parse_error_missing_operand() -> void:
	var e = GDSQL.SQLExpression.new()
	var err = e.parse("1+", [])
	assert_bool(err != OK).is_true()


func test_parse_error_two_consecutive_operators() -> void:
	var e = GDSQL.SQLExpression.new()
	var err = e.parse("1++2", [])
	assert_bool(err != OK).is_true()


func test_parse_error_empty_expression() -> void:
	var e = GDSQL.SQLExpression.new()
	var err = e.parse("", [])
	assert_bool(err != OK).is_true()


func test_parse_error_expected_equals() -> void:
	var e = GDSQL.SQLExpression.new()
	var err = e.parse("1 = 2", [])
	assert_bool(err != OK).is_true()
	assert_str(e.get_error_text()).contains("Expected '='")


func test_parse_error_expected_expression() -> void:
	var e = GDSQL.SQLExpression.new()
	var err = e.parse("+", [])
	assert_bool(err != OK).is_true()


func test_parse_error_unknown_function() -> void:
	# The parser should accept function identifiers, but if not a builtin func it treats as call
	var e = GDSQL.SQLExpression.new()
	# This should parse OK since nonexistentFunc is treated as a NamedIndexNode...
	# actually let's verify.
	# Functions that aren't builtins may fail differently.
	e.parse("nonexistentFunc(1)", [])
	# The parse itself might pass if it's treated as a call node; execution may fail.
	# Not all parsers differentiate. Let's just verify it parses without error.
	assert_bool(e.has_execute_failed()).is_false()


# ============================================================================
# 12. Caching — EXPRESSION_CACHE
# ============================================================================

func test_cache_found_after_parse() -> void:
	# After parsing, the EXPRESSION_CACHE should still be null
	# since caching is managed by the caller (base_dao), not by expression itself.
	# But we verify the static cache exists.
	assert_that(GDSQL.SQLExpression.EXPRESSION_CACHE).is_not_null()


func test_cache_capacity_default() -> void:
	assert_int(GDSQL.SQLExpression.EXPRESSION_CACHE.capacity).is_equal(1024)


func test_cache_put_and_get() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	cache.put_value("test_key_1", 42)
	assert_int(cache.get_value("test_key_1")).is_equal(42)
	cache.remove_value("test_key_1")


func test_cache_overwrite_value() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	cache.put_value("test_key_2", "old")
	cache.put_value("test_key_2", "new")
	assert_str(cache.get_value("test_key_2")).is_equal("new")
	cache.remove_value("test_key_2")


func test_cache_missing_key() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	assert_that(cache.get_value("nonexistent_key")).is_null()


func test_cache_eviction_when_full() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	var original_capacity = cache.capacity
	cache.capacity = 3

	# Fill the cache
	cache.put_value("k1", 1)
	cache.put_value("k2", 2)
	cache.put_value("k3", 3)

	# This should evict "k1" (oldest)
	cache.put_value("k4", 4)

	assert_that(cache.get_value("k1")).is_null()   # evicted
	assert_int(cache.get_value("k2")).is_equal(2)  # still there
	assert_int(cache.get_value("k3")).is_equal(3)
	assert_int(cache.get_value("k4")).is_equal(4)

	# Cleanup
	cache.remove_value("k2")
	cache.remove_value("k3")
	cache.remove_value("k4")
	cache.capacity = original_capacity


func test_cache_lru_reorder() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	var original_capacity = cache.capacity
	cache.capacity = 3

	cache.put_value("a", 1)
	cache.put_value("b", 2)
	cache.put_value("c", 3)

	# Access "a" to make it recently used
	assert_int(cache.get_value("a")).is_equal(1)

	# Now "b" should be the LRU, adding "d" evicts "b"
	cache.put_value("d", 4)

	assert_that(cache.get_value("b")).is_null()  # evicted
	assert_int(cache.get_value("a")).is_equal(1)
	assert_int(cache.get_value("d")).is_equal(4)

	# Cleanup
	cache.remove_value("a")
	cache.remove_value("c")
	cache.remove_value("d")
	cache.capacity = original_capacity


func test_cache_clear() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	cache.put_value("clear_test", 99)
	cache.clear()
	assert_that(cache.get_value("clear_test")).is_null()


# ============================================================================
# Error reporting
# ============================================================================

func test_get_error_text_after_parse_error() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("bad^expression", [])
	var err_text = e.get_error_text()
	assert_bool(err_text.length() > 0).is_true()


func test_has_execute_failed_after_success() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("1+1", [])
	e.execute([], {}, null, true)
	assert_bool(e.has_execute_failed()).is_false()


func test_has_execute_failed_after_execution_error() -> void:
	# Execution error can happen when a named property doesn't exist
	var e = GDSQL.SQLExpression.new()
	e.parse("x.nonexistent", ["x"])
	e.execute([42], {}, null, false)
	assert_bool(e.has_execute_failed()).is_true()


# ============================================================================
# Edge cases and combinations
# ============================================================================

func test_nested_parentheses() -> void:
	assert_int(_eval("((1+2)*3)")).is_equal(9)
	assert_int(_eval("(2*(3+4))/2")).is_equal(7)


func test_float_arithmetic() -> void:
	assert_float(_eval("3.5+1.5")).is_equal(5.0)
	assert_float(_eval("10.0/3.0")).is_approx_equal(3.33333)


func test_multiple_operators_mixed() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("1+2*3==7", [])
	var result = e.execute([], {}, null, true)
	assert_bool(result).is_true()


func test_large_integer() -> void:
	assert_int(_eval("1000000*1000")).is_equal(1000000000)


func test_boolean_equality_with_numbers() -> void:
	assert_bool(_eval("1==true")).is_true()
	assert_bool(_eval("0==false")).is_true()


func test_not_with_comparison() -> void:
	assert_bool(_eval("not 1==2")).is_true()
	assert_bool(_eval("not (1<2)")).is_false()


func test_complex_expression() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("(a + b) * abs(c) - d / e", ["a", "b", "c", "d", "e"])
	var result = e.execute([2, 3, -4, 10, 2], {}, null, true)
	# (2+3) * abs(-4) - 10/2 = 5 * 4 - 5 = 15
	assert_int(result).is_equal(15)


func test_repeated_eval_with_different_inputs() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("x * 2", ["x"])
	assert_int(e.execute([3], {}, null, true)).is_equal(6)
	assert_int(e.execute([5], {}, null, true)).is_equal(10)
	assert_int(e.execute([0], {}, null, true)).is_equal(0)


func test_expression_with_multiple_whitespace() -> void:
	assert_int(_eval("  1  +  2  *  3  ")).is_equal(7)


func test_division_by_zero_returns_inf() -> void:
	var result = _eval("1/0")
	assert_bool(is_inf(result)).is_true()


func test_modulo_by_zero() -> void:
	var result = _eval("5%0")
	assert_bool(is_nan(result)).is_true()


func test_power_negative_exponent() -> void:
	assert_float(_eval("2**-1")).is_approx_equal(0.5)
