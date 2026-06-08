@tool
extends CodeEdit

@export var button_run_edit: Button

var in_run_edit = false
var in_run_edit_shortcut_feedback = false

const SQL_KEYWORDS: Array[String] = [
	"select", "insert", "update", "delete", "replace",
	"from", "where", "set", "into", "values",
	"join", "left", "right", "inner", "outer", "cross", "on",
	"group", "by", "order", "having", "limit", "offset",
	"union", "all", "distinct", "as", "between", "in", "like",
	"exists", "case", "when", "then", "else", "end",
	"create", "drop", "alter", "table", "database", "index",
	"primary", "foreign", "references", "unique", "default",
	"autoincrement", "not", "null", "if", "cascade", "restrict",
	"add", "column", "rename", "to", "ignore", "duplicate", "key",
	"begin", "commit", "rollback", "transaction", "savepoint",
	"and", "or", "not", "is", "asc", "desc",
	"count", "sum", "avg", "min", "max", "abs", "round",
	"ceil", "floor", "length", "trim", "upper", "lower",
	"substr", "coalesce", "ifnull", "nullif", "cast", "typeof",
	"int", "integer", "float", "real", "double", "decimal",
	"varchar", "char", "text", "blob", "boolean", "bool",
	"date", "datetime", "timestamp",
	"true", "false",
]

var mgr: GDSQL.WorkbenchManagerClass:
	get: return GDSQL.WorkbenchManager

func _ready() -> void:
	syntax_highlighter = _create_sql_highlighter()
	code_completion_enabled = true
	var prefixes = PackedStringArray([".", "_"])
	for c in range(ord("a"), ord("z") + 1):
		prefixes.push_back(char(c))
	for c in range(ord("A"), ord("Z") + 1):
		prefixes.push_back(char(c))
	for c in range(ord("0"), ord("9") + 1):
		prefixes.push_back(char(c))
	code_completion_prefixes = prefixes
	if not code_completion_requested.is_connected(_on_code_completion_requested):
		code_completion_requested.connect(_on_code_completion_requested)
	text_changed.connect(func(): code_completion_requested.emit())
	print("[SQL CodeEdit] _ready done, enabled=", code_completion_enabled, " prefixes=", code_completion_prefixes.size())


## 创建 SQL 语法高亮器
func _create_sql_highlighter() -> CodeHighlighter:
	var h = CodeHighlighter.new()

	# 从编辑器主题获取颜色（带默认回退值）
	var es = EditorInterface.get_editor_settings()
	var keyword_color: Color = es.get_setting("text_editor/theme/highlighting/keyword_color")
	var comment_color: Color = es.get_setting("text_editor/theme/highlighting/comment_color")
	var string_color: Color = es.get_setting("text_editor/theme/highlighting/string_color")
	var number_color: Color = es.get_setting("text_editor/theme/highlighting/number_color")
	var symbol_color: Color = es.get_setting("text_editor/theme/highlighting/symbol_color")
	var function_color: Color = es.get_setting("text_editor/theme/highlighting/function_color")
	var type_color: Color = es.get_setting("text_editor/theme/highlighting/engine_type_color")
	var constant_color: Color = es.get_setting("text_editor/theme/highlighting/comment_color")
	var text_color: Color = es.get_setting("text_editor/theme/highlighting/text_color")

	h.number_color = number_color
	h.symbol_color = symbol_color
	h.function_color = function_color
	h.member_variable_color = text_color

	# 注释区域
	h.add_color_region("--", "", comment_color, true)
	h.add_color_region("#", "", comment_color, true)
	h.add_color_region("/*", "*/", comment_color, false)

	# 字符串（单引号）
	h.add_color_region("'", "'", string_color, false)

	# DML 关键字
	var dml_keywords = [
		"select", "insert", "update", "delete", "replace",
		"from", "where", "set", "into", "values",
		"join", "left", "right", "inner", "outer", "cross", "on",
		"group", "by", "order", "having", "limit", "offset",
		"union", "all", "distinct", "as", "between", "in", "like",
		"exists", "case", "when", "then", "else", "end",
		"ignore", "duplicate", "key",
	]
	for kw in dml_keywords:
		h.add_keyword_color(kw, keyword_color)

	# DDL / 结构关键字
	var ddl_keywords = [
		"create", "drop", "alter", "table", "database", "index",
		"primary", "foreign", "references", "unique", "default",
		"autoincrement", "not", "null", "if", "cascade", "restrict",
		"add", "column", "rename", "to",
	]
	for kw in ddl_keywords:
		h.add_keyword_color(kw, keyword_color)

	# 事务关键字
	var txn_keywords = [
		"begin", "commit", "rollback", "transaction", "savepoint",
	]
	for kw in txn_keywords:
		h.add_keyword_color(kw, keyword_color)

	# 数据类型
	var data_types = [
		"int", "integer", "float", "real", "double", "decimal",
		"varchar", "char", "text", "blob", "boolean", "bool",
		"date", "datetime", "timestamp",
	]
	for kw in data_types:
		h.add_keyword_color(kw, type_color)

	# 内置函数
	var functions = [
		"count", "sum", "avg", "min", "max",
		"abs", "round", "ceil", "floor",
		"length", "trim", "upper", "lower", "substr", "replace",
		"coalesce", "ifnull", "nullif",
		"cast", "typeof", "list",
	]
	for kw in functions:
		h.add_keyword_color(kw, function_color)

	# 常量
	var constants = ["true", "false", "null"]
	for kw in constants:
		h.add_keyword_color(kw, constant_color)

	# 逻辑运算符
	var operators = ["and", "or", "not", "is", "asc", "desc"]
	for kw in operators:
		h.add_keyword_color(kw, keyword_color)

	return h


