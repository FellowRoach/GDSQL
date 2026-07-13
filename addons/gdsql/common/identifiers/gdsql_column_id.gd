class_name GDSQLColumnId
extends RefCounted

var table_id: GDSQLTableId
var column_name: StringName


func _init(p_table: GDSQLTableId = null, p_column: StringName = &"") -> void:
	table_id = p_table
	column_name = p_column
