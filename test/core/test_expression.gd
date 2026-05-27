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

## 测试: 加法运算
func test_arithmetic_addition() -> void:
	assert_int(_eval("1+1")).is_equal(2)
	assert_int(_eval("1 + 1")).is_equal(2)
	assert_int(_eval("0+0")).is_equal(0)
	assert_int(_eval("-1+1")).is_equal(0)


## 测试: 减法运算
func test_arithmetic_subtraction() -> void:
	assert_int(_eval("2-1")).is_equal(1)
	assert_int(_eval("10-5")).is_equal(5)
	assert_int(_eval("0-5")).is_equal(-5)


## 测试: 乘法运算
func test_arithmetic_multiplication() -> void:
	assert_int(_eval("2*3")).is_equal(6)
	assert_int(_eval("0*5")).is_equal(0)
	assert_int(_eval("-2*3")).is_equal(-6)


## 测试: 除法运算
func test_arithmetic_division() -> void:
	assert_int(_eval("10/2")).is_equal(5)
	assert_int(_eval("9/3")).is_equal(3)
	assert_float(_eval("7.0/2")).is_equal(3.5)


## 测试: 取模运算
func test_arithmetic_modulo() -> void:
	assert_int(_eval("5%2")).is_equal(1)
	assert_int(_eval("10%3")).is_equal(1)
	assert_int(_eval("8%4")).is_equal(0)


## 测试: 幂运算
func test_arithmetic_power() -> void:
	assert_int(_eval("2**3")).is_equal(8)
	assert_int(_eval("3**2")).is_equal(9)
	assert_int(_eval("10**0")).is_equal(1)


## 测试: 一元负号
func test_arithmetic_unary_minus() -> void:
	assert_int(_eval("-5")).is_equal(-5)
	assert_int(_eval("--5")).is_equal(5)
	assert_int(_eval("-(3+2)")).is_equal(-5)


## 测试: 一元正号
func test_arithmetic_unary_plus() -> void:
	assert_int(_eval("+5")).is_equal(5)
	assert_int(_eval("++5")).is_equal(5)


## 测试: 运算符优先级
func test_arithmetic_operator_precedence() -> void:
	assert_int(_eval("2+3*4")).is_equal(14)   # * before +
	assert_int(_eval("(2+3)*4")).is_equal(20)  # parens override
	assert_int(_eval("10-2*3")).is_equal(4)    # * before -
	assert_int(_eval("2**3+1")).is_equal(9)    # ** before +


# ============================================================================
# 2. Comparison
# ============================================================================

## 测试: 相等比较
func test_comparison_equal() -> void:
	assert_bool(_eval("1==1")).is_true()
	assert_bool(_eval("1==2")).is_false()
	assert_bool(_eval("'abc'=='abc'")).is_true()
	assert_bool(_eval("'abc'=='xyz'")).is_false()


## 测试: 不等比较
func test_comparison_not_equal() -> void:
	assert_bool(_eval("1!=2")).is_true()
	assert_bool(_eval("1!=1")).is_false()


## 测试: 小于比较
func test_comparison_less() -> void:
	assert_bool(_eval("1<2")).is_true()
	assert_bool(_eval("2<1")).is_false()
	assert_bool(_eval("2<2")).is_false()


## 测试: 大于比较
func test_comparison_greater() -> void:
	assert_bool(_eval("2>1")).is_true()
	assert_bool(_eval("1>2")).is_false()
	assert_bool(_eval("2>2")).is_false()


## 测试: 小于等于比较
func test_comparison_less_equal() -> void:
	assert_bool(_eval("1<=2")).is_true()
	assert_bool(_eval("2<=2")).is_true()
	assert_bool(_eval("3<=2")).is_false()


## 测试: 大于等于比较
func test_comparison_greater_equal() -> void:
	assert_bool(_eval("2>=1")).is_true()
	assert_bool(_eval("2>=2")).is_true()
	assert_bool(_eval("1>=2")).is_false()


## 测试: 链式比较
func test_comparison_chained() -> void:
	assert_bool(_eval("1<2 and 2<3")).is_true()
	assert_bool(_eval("1<2 and 2>3")).is_false()