# ==================== 代码补全 ====================

func _on_code_completion_requested() -> void:
	if _is_cursor_in_string_or_comment():
		cancel_code_completion()
		return

	var line_idx = get_caret_line(0)
	var col = get_caret_column(0)
	var before: String = get_line(line_idx).substr(0, col)
	var word = _get_word_before_cursor(before)
	print("[SQL CodeEdit] before='", before, "' word='", word, "'")

	# 检查 "xxx." 模式（数据库名或表名后跟点号）
	var prefix_parts = before.strip_edges().rsplit(".", true, 1)
	if before.ends_with(".") and prefix_parts.size() >= 2:
		var db_prefix = prefix_parts[0].get_slice(" ", prefix_parts[0].get_slice_count(" ") - 1).strip_edges()
		if _add_table_completions(db_prefix, ""):
			update_code_completion_options(true)
			return
	elif prefix_parts.size() >= 2:
		var db_prefix = prefix_parts[0].get_slice(" ", prefix_parts[0].get_slice_count(" ") - 1).strip_edges()
		if _add_table_completions(db_prefix, word):
			update_code_completion_options(true)
			return

	# 通用候选词
	if word.length() < 2:
		cancel_code_completion()
		return

	var all_candidates: Array[Dictionary] = []

	# SQL 关键字
	for kw in SQL_KEYWORDS:
		all_candidates.push_back({"text": kw, "type": "keyword"})

	# 数据库名
	if mgr and mgr.databases:
		for db_name in mgr.databases:
			all_candidates.push_back({"text": db_name, "type": "database"})
			var display_name = mgr.databases[db_name].get("display_name", "")
			if display_name != "" and display_name != db_name:
				all_candidates.push_back({"text": display_name, "type": "database"})

		# 所有表名
		for db_name in mgr.databases:
			for table_name in mgr.databases[db_name].get("tables", {}):
				all_candidates.push_back({"text": table_name, "type": "table"})

		# 当前SQL中FROM/JOIN后引用的表的字段名
		var referenced_tables = _extract_referenced_tables(before)
		for t_name in referenced_tables:
			for db_name in mgr.databases:
				var tables = mgr.databases[db_name].get("tables", {})
				if tables.has(t_name):
					for column in tables[t_name].get("columns", []):
						all_candidates.push_back({"text": column["Column Name"], "type": "column"})

	var matches = _filter_and_sort(all_candidates, word)
	print("[SQL CodeEdit] candidates=", all_candidates.size(), " matches=", matches.size())
	if matches.is_empty():
		cancel_code_completion()
		return

	for m in matches:
		add_code_completion_option(
			0, m["text"], m["text"],
			_get_completion_color(m["type"])
		)
	update_code_completion_options(true)
	print("[SQL CodeEdit] update_code_completion_options called")


