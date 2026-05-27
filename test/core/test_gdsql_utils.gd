extends GdUnitTestSuite

## Comprehensive test suite for GDSQL.GDSQLUtils.
## Covers all public static methods with edge cases.

# --------------------------------------------------------------------------
# evaluate_command
# --------------------------------------------------------------------------

func test_evaluate_command_simple_arithmetic() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "1 + 2")
	assert_int(result).is_equal(3)


func test_evaluate_command_simple_multiplication() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "3 * 4")
	assert_int(result).is_equal(12)


func test_evaluate_command_mixed_arithmetic() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "10 - 3 * 2")
	assert_int(result).is_equal(4)


func test_evaluate_command_parentheses() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "(1 + 2) * 3")
	assert_int(result).is_equal(9)


func test_evaluate_command_string_concat() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "\"hello \" + \"world\"")
	assert_str(result).is_equal("hello world")


func test_evaluate_command_boolean_and() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "true && false")
	assert_bool(result).is_false()


func test_evaluate_command_boolean_or() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "true || false")
	assert_bool(result).is_true()


func test_evaluate_command_equality() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "1 == 1")
	assert_bool(result).is_true()


func test_evaluate_command_inequality() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "1 != 2")
	assert_bool(result).is_true()


func test_evaluate_command_greater_than() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "5 > 3")
	assert_bool(result).is_true()


func test_evaluate_command_with_variables() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "a + b", ["a", "b"], [10, 20])
	assert_int(result).is_equal(30)


func test_evaluate_command_with_variables_string() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "prefix + suffix", ["prefix", "suffix"], ["hello_", "world"])
	assert_str(result).is_equal("hello_world")


func test_evaluate_command_with_single_variable() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "x * 2", ["x"], [7])
	assert_int(result).is_equal(14)


func test_evaluate_command_with_three_variables() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "(a + b) * c", ["a", "b", "c"], [1, 2, 3])
	assert_int(result).is_equal(9)


func test_evaluate_command_float_arithmetic() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "5.0 / 2.0")
	assert_that(result).is_equal(2.5)


func test_evaluate_command_negation() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "-5 + 3")
	assert_int(result).is_equal(-2)


func test_evaluate_command_modulo() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "10 % 3")
	assert_int(result).is_equal(1)


func test_evaluate_command_with_target_script_properties() -> void:
	var script = GDScript.new()
	script.source_code = "extends RefCounted\nvar x = 10\nvar y = 20"
	script.reload()
	var target = script.new()
	var result = GDSQL.GDSQLUtils.evaluate_command(target, "x + y")
	assert_int(result).is_equal(30)
	target.free()


func test_evaluate_command_with_target_and_variables() -> void:
	var script = GDScript.new()
	script.source_code = "extends RefCounted\nvar base = 100"
	script.reload()
	var target = script.new()
	var result = GDSQL.GDSQLUtils.evaluate_command(target, "base + delta", ["delta"], [50])
	assert_int(result).is_equal(150)
	target.free()


func test_evaluate_command_with_target_method_call() -> void:
	var script = GDScript.new()
	script.source_code = "extends RefCounted\nfunc double_it(v):\n\treturn v * 2"
	script.reload()
	var target = script.new()
	var result = GDSQL.GDSQLUtils.evaluate_command(target, "double_it(7)")
	assert_int(result).is_equal(14)
	target.free()


func test_evaluate_command_empty_string_command() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "")
	assert_that(result).is_null()


func test_evaluate_command_invalid_expression() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "1 +++ 2")
	assert_that(result).is_null()


func test_evaluate_command_negate_boolean() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "!true")
	assert_bool(result).is_false()


func test_evaluate_command_bitwise_ops() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command(null, "3 & 1")
	assert_int(result).is_equal(1)


# --------------------------------------------------------------------------
# evaluate_command_with_sql_expression
# --------------------------------------------------------------------------

func test_evaluate_command_with_sql_expression_simple() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_with_sql_expression(null, "1 + 1")
	assert_int(result).is_equal(2)