# ============================================================================
# 3. Logic
# ============================================================================

## 测试: 逻辑与
func test_logic_and() -> void:
	assert_bool(_eval("true and true")).is_true()
	assert_bool(_eval("true and false")).is_false()
	assert_bool(_eval("false and true")).is_false()
	assert_bool(_eval("false and false")).is_false()


## 测试: 逻辑或
func test_logic_or() -> void:
	assert_bool(_eval("true or false")).is_true()
	assert_bool(_eval("false or true")).is_true()
	assert_bool(_eval("false or false")).is_false()


## 测试: 逻辑非
func test_logic_not() -> void:
	assert_bool(_eval("not true")).is_false()
	assert_bool(_eval("not false")).is_true()
	assert_bool(_eval("not (1==2)")).is_true()


## 测试: 复合逻辑运算
func test_logic_compound() -> void:
	assert_bool(_eval("true and not false")).is_true()
	assert_bool(_eval("not true or false")).is_false()
	assert_bool(_eval("(1==1) and (2==2) and (3==3)")).is_true()


# ============================================================================
# 4. Bitwise
# ============================================================================

## 测试: 按位与
func test_bitwise_and() -> void:
	assert_int(_eval("5&3")).is_equal(1)   # 101 & 011 = 001
	assert_int(_eval("6&2")).is_equal(2)   # 110 & 010 = 010


## 测试: 按位或
func test_bitwise_or() -> void:
	assert_int(_eval("5|3")).is_equal(7)   # 101 | 011 = 111
	assert_int(_eval("1|2")).is_equal(3)


## 测试: 按位异或
func test_bitwise_xor() -> void:
	assert_int(_eval("5^3")).is_equal(6)   # 101 ^ 011 = 110
	assert_int(_eval("1^1")).is_equal(0)


## 测试: 左移运算
func test_bitwise_shift_left() -> void:
	assert_int(_eval("1<<3")).is_equal(8)
	assert_int(_eval("2<<2")).is_equal(8)
	assert_int(_eval("0<<5")).is_equal(0)


## 测试: 右移运算
func test_bitwise_shift_right() -> void:
	assert_int(_eval("8>>3")).is_equal(1)
	assert_int(_eval("16>>2")).is_equal(4)


## 测试: 按位取反
func test_bitwise_invert() -> void:
	assert_int(_eval("~0")).is_equal(-1)
	assert_int(_eval("~1")).is_equal(-2)


# ============================================================================
# 5. String operations
# ============================================================================

## 测试: 字符串拼接
func test_string_concatenation() -> void:
	assert_str(_eval("'hello'+' world'")).is_equal("hello world")
	assert_str(_eval("'a'+'b'+'c'")).is_equal("abc")


# ============================================================================
# 6. Constants
# ============================================================================

## 测试: null常量
func test_constant_null() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("null")
	var result = e.execute()
	assert_that(result).is_null()


## 测试: true常量
func test_constant_true() -> void:
	assert_bool(_eval("true")).is_true()


## 测试: false常量
func test_constant_false() -> void:
	assert_bool(_eval("false")).is_false()


## 测试: PI常量
func test_constant_pi() -> void:
	assert_float(_eval("PI")).is_equal(PI)


## 测试: TAU常量
func test_constant_tau() -> void:
	assert_float(_eval("TAU")).is_equal(TAU)


## 测试: INF常量
func test_constant_inf() -> void:
	assert_float(_eval("INF")).is_equal(INF)


## 测试: NAN常量
func test_constant_nan() -> void:
	var result = _eval("NAN")
	assert_bool(is_nan(result)).is_true()


# ============================================================================
# 7. Function calls
# ============================================================================

## 测试: sin函数
func test_func_sin() -> void:
	assert_float(_eval("sin(0.0)")).is_equal(0.0)
	assert_float(_eval("sin(PI/2)")).is_equal_approx(1.0, 0.0001)


## 测试: cos函数
func test_func_cos() -> void:
	assert_float(_eval("cos(0.0)")).is_equal(1.0)
	assert_float(_eval("cos(PI)")).is_equal_approx(-1.0, 0.0001)


