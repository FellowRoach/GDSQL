class_name GDSQLOperationResult
extends RefCounted

var value: Variant
var diagnostics: Array[GDSQLQueryDiagnostic] = []


func is_successful() -> bool:
	for diagnostic in diagnostics:
		if diagnostic.severity == GDSQLQueryDiagnostic.Severity.ERROR:
			return false
	return true


func add_diagnostic(diagnostic: GDSQLQueryDiagnostic) -> void:
	diagnostics.append(diagnostic)
