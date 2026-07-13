class_name GDSQLSourceSpan
extends RefCounted

var start: int = 0
var end: int = 0


func _init(p_start: int = 0, p_end: int = 0) -> void:
	start = p_start
	end = p_end
