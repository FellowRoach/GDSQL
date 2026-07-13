class_name GDSQLTableDefinition
extends RefCounted

var database_name: StringName
var name: StringName
var columns: Array[GDSQLColumnDefinition] = []
var primary_key: StringName
var indexes: Array[GDSQLIndexDefinition] = []


func get_column(column_name: StringName) -> GDSQLColumnDefinition:
	for column in columns:
		if column.name == column_name:
			return column
	return null


func has_column(column_name: StringName) -> bool:
	return get_column(column_name) != null


func get_primary_key() -> GDSQLColumnDefinition:
	return get_column(primary_key)