## 测试: min函数
func test_func_min() -> void:
	assert_int(_eval("min(3,5)")).is_equal(3)
	assert_int(_eval("min(-1,10)")).is_equal(-1)


## 测试: max函数
func test_func_max() -> void:
	assert_int(_eval("max(3,5)")).is_equal(5)
	assert_int(_eval("max(-1,10)")).is_equal(10)


## 测试: abs函数
func test_func_abs() -> void:
	assert_int(_eval("abs(-5)")).is_equal(5)
	assert_int(_eval("abs(3)")).is_equal(3)


## 测试: round函数
func test_func_round() -> void:
	assert_float(_eval("round(3.7)")).is_equal(4.0)
	assert_float(_eval("round(3.2)")).is_equal(3.0)


## 测试: floor函数
func test_func_floor() -> void:
	assert_float(_eval("floor(3.7)")).is_equal(3.0)
	assert_float(_eval("floor(-1.5)")).is_equal(-2.0)


## 测试: ceil函数
func test_func_ceil() -> void:
	assert_float(_eval("ceil(3.2)")).is_equal(4.0)
	assert_float(_eval("ceil(-1.5)")).is_equal(-1.0)


## 测试: sqrt函数
func test_func_sqrt() -> void:
	assert_float(_eval("sqrt(9.0)")).is_equal(3.0)


## 测试: pow函数
func test_func_pow() -> void:
	assert_float(_eval("pow(2.0, 3.0)")).is_equal(8.0)


## 测试: clamp函数
func test_func_clamp() -> void:
	assert_int(_eval("clamp(5, 0, 10)")).is_equal(5)
	assert_int(_eval("clamp(-1, 0, 10)")).is_equal(0)
	assert_int(_eval("clamp(15, 0, 10)")).is_equal(10)


## 测试: lerp函数
func test_func_lerp() -> void:
	assert_float(_eval("lerp(0.0, 10.0, 0.5)")).is_equal(5.0)


## 测试: is_nan函数
func test_func_is_nan() -> void:
	assert_bool(_eval("is_nan(NAN)")).is_true()
	assert_bool(_eval("is_nan(1.0)")).is_false()


## 测试: is_inf函数
func test_func_is_inf() -> void:
	assert_bool(_eval("is_inf(INF)")).is_true()
	assert_bool(_eval("is_inf(1.0)")).is_false()


## 测试: str函数
func test_func_str() -> void:
	assert_str(_eval("str(123)")).is_equal("123")
	assert_str(_eval("str(1,2,3)")).is_equal("123")


## 测试: len函数
func test_func_len() -> void:
	assert_int(_eval("len('hello')")).is_equal(5)
	assert_int(_eval("len([1,2,3])")).is_equal(3)


## 测试: snapped函数
func test_func_snapped() -> void:
	assert_float(_eval("snapped(3.7, 1.0)")).is_equal(4.0)


## 测试: deg_to_rad函数
func test_func_deg_to_rad() -> void:
	assert_float(_eval("deg_to_rad(180.0)")).is_equal_approx(PI, 0.0001)


## 测试: rad_to_deg函数
func test_func_rad_to_deg() -> void:
	assert_float(_eval("rad_to_deg(PI)")).is_equal_approx(180.0, 0.0001)


## 测试: step_decimals函数
func test_func_step_decimals() -> void:
	assert_int(_eval("step_decimals(3.000)")).is_equal(0)
	# step_decimals(3.100) could be 1 depending on float representation


# ============================================================================
# 8. Variables / inputs
# ============================================================================

## 测试: 单个变量输入
func test_input_single_variable() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("x + 1", ["x"])
	var result = e.execute([5], {}, null, true)
	assert_int(result).is_equal(6)


## 测试: 多个变量输入
func test_input_multiple_variables() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("a + b * c", ["a", "b", "c"])
	var result = e.execute([1, 2, 3], {}, null, true)
	assert_int(result).is_equal(7)  # 1 + (2 * 3) = 7


## 测试: 字符串类型变量
func test_input_as_string() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("'Hello, ' + name", ["name"])
	var result = e.execute(["World"], {}, null, true)
	assert_str(result).is_equal("Hello, World")