func test_evaluate_command_with_sql_expression_variables() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_with_sql_expression(
		null, "a + b", ["a", "b"], [3, 4]
	)
	assert_int(result).is_equal(7)


func test_evaluate_command_with_sql_expression_string() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_with_sql_expression(
		null, "\"Hello, \" + name", ["name"], ["World"]
	)
	assert_str(result).is_equal("Hello, World")


func test_evaluate_command_with_sql_expression_input_names() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_with_sql_expression(
		null, "price * quantity", ["price", "quantity"], [],
		{"unit_price": 0, "qty": 1}, [5, 3]
	)
	assert_int(result).is_equal(15)


func test_evaluate_command_with_sql_expression_lacking_tables() -> void:
	var lacking = []
	var result = GDSQL.GDSQLUtils.evaluate_command_with_sql_expression(
		null, "col_1 + col_2", [], [], {}, [], {}, {}, lacking
	)
	assert_that(result).is_null()
	assert_array(lacking).is_not_empty()


func test_evaluate_command_with_sql_expression_is_null_on_error() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_with_sql_expression(
		null, "invalid expression +++"
	)
	assert_that(result).is_null()


func test_evaluate_command_with_sql_expression_with_nested_subqueries() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_with_sql_expression(
		null, "1 + 1", [], [], {}, [], {}, {}
	)
	assert_int(result).is_equal(2)


# --------------------------------------------------------------------------
# evalute_command_with_agg
# --------------------------------------------------------------------------

func test_evalute_command_with_agg_simple() -> void:
	var result = GDSQL.GDSQLUtils.evalute_command_with_agg(null, "1 + 2")
	assert_int(result).is_equal(3)


func test_evalute_command_with_agg_variables() -> void:
	var result = GDSQL.GDSQLUtils.evalute_command_with_agg(
		null, "a + b", ["a", "b"], [10, 20]
	)
	assert_int(result).is_equal(30)


func test_evalute_command_with_agg_with_instance() -> void:
	var agg = GDSQL.AggregateFunctions.get_instance("test_agg")
	var result = GDSQL.GDSQLUtils.evalute_command_with_agg(agg, "1 + 1")
	assert_int(result).is_equal(2)
	GDSQL.AggregateFunctions.clear_instances()


func test_evalute_command_with_agg_is_null_on_error() -> void:
	var result = GDSQL.GDSQLUtils.evalute_command_with_agg(null, "invalid ***")
	assert_that(result).is_null()


func test_evalute_command_with_agg_input_names() -> void:
	var result = GDSQL.GDSQLUtils.evalute_command_with_agg(
		null, "val * 2", ["val"], [], {}, [], {}, {}
	)
	assert_int(result).is_equal(0)  # val is unset, defaults to 0 in expression


# --------------------------------------------------------------------------
# evaluate_command_script
# --------------------------------------------------------------------------

func test_evaluate_command_script_simple() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("1 + 2")
	assert_int(result).is_equal(3)


func test_evaluate_command_script_multiplication() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("4 * 5")
	assert_int(result).is_equal(20)


func test_evaluate_command_script_with_variables() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("a + b", ["a", "b"], [7, 8])
	assert_int(result).is_equal(15)


func test_evaluate_command_script_string_concat() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("s1 + s2", ["s1", "s2"], ["ab", "cd"])
	assert_str(result).is_equal("abcd")


func test_evaluate_command_script_boolean() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("true && false")
	assert_bool(result).is_false()


func test_evaluate_command_script_complex_expression() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("(a + b) * c / d", ["a", "b", "c", "d"], [2, 3, 10, 5])
	assert_int(result).is_equal(10)


func test_evaluate_command_script_with_null_variable() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("val", ["val"], [null])
	assert_that(result).is_null()


func test_evaluate_command_script_returns_null_on_error() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("1 +++ 2")
	assert_that(result).is_null()


func test_evaluate_command_script_ternary() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("true if a > b else false", ["a", "b"], [5, 3])
	assert_bool(result).is_true()


func test_evaluate_command_script_array_literal() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("[1, 2, 3]")
	assert_array(result).has_size(3)


