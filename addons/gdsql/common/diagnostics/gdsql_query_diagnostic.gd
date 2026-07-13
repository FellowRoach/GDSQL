class_name GDSQLQueryDiagnostic
extends RefCounted

enum Severity { INFO, WARNING, ERROR }

var code: StringName
var severity: Severity = Severity.ERROR
var message: String = ""
var source_span: GDSQLSourceSpan
var related_object: Variant


func _init(
		p_code: StringName = &"",
		p_message: String = "",
		p_severity: Severity = Severity.ERROR,
		p_source_span: GDSQLSourceSpan = null,
		p_related_object: Variant = null,
) -> void:
	code = p_code
	message = p_message
	severity = p_severity
	source_span = p_source_span
	related_object = p_related_object
