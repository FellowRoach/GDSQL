class_name GDSQLDatabase
extends RefCounted

var context: GDSQLDatabaseContext
var database_name: StringName


static func open(database_name: StringName, data_root: String = "res://data") -> GDSQLDatabase:
	return GDSQLDatabase.new(database_name, GDSQLRuntimeFactory.create_default(data_root))


func _init(
		p_database_name: StringName = &"",
		p_context: GDSQLDatabaseContext = null,
) -> void:
	database_name = p_database_name
	context = p_context


func query() -> GDSQLQuery:
	return GDSQLQuery.new(database_name)


func table(table_name: StringName) -> GDSQLQuery:
	return query()


func execute(query_spec: GDSQLQuerySpec) -> GDSQLQueryResult:
	return context.execute(query_spec)


func insert(table_name: StringName, values: Dictionary) -> GDSQLQueryResult:
	var query_spec := query().insert().into_table(table_name).values(values).build()
	return execute(query_spec)


func execute_sql(source: String) -> GDSQLQueryResult:
	var result := GDSQLQueryResult.new()
	result.diagnostics.append(
		GDSQLQueryDiagnostic.new(
			&"GDSQL_SQL_NOT_IMPLEMENTED",
			"SQL execution is not implemented in the Fluent API milestone.",
		),
	)
	return result
