class_name GDSQLQueryDiagnostic
extends RefCounted

enum Severity { INFO, WARNING, ERROR }

var code: StringName
var severity: Severity = Severity.ERROR
var message: String = ""
var source_span: GDSQLSourceSpan
var related_object: Variant