## 尝试添加表名补全（xxx. 之后）。成功返回 true。
func _add_table_completions(db_prefix: String, word_filter: String) -> bool:
	if not (mgr and mgr.databases):
		return false
	var databases = mgr.databases

	# 精确匹配数据库名
	if databases.has(db_prefix):
		var tables: Dictionary = databases[db_prefix].get("tables", {})
		var candidates: Array[Dictionary] = []
		for t_name in tables:
			candidates.push_back({"text": t_name, "type": "table"})
		var matches = _filter_and_sort(candidates, word_filter) if word_filter != "" else candidates
		for m in matches:
			add_code_completion_option(0, m["text"], m["text"],
				_get_completion_color("table"))
		return true

	# 尝试作为表名，补全列名
	for db_name in databases:
		var tables: Dictionary = databases[db_name].get("tables", {})
		if tables.has(db_prefix):
			var cols = tables[db_prefix].get("columns", [])
			var candidates: Array[Dictionary] = []
			for col in cols:
				candidates.push_back({"text": col["Column Name"], "type": "column"})
			var matches = _filter_and_sort(candidates, word_filter) if word_filter != "" else candidates
			for m in matches:
				add_code_completion_option(0, m["text"], m["text"],
					_get_completion_color("column"))
			return true

	return false


## 从SQL文本中提取 FROM / JOIN 后面引用的表名
func _extract_referenced_tables(sql_text: String) -> Array[String]:
	var tables: Array[String] = []
	var re = RegEx.new()
	re.compile(r"(?i)(?:from|join)\s+([a-zA-Z_][a-zA-Z0-9_]*)(?:\.([a-zA-Z_][a-zA-Z0-9_]*))?")
	for m in re.search_all(sql_text):
		if m.get_group_count() >= 2 and m.get_string(2) != "":
			tables.push_back(m.get_string(2))  # table部分
		elif m.get_group_count() >= 1:
			tables.push_back(m.get_string(1))  # 可能是db或table
	return tables


## 获取光标前的单词（标识符）
func _get_word_before_cursor(before: String) -> String:
	var i = before.length() - 1
	while i >= 0:
		var ch = before[i]
		if ch.is_valid_int() or ch.to_lower() != ch.to_upper() or ch == "_":
			i -= 1
		else:
			break
	return before.substr(i + 1)


