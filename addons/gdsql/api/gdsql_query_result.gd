class_name GDSQLQueryResult
extends RefCounted

var rows: Array[GDSQLRowRecord] = []
var diagnostics: Array[GDSQLQueryDiagnostic] = []

func is_successful() -> bool:
	for diagnostic in diagnostics:
		if diagnostic.severity == GDSQLQueryDiagnostic.Severity.ERROR: return false
	return true

