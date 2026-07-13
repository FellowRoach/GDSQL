class_name GDSQLDefaultQueryValidator
extends GDSQLQueryValidator

var catalog: GDSQLCatalogService


func _init(p_catalog: GDSQLCatalogService = null) -> void:
	catalog = p_catalog


func validate(query: GDSQLQuerySpec) -> GDSQLQueryValidationResult:
	if query is GDSQLInsertQuerySpec:
		return _validate_insert(query as GDSQLInsertQuerySpec)
	return _error(&"GDSQL_VALIDATION_OPERATION_UNSUPPORTED", "Missing implementation")


func _validate_insert(query: GDSQLInsertQuerySpec) -> GDSQLQueryValidationResult:
	if query.target == null:
		return _error(&"GDSQL_VALIDATION_INSERT_TARGET_REQUIRED", "Insert query requires a target table.")
	var table := catalog.get_table(query.target.database_name, query.target.table_name)
	if table == null:
		return _error(
			&"GDSQL_VALIDATION_UNKNOWN_TABLE",
			"Unknown table '%s.%s'." % [query.target.database_name, query.target.table_name],
		)
	if query.columns.is_empty() or query.rows.is_empty():
		return _error(&"GDSQL_VALIDATION_INSERT_VALUES_REQUIRED", "Insert query requires at least one column and row.")
	var seen_columns: Dictionary = { }
	for column_name in query.columns:
		if seen_columns.has(column_name):
			return _error(&"GDSQL_VALIDATION_DUPLICATE_COLUMN", "Column '%s' appears more than once." % column_name)
		seen_columns[column_name] = true
		if not table.has_column(column_name):
			return _error(&"GDSQL_VALIDATION_UNKNOWN_COLUMN", "Unknown column '%s' in table '%s'." % [column_name, table.name])
	for column in table.columns:
		if not column.nullable and column.default_value == null and not column.auto_increment and not seen_columns.has(column.name):
			return _error(&"GDSQL_VALIDATION_REQUIRED_COLUMN", "Required column '%s' is missing." % column.name)
	var bound_operation := GDSQLBoundInsertQuery.new()
	bound_operation.target = table
	for source_row in query.rows:
		if source_row.values.size() != query.columns.size():
			return _error(&"GDSQL_VALIDATION_VALUE_COUNT", "Insert value count does not match the column count.")
		var values: Dictionary = { }
		for index in query.columns.size():
			var column_name := query.columns[index]
			var column := table.get_column(column_name)
			var value: Variant = source_row.values[index]
			if not _is_compatible(value, column):
				return _error(
					&"GDSQL_VALIDATION_TYPE_MISMATCH",
					"Column '%s' expects Variant type %s, received %s." % [column_name, column.data_type, typeof(value)],
				)
			values[column_name] = value
		for column in table.columns:
			if not values.has(column.name) and column.default_value != null:
				values[column.name] = column.default_value
		bound_operation.rows.append(GDSQLRowRecord.new(values))
	var bound_query := GDSQLBoundQuery.new()
	bound_query.source_query = query
	bound_query.root_operation = bound_operation
	bound_query.referenced_tables = [table]
	var result := GDSQLQueryValidationResult.new()
	result.bound_query = bound_query
	result.value = bound_query
	return result


func _is_compatible(value: Variant, column: GDSQLColumnDefinition) -> bool:
	if value == null:
		return column.nullable
	if column.data_type == TYPE_NIL or typeof(value) == column.data_type:
		return true
	return column.data_type == TYPE_FLOAT and typeof(value) == TYPE_INT


func _error(code: StringName, message: String) -> GDSQLQueryValidationResult:
	var result := GDSQLQueryValidationResult.new()
	result.add_diagnostic(GDSQLQueryDiagnostic.new(code, message))
	return result