## 模糊匹配过滤并排序候选词
func _filter_and_sort(candidates: Array[Dictionary], prefix: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var prefix_lower = prefix.to_lower()
	for c in candidates:
		var score = _fuzzy_match_score(c["text"], prefix_lower)
		if score > 0:
			var entry = c.duplicate()
			entry["score"] = score
			result.push_back(entry)
	result.sort_custom(func(a, b):
		if a["score"] != b["score"]:
			return a["score"] > b["score"]
		return a["text"].to_lower() < b["text"].to_lower()
	)
	return result


## 计算模糊匹配得分，0 表示不匹配
func _fuzzy_match_score(candidate: String, prefix_lower: String) -> int:
	var lower = candidate.to_lower()

	# 完全匹配
	if lower == prefix_lower:
		return 1000

	# 前缀匹配
	if lower.begins_with(prefix_lower):
		return 500 + (100 - candidate.length())

	# 子序列匹配（如 "slt" 匹配 "select"）
	var pi = 0
	for ci in range(lower.length()):
		if pi < prefix_lower.length() and lower[ci] == prefix_lower[pi]:
			pi += 1
	if pi >= prefix_lower.length():
		return 100 + int(_similarity_ratio(lower, prefix_lower) * 50)

	# 包含匹配
	if lower.contains(prefix_lower):
		return 200

	return 0


## 计算两个字符串的相似度 (0.0 ~ 1.0)
func _similarity_ratio(a: String, b: String) -> float:
	if a.is_empty() and b.is_empty():
		return 1.0
	var max_len = maxi(a.length(), b.length())
	if max_len == 0:
		return 1.0
	var matches = 0
	var min_len = mini(a.length(), b.length())
	for i in range(min_len):
		if a[i] == b[i]:
			matches += 1
	return float(matches) / float(max_len)


## 检测光标是否在字符串或注释内
func _is_cursor_in_string_or_comment() -> bool:
	var line_text = get_line(get_caret_line(0))
	var col = get_caret_column(0)
	var in_sq = false
	var in_dq = false
	var in_block_comment = false
	var i = 0
	while i < col and i < line_text.length():
		var ch = line_text[i]
		if in_block_comment:
			if ch == "*" and i + 1 < line_text.length() and line_text[i + 1] == "/":
				in_block_comment = false
				i += 1
		elif in_sq:
			if ch == "'":
				in_sq = false
		elif in_dq:
			if ch == '"':
				in_dq = false
		else:
			if ch == "-" and i + 1 < line_text.length() and line_text[i + 1] == "-":
				return true
			if ch == "#":
				return true
			if ch == "/" and i + 1 < line_text.length() and line_text[i + 1] == "*":
				in_block_comment = true
				i += 1
			elif ch == "'":
				in_sq = true
			elif ch == '"':
				in_dq = true
		i += 1
	return in_sq or in_dq or in_block_comment


## 获取补全项的颜色
func _get_completion_color(type: String) -> Color:
	var es = EditorInterface.get_editor_settings()
	match type:
		"keyword":
			return es.get_setting("text_editor/theme/highlighting/keyword_color")
		"database":
			return es.get_setting("text_editor/theme/highlighting/engine_type_color")
		"table":
			return es.get_setting("text_editor/theme/highlighting/function_color")
		"column":
			return es.get_setting("text_editor/theme/highlighting/text_color")
	return Color.WHITE

func _can_drop_data(_position, data):
	# { "type": "files", "files": ["res://src/dao/t_hero.gdmappergraph"], "from": @Tree@6840:<Tree#603409380691> }
	if data is Dictionary:
		if data.has("type") and data.has("files") and data.get("type") == "files":
			for i in data.get("files"):
				if i is String:
					if i.ends_with(".gdsqltext") or i.ends_with(".gdsqlgraph") or i.ends_with(".gdmappergraph"):
						return true
	return false
	
func _drop_data(_position, data):
	for i in data.get("files"):
		if i is String:
			if i.ends_with(".gdsqltext"):
				GDSQL.WorkbenchManager.open_sql_text_file_tab.emit(i)
			elif i.ends_with(".gdsqlgraph"):
				GDSQL.WorkbenchManager.open_sql_graph_file_tab.emit(i)
			elif i.ends_with(".gdmappergraph"):
				GDSQL.WorkbenchManager.open_mapper_graph_file_tab.emit(i)
				
func _gui_input(event: InputEvent) -> void:
	if in_run_edit_shortcut_feedback:
		if event is InputEventKey:
			accept_event()
		return
	if button_run_edit.shortcut.matches_event(event):
		in_run_edit = true
		if event.is_released():
			in_run_edit = false
			_button_run_edit_pressed()
		accept_event()
		return
	elif in_run_edit:
		in_run_edit = false
		_button_run_edit_pressed()
		accept_event()
		return
		
func _button_run_edit_pressed():
	button_run_edit.pressed.emit()
	var normal_sb = button_run_edit.get_theme_stylebox("normal")
	var hover_pressed_sb = button_run_edit.get_theme_stylebox("hover_pressed")
	button_run_edit.add_theme_stylebox_override("normal", hover_pressed_sb)
	in_run_edit_shortcut_feedback = true
	await get_tree().create_timer(ProjectSettings.get_setting("gui/timers/button_shortcut_feedback_highlight_time", 0.2)).timeout
	in_run_edit_shortcut_feedback = false
	if button_run_edit:
		button_run_edit.add_theme_stylebox_override("normal", normal_sb)
