class_name GDSQLColumnDefinition
extends RefCounted

var name: StringName
var data_type: Variant.Type = TYPE_NIL
var nullable: bool = true
var unique: bool = false
var auto_increment: bool = false
var default_value: Variant


func _init(
		p_name: StringName = &"",
		p_type: Variant.Type = TYPE_NIL,
		p_nullable: bool = true,
) -> void:
	name = p_name
	data_type = p_type
	nullable = p_nullable