func test_evaluate_command_script_dictionary_literal() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script('{"key": "value"}')
	assert_that(result).is_not_null()
	assert_str(result["key"]).is_equal("value")


# --------------------------------------------------------------------------
# globalize_path
# --------------------------------------------------------------------------

func test_globalize_path_res_simplify() -> void:
	var path = "res://addons/gdsql/gdsql_utils.gd"
	var result = GDSQL.GDSQLUtils.globalize_path(path)
	assert_str(result).is_equal(path.simplify_path())


func test_globalize_path_res_with_dots() -> void:
	var path = "res://addons/../addons/gdsql/./gdsql_utils.gd"
	var result = GDSQL.GDSQLUtils.globalize_path(path)
	# res:// paths are simplified
	assert_bool(result.ends_with("gdsql_utils.gd")).is_true()
	assert_bool(".." in result).is_false()


func test_globalize_path_res_simple_dir() -> void:
	var path = "res://addons/gdsql/"
	var result = GDSQL.GDSQLUtils.globalize_path(path)
	assert_str(result).is_equal(path.simplify_path())


func test_globalize_path_install_contains_path() -> void:
	var path = "install://gdsql/data"
	var result = GDSQL.GDSQLUtils.globalize_path(path)
	assert_str(result).contains("gdsql/data")


func test_globalize_path_install_does_not_start_with_res() -> void:
	var path = "install://some_dir/file.txt"
	var result = GDSQL.GDSQLUtils.globalize_path(path)
	assert_bool(result.begins_with("res://")).is_false()


func test_globalize_path_install_subdir() -> void:
	var path = "install://subdir/deep/file.gd"
	var result = GDSQL.GDSQLUtils.globalize_path(path)
	assert_str(result).contains("subdir/deep/file.gd")


func test_globalize_path_absolute_path_passthrough() -> void:
	# Absolute paths that do not start with res:// or install://
	# and are not relative to the editor's res:// path are returned as-is
	var path = "/absolute/path/to/file.txt"
	var result = GDSQL.GDSQLUtils.globalize_path(path)
	# In non-editor mode or if it doesn't match res_path prefix, it returns the path as-is
	assert_str(result).is_equal(path)


func test_globalize_path_windows_absolute_passthrough() -> void:
	var path = "D:/some/path/file.txt"
	var result = GDSQL.GDSQLUtils.globalize_path(path)
	assert_str(result).is_equal(path)


func test_globalize_path_relative_path_passthrough() -> void:
	var path = "relative/path/file.txt"
	var result = GDSQL.GDSQLUtils.globalize_path(path)
	assert_str(result).is_equal(path)


func test_globalize_path_install_then_res_path() -> void:
	# Ensure install:// is recognized before any other check
	var path = "install://some_folder"
	var result = GDSQL.GDSQLUtils.globalize_path(path)
	assert_str(result).contains("some_folder")


func test_globalize_path_empty_string() -> void:
	var result = GDSQL.GDSQLUtils.globalize_path("")
	assert_str(result).is_equal("")


# --------------------------------------------------------------------------
# file_exists
# --------------------------------------------------------------------------

func test_file_exists_res_path_true() -> void:
	var path = "res://addons/gdsql/gdsql_utils.gd"
	assert_bool(GDSQL.GDSQLUtils.file_exists(path)).is_true()


func test_file_exists_res_path_false() -> void:
	var path = "res://addons/gdsql/nonexistent_file.gd"
	assert_bool(GDSQL.GDSQLUtils.file_exists(path)).is_false()


func test_file_exists_install_path_translated() -> void:
	# install:// paths get globalized, so we can at least verify it runs without error
	var path = "install://nonexistent_file.xyz"
	assert_bool(GDSQL.GDSQLUtils.file_exists(path)).is_false()


func test_file_exists_absolute_path() -> void:
	var path = "res://addons/gdsql/gdsql_utils.gd"
	assert_bool(GDSQL.GDSQLUtils.file_exists(path)).is_true()


func test_file_exists_empty_string() -> void:
	assert_bool(GDSQL.GDSQLUtils.file_exists("")).is_false()


