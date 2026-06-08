@tool
extends CodeEdit

@export var button_run_edit: Button

var in_run_edit = false
var in_run_edit_shortcut_feedback = false

func _ready() -> void:
	syntax_highlighter = _create_sql_highlighter()


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