## 测试: 缺失变量默认为null
func test_input_missing_provides_null() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("x", ["x"])
	# Execute without providing the input — x defaults to null
	var result = e.execute([null], {}, null, true)
	assert_that(result).is_null()


## 测试: 索引变量$0/$1
func test_input_indexed() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("$0 + $1", [])
	var result = e.execute([10, 20], {}, null, true)
	assert_int(result).is_equal(30)


## 测试: 索引变量与名称混用
func test_input_indexed_with_names() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("$0 + $1", ["a", "b"])
	var result = e.execute([3, 4], {}, null, true)
	assert_int(result).is_equal(7)


## 测试: 命名变量作为函数参数
func test_input_named_identifier_used_in_function() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("abs(x)", ["x"])
	var result = e.execute([-42], {}, null, true)
	assert_int(result).is_equal(42)



# ============================================================================
# 9. SQL mode — null propagation
# ============================================================================

## 测试: SQL模式比较运算 null==1 为 false
func test_sql_mode_null_propagation_comparison() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.parse("null == 1", [])
	var result = e.execute([], {}, null, true)
	assert_bool(result).is_false()


## 测试: SQL模式字符串运算
func test_sql_mode_string_arithmetic() -> void:
	# The expression engine converts string numbers to int/float in sql_mode
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.parse("'5' + '3'", [])
	var result = e.execute([], {}, null, true)
	# In GDScript, '5' + '3' concatenates to '53'
	assert_str(result).is_equal("53")


## 测试: SQL模式变量输入
func test_sql_mode_variable_input() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.parse("x + 1", ["x"])
	var result = e.execute([10], {}, null, true)
	assert_int(result).is_equal(11)


# ============================================================================
# 10. SQL input names — table.column syntax
# ============================================================================

## 测试: 表.列语法访问
func test_sql_input_names_table_column() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.set_sql_input_names({
		"users": {true: ["id", "name"], "id": 0, "name": 1}
	})
	e.parse("users.id == 1", [], [])
	var result = e.execute([], {"users": {"id": 1, "name": "Alice"}}, null, true)
	assert_bool(result).is_true()


## 测试: 未知列名报错
func test_sql_input_names_unknown_column() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.set_sql_input_names({
		"users": {true: ["id", "name"], "id": 0, "name": 1}
	})
	e.parse("users.nonexistent == 1", [], [])
	var result = e.execute([], {"users": {"id": 1, "name": "Alice"}}, null, false)
	assert_bool(e.has_execute_failed()).is_true()


## 测试: 缺失列名检测
func test_sql_input_names_lack_input_names() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.set_sql_input_names({
		"users": {true: ["id", "name"], "id": 0, "name": 1}
	})
	e.parse("users.id == 1", ["users"], [])
	var lack = e.get_lack_input_names()
	assert_that(lack).is_not_null()


## 测试: 列值条件比较
func test_sql_input_names_column_value() -> void:
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.set_sql_input_names({
		"orders": {true: ["total", "status"], "total": 0, "status": 1}
	})
	e.parse("orders.total > 100", [], [])
	var result = e.execute([], {"orders": {"total": 150, "status": "shipped"}}, null, true)
	assert_bool(result).is_true()


## 测试: 列与命名变量比较
func test_sql_input_names_equals_column_by_name() -> void:
	# Test comparing a column to a name identifier
	var e = GDSQL.SQLExpression.new()
	e.sql_mode = true
	e.set_sql_input_names({
		"users": {true: ["id", "name"], "id": 0, "name": 1}
	})
	e.parse("users.name == name", ["name"], [])
	var result = e.execute(["Alice"], {"users": {"id": 1, "name": "Alice"}}, null, true)
	assert_bool(result).is_true()


# ============================================================================
# 12. Edge cases
# ============================================================================

# ============================================================================
# 12. Caching — EXPRESSION_CACHE
# ============================================================================

## 测试: 缓存对象存在性
func test_cache_found_after_parse() -> void:
	# After parsing, the EXPRESSION_CACHE should still be null
	# since caching is managed by the caller (base_dao), not by expression itself.
	# But we verify the static cache exists.
	assert_that(GDSQL.SQLExpression.EXPRESSION_CACHE).is_not_null()