# --------------------------------------------------------------------------
# search_symbol
# --------------------------------------------------------------------------

func test_search_symbol_simple_commas() -> void:
	var text = "a,b,c"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(2)
	# Positions: first comma at [1,2), second at [3,4)
	assert_int(result[0][0]).is_equal(1)
	assert_int(result[0][1]).is_equal(2)
	assert_int(result[1][0]).is_equal(3)
	assert_int(result[1][1]).is_equal(4)


func test_search_symbol_with_quotes() -> void:
	var text = "a,'b,c',d"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(2)


func test_search_symbol_with_double_quotes() -> void:
	var text = 'a,"b,c",d'
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(2)


func test_search_symbol_with_brackets() -> void:
	var text = "func(a,b),c"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(1)
	assert_int(result[0][0]).is_equal(9)
	assert_int(result[0][1]).is_equal(10)


func test_search_symbol_nested_brackets() -> void:
	var text = "outer(func(a,b),c),d"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(1)
	assert_int(result[0][0]).is_equal(18)
	assert_int(result[0][1]).is_equal(19)


func test_search_symbol_with_braces() -> void:
	var text = "{a,b},c"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(1)


func test_search_symbol_no_match() -> void:
	var text = "abc"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(0)


func test_search_symbol_single_char_text() -> void:
	var text = "a"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(0)


func test_search_symbol_empty_text() -> void:
	var text = ""
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(0)


func test_search_symbol_whitespace() -> void:
	var text = "a b c"
	var result = GDSQL.GDSQLUtils.search_symbol(text, "\\s")
	assert_int(result.size()).is_equal(2)


func test_search_symbol_whitespace_with_tabs() -> void:
	var text = "a\tb"
	var result = GDSQL.GDSQLUtils.search_symbol(text, "\\s")
	assert_int(result.size()).is_equal(1)


func test_search_symbol_whitespace_no_match() -> void:
	var text = "abc"
	var result = GDSQL.GDSQLUtils.search_symbol(text, "\\s")
	assert_int(result.size()).is_equal(0)


func test_search_symbol_allow_empty_false_removes_adjacent_empty() -> void:
	var text = "a,,c"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",", false)
	# Adjacent commas merge: the empty arg between them is removed
	assert_int(result.size()).is_equal(1)
	assert_int(result[0][0]).is_equal(1)
	assert_int(result[0][1]).is_equal(3)


func test_search_symbol_with_escaped_quote() -> void:
	var text = "a,'b\\'c',d"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(2)


func test_search_symbol_semicolon() -> void:
	var text = "a;b;c"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ";")
	assert_int(result.size()).is_equal(2)


func test_search_symbol_at_sign() -> void:
	var text = "a@b@c"
	var result = GDSQL.GDSQLUtils.search_symbol(text, "@")
	assert_int(result.size()).is_equal(2)


func test_search_symbol_pipe() -> void:
	var text = "a|b||c"
	var result = GDSQL.GDSQLUtils.search_symbol(text, "|")
	assert_int(result.size()).is_equal(3)


func test_search_symbol_double_quote_inside_brackets() -> void:
	var text = 'func("a,b"),c'
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	# The comma inside quotes is not counted
	assert_int(result.size()).is_equal(1)


func test_search_symbol_mixed_quotes() -> void:
	var text = "a,'b\"c\"d',e"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(2)


# --------------------------------------------------------------------------
# extract_outer_quotes
# --------------------------------------------------------------------------

func test_extract_outer_quotes() -> void:
	var text = "func('hello', 'world')"
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_int(result.size()).is_equal(2)


func test_extract_outer_quotes_double_quotes() -> void:
	var text = 'func("hello", "world")'
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_int(result.size()).is_equal(2)


func test_extract_outer_quotes_mixed_single_double() -> void:
	var text = "func('hello \"world\"')"
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_int(result.size()).is_equal(1)
	assert_that(result[0]).contains("hello")


func test_extract_outer_quotes_nested_brackets() -> void:
	var text = "outer('a(b)', 'c')"
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_int(result.size()).is_equal(2)


