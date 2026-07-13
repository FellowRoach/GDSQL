class_name GDSQLTableId
extends RefCounted

var database_name: StringName
var table_name: StringName

func _init(p_database: StringName = &"", p_table: StringName = &"") -> void:
	database_name = p_database
	table_name = p_table

