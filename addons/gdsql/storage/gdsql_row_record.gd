class_name GDSQLRowRecord
extends RefCounted

var values: Dictionary = {}
func get_value(column: StringName) -> Variant: return values.get(column)
func set_value(column: StringName, value: Variant) -> void: values[column] = value
func has_column(column: StringName) -> bool: return values.has(column)