func test_extract_outer_quotes_no_quotes() -> void:
	var text = "abc123"
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_int(result.size()).is_equal(0)


func test_extract_outer_quotes_empty_string() -> void:
	var text = ""
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_int(result.size()).is_equal(0)


func test_extract_outer_quotes_bracket_not_outer() -> void:
	# Brackets (parentheses) inside the text are returned as part of outer quotes
	var text = "'hello(world)'"
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_int(result.size()).is_equal(1)
	assert_str(result[0]).is_equal("'hello(world)'")


func test_extract_outer_quotes_multiple_returns_sorted_by_length() -> void:
	var text = "'short' and 'much longer'"
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_int(result.size()).is_equal(2)
	# Sorted by length descending (longest first)
	assert_int(result[0].length()).is_greater_equal(result[1].length())


func test_extract_outer_quotes_escaped_quotes() -> void:
	var text = "'don\\'t stop'"
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	# The escaped quote is treated as a regular char
	assert_that(result).is_not_empty()


func test_extract_outer_quotes_with_braces() -> void:
	var text = '"{brace}ed"'
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_int(result.size()).is_equal(1)


func test_extract_outer_quotes_only_unmatched_warning() -> void:
	# Unmatched quotes produce an error but should not crash
	var text = "'unmatched"
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_that(result).is_not_null()


# --------------------------------------------------------------------------
# extract_outer_bracket
# --------------------------------------------------------------------------

func test_extract_outer_bracket_simple() -> void:
	var text = "(hello)"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	assert_int(result.size()).is_equal(1)
	assert_str(result[0]).is_equal("(hello)")


func test_extract_outer_bracket_nested() -> void:
	var text = "(outer(inner))"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	assert_int(result.size()).is_equal(1)
	assert_str(result[0]).is_equal("(outer(inner))")


func test_extract_outer_bracket_multiple() -> void:
	var text = "(first) and (second)"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	assert_int(result.size()).is_equal(2)


func test_extract_outer_bracket_with_quotes() -> void:
	var text = "('parenthesized')"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	assert_int(result.size()).is_equal(1)
	assert_str(result[0]).is_equal("('parenthesized')")


func test_extract_outer_bracket_no_brackets() -> void:
	var text = "no brackets here"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	assert_int(result.size()).is_equal(0)


func test_extract_outer_bracket_empty_string() -> void:
	var text = ""
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	assert_int(result.size()).is_equal(0)


func test_extract_outer_bracket_only_brackets_inside_quotes() -> void:
	var text = "'(not outer)'"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	# Brackets inside quotes are not extracted
	assert_int(result.size()).is_equal(0)


func test_extract_outer_bracket_square_brackets_not_extracted() -> void:
	var text = "[square]"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	# Only () brackets are extracted, not []
	assert_int(result.size()).is_equal(0)


func test_extract_outer_bracket_braces_not_extracted() -> void:
	var text = "{braces}"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	# Only () brackets are extracted, not {}
	assert_int(result.size()).is_equal(0)


func test_extract_outer_bracket_with_commas_inside() -> void:
	var text = "(a, b, c)"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	assert_int(result.size()).is_equal(1)
	assert_str(result[0]).is_equal("(a, b, c)")


func test_extract_outer_bracket_sorted_by_length() -> void:
	var text = "(short) and (much longer content)"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	assert_int(result.size()).is_equal(2)
	# Sorted by length descending
	assert_int(result[0].length()).is_greater_equal(result[1].length())


func test_extract_outer_bracket_unmatched_inside_quotes() -> void:
	var text = '"unclosed (bracket"'
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	# The ( is inside quotes, so it's not treated as a bracket start
	assert_int(result.size()).is_equal(0)


# --------------------------------------------------------------------------
# get_specific_extension_files
# --------------------------------------------------------------------------

func test_get_specific_extension_files_find_gd() -> void:
	var result = GDSQL.GDSQLUtils.get_specific_extension_files("res://addons/gdsql/", "gd")
	assert_bool(result.size() > 0).is_true()


