class_name GDSQLRowRecord
extends RefCounted

var values: Dictionary = { }


func _init(p_values: Dictionary = { }) -> void:
	values = p_values.duplicate(true)


func get_value(column: StringName) -> Variant:
	return values.get(column)


func set_value(column: StringName, value: Variant) -> void:
	values[column] = value


func has_column(column: StringName) -> bool:
	return values.has(column)


func duplicate_record() -> GDSQLRowRecord:
	return GDSQLRowRecord.new(values)