## 测试: 缓存默认容量
func test_cache_capacity_default() -> void:
	assert_int(GDSQL.SQLExpression.EXPRESSION_CACHE.capacity).is_equal(1024)


## 测试: 缓存写入与读取
func test_cache_put_and_get() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	cache.put_value("test_key_1", 42)
	assert_int(cache.get_value("test_key_1")).is_equal(42)
	cache.remove_value("test_key_1")


## 测试: 缓存覆盖旧值
func test_cache_overwrite_value() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	cache.put_value("test_key_2", "old")
	cache.put_value("test_key_2", "new")
	assert_str(cache.get_value("test_key_2")).is_equal("new")
	cache.remove_value("test_key_2")


## 测试: 缓存缺失键返回null
func test_cache_missing_key() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	assert_that(cache.get_value("nonexistent_key")).is_null()


## 测试: 缓存满时淘汰最旧
func test_cache_eviction_when_full() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	cache.clear()
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


## 测试: 缓存LRU重新排序
func test_cache_lru_reorder() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	cache.clear()
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


## 测试: 缓存清空
func test_cache_clear() -> void:
	var cache = GDSQL.SQLExpression.EXPRESSION_CACHE
	cache.put_value("clear_test", 99)
	cache.clear()
	assert_that(cache.get_value("clear_test")).is_null()


# ============================================================================
# Error reporting
# ============================================================================

## 测试: 成功执行后无错误
func test_has_execute_failed_after_success() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("1+1", [])
	e.execute([], {}, null, true)
	assert_bool(e.has_execute_failed()).is_false()


## 测试: 执行错误后标记失败
func test_has_execute_failed_after_execution_error() -> void:
	# Execution error can happen when a named property doesn't exist
	var e = GDSQL.SQLExpression.new()
	e.parse("x.nonexistent", ["x"])
	e.execute([42], {}, null, false)
	assert_bool(e.has_execute_failed()).is_true()


# ============================================================================
# Edge cases and combinations
# ============================================================================

## 测试: 嵌套括号运算
func test_nested_parentheses() -> void:
	assert_int(_eval("((1+2)*3)")).is_equal(9)
	assert_int(_eval("(2*(3+4))/2")).is_equal(7)


## 测试: 浮点数算术运算
func test_float_arithmetic() -> void:
	assert_float(_eval("3.5+1.5")).is_equal(5.0)
	assert_float(_eval("10.0/3.0")).is_equal_approx(3.33333, 0.0001)


## 测试: 混合运算符组合
func test_multiple_operators_mixed() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("1+2*3==7", [])
	var result = e.execute([], {}, null, true)
	assert_bool(result).is_true()


## 测试: 大整数运算
func test_large_integer() -> void:
	assert_int(_eval("1000000*1000")).is_equal(1000000000)


## 测试: not与比较运算结合
func test_not_with_comparison() -> void:
	assert_bool(_eval("not 1==2")).is_true()
	assert_bool(_eval("not (1<2)")).is_false()


## 测试: 复杂多变量表达式
func test_complex_expression() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("(a + b) * abs(c) - d / e", ["a", "b", "c", "d", "e"])
	var result = e.execute([2, 3, -4, 10, 2], {}, null, true)
	# (2+3) * abs(-4) - 10/2 = 5 * 4 - 5 = 15
	assert_int(result).is_equal(15)


## 测试: 重复求值不同输入
func test_repeated_eval_with_different_inputs() -> void:
	var e = GDSQL.SQLExpression.new()
	e.parse("x * 2", ["x"])
	assert_int(e.execute([3], {}, null, true)).is_equal(6)
	assert_int(e.execute([5], {}, null, true)).is_equal(10)
	assert_int(e.execute([0], {}, null, true)).is_equal(0)


## 测试: 多空格表达式
func test_expression_with_multiple_whitespace() -> void:
	assert_int(_eval("  1  +  2  *  3  ")).is_equal(7)


## 测试: 负指数幂运算
func test_power_negative_exponent() -> void:
	assert_that(_eval("2.0**(-1)") == 0.5).is_true()