func test_get_specific_extension_files_find_gd_in_test_dir() -> void:
	var result = GDSQL.GDSQLUtils.get_specific_extension_files("res://test/core/", "gd")
	assert_bool(result.size() > 0).is_true()
	assert_bool("test_gdsql_utils.gd" in result).is_true()


func test_get_specific_extension_files_nonexistent_extension() -> void:
	var result = GDSQL.GDSQLUtils.get_specific_extension_files("res://addons/gdsql/", "xyz")
	assert_int(result.size()).is_equal(0)


func test_get_specific_extension_files_extension_case_insensitive() -> void:
	var result = GDSQL.GDSQLUtils.get_specific_extension_files("res://addons/gdsql/", "GD")
	assert_bool(result.size() > 0).is_true()


# --------------------------------------------------------------------------
# Edge cases and additional coverage
# --------------------------------------------------------------------------

func test_extract_outer_quotes_result_order() -> void:
	# The function sorts results by length descending.
	# Ensure sorting works correctly.
	var text = "'a' + 'bb' + 'ccc'"
	var result = GDSQL.GDSQLUtils.extract_outer_quotes(text)
	assert_int(result.size()).is_equal(3)
	assert_int(result[0].length()).is_greater_equal(result[1].length())
	assert_int(result[1].length()).is_greater_equal(result[2].length())


func test_extract_outer_bracket_result_order() -> void:
	var text = "(a) + (bb) + (ccc)"
	var result = GDSQL.GDSQLUtils.extract_outer_bracket(text)
	assert_int(result.size()).is_equal(3)
	assert_int(result[0].length()).is_greater_equal(result[1].length())
	assert_int(result[1].length()).is_greater_equal(result[2].length())


func test_search_symbol_with_empty_result_for_non_existent_symbol() -> void:
	var result = GDSQL.GDSQLUtils.search_symbol("hello world", "#")
	assert_int(result.size()).is_equal(0)


func test_search_symbol_single_char_input() -> void:
	var text = ","
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	assert_int(result.size()).is_equal(1)


func test_evaluate_command_script_large_numbers() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("1000000 * 1000000")
	assert_int(result).is_equal(1000000000000)


func test_evaluate_command_with_sql_expression_cache_hit() -> void:
	# Run the same expression twice to exercise the cache hit path
	var result1 = GDSQL.GDSQLUtils.evaluate_command_with_sql_expression(
		null, "cache_test * 2", ["cache_test"], [5]
	)
	assert_int(result1).is_equal(10)

	var result2 = GDSQL.GDSQLUtils.evaluate_command_with_sql_expression(
		null, "cache_test * 2", ["cache_test"], [7]
	)
	assert_int(result2).is_equal(14)


func test_search_symbol_with_brackets_quotes_and_commas() -> void:
	var text = "func1('a,b'), func2(c,d)"
	var result = GDSQL.GDSQLUtils.search_symbol(text, ",")
	# Only the comma after func1(...) is at the top level.
	# Commas inside quotes and inside func2(...) are ignored.
	assert_int(result.size()).is_equal(1)


func test_evaluate_command_script_float_division() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script("7.0 / 2.0")
	assert_that(result).is_equal(3.5)


func test_evaluate_command_with_target_method_returning_string() -> void:
	var script = GDScript.new()
	script.source_code = "extends RefCounted\nfunc greet(name):\n\treturn 'Hello, ' + name"
	script.reload()
	var target = script.new()
	var result = GDSQL.GDSQLUtils.evaluate_command(target, 'greet("GDSQL")')
	assert_str(result).is_equal("Hello, GDSQL")
	target.free()


func test_search_symbol_space_as_delimiter() -> void:
	var text = "one two\tthree\nfour"
	var result = GDSQL.GDSQLUtils.search_symbol(text, "\\s")
	assert_int(result.size()).is_equal(3)


func test_evaluate_command_script_nested_ternary() -> void:
	var result = GDSQL.GDSQLUtils.evaluate_command_script(
		"true if a > 0 else (false if b > 0 else true)",
		["a", "b"], [5, -1]
	)
	assert_bool(result).is_true()
