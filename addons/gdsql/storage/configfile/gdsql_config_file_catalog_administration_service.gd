class_name GDSQLConfigFileCatalogAdministrationService
extends GDSQLCatalogAdministrationService

var _path_resolver: GDSQLDatabasePathResolver
var _catalog: GDSQLCatalogService


func _init(
		path_resolver: GDSQLDatabasePathResolver,
		catalog: GDSQLCatalogService,
) -> void:
	_path_resolver = path_resolver
	_catalog = catalog


func create_database(database_name: StringName) -> GDSQLCatalogOperationResult:
	if not _path_resolver.is_valid_name(database_name):
		return _error(
			&"GDSQL_CATALOG_INVALID_DATABASE_NAME",
			"Database name '%s' must be a valid identifier." % database_name,
		)
	var registry_path := _path_resolver.resolve_catalog_path()
	var directory_error := _ensure_directory(registry_path.get_base_dir())
	if directory_error != OK:
		return _error(
			&"GDSQL_CATALOG_DIRECTORY_UNWRITABLE",
			"Could not create catalog directory '%s'." % registry_path.get_base_dir(),
		)
	var registry := ConfigFile.new()
	var load_error := registry.load(registry_path)
	if load_error != OK and load_error != ERR_FILE_NOT_FOUND:
		return _error(
			&"GDSQL_CATALOG_UNREADABLE",
			"Could not read database catalog '%s'." % registry_path,
		)
	if registry.has_section(String(database_name)):
		return _error(
			&"GDSQL_CATALOG_DATABASE_EXISTS",
			"Database '%s' is already registered." % database_name,
		)
	for folder in ["schema", "tables", "mappers", "graphs"]:
		var folder_path := _path_resolver.resolve_database_path(database_name).path_join(folder)
		if _ensure_directory(folder_path) != OK:
			return _error(
				&"GDSQL_CATALOG_DIRECTORY_UNWRITABLE",
				"Could not create database directory '%s'." % folder_path,
			)
	registry.set_value(
		String(database_name),
		"path",
		_path_resolver.resolve_database_path(database_name),
	)
	if registry.save(registry_path) != OK:
		return _error(
			&"GDSQL_CATALOG_SAVE_FAILED",
			"Could not save database catalog '%s'." % registry_path,
		)
	var definition := GDSQLDatabaseDefinition.new()
	definition.name = database_name
	var result := GDSQLCatalogOperationResult.new()
	result.value = definition
	return result


func create_table(
		database_name: StringName,
		table: GDSQLTableDefinition,
) -> GDSQLCatalogOperationResult:
	var validation := _validate_table(database_name, table)
	if not validation.is_successful():
		return validation
	var registry := ConfigFile.new()
	if registry.load(_path_resolver.resolve_catalog_path()) != OK \
			or not registry.has_section(String(database_name)):
		return _error(
			&"GDSQL_CATALOG_UNKNOWN_DATABASE",
			"Database '%s' is not registered." % database_name,
		)
	var schema_path := _path_resolver.resolve_schema_path(database_name, table.name)
	var table_path := _path_resolver.resolve_table_path(database_name, table.name)
	if FileAccess.file_exists(schema_path):
		if not FileAccess.file_exists(table_path) and _stored_schema_matches(database_name, table):
			return _complete_missing_table_storage(database_name, table, table_path)
		return _error(
			&"GDSQL_CATALOG_TABLE_EXISTS",
			"Table '%s.%s' already exists." % [database_name, table.name],
		)
	if FileAccess.file_exists(table_path):
		return _error(
			&"GDSQL_CATALOG_TABLE_STORAGE_EXISTS",
			"Table storage '%s' already exists without a schema." % table_path,
		)
	if _ensure_directory(schema_path.get_base_dir()) != OK:
		return _error(
			&"GDSQL_CATALOG_DIRECTORY_UNWRITABLE",
			"Could not create schema directory '%s'." % schema_path.get_base_dir(),
		)
	if _ensure_directory(table_path.get_base_dir()) != OK:
		return _error(
			&"GDSQL_CATALOG_DIRECTORY_UNWRITABLE",
			"Could not create table directory '%s'." % table_path.get_base_dir(),
		)
	var empty_table := ConfigFile.new()
	if empty_table.save(table_path) != OK:
		return _error(
			&"GDSQL_CATALOG_TABLE_STORAGE_CREATE_FAILED",
			"Could not create table storage '%s'." % table_path,
		)
	var schema := ConfigFile.new()
	schema.set_value("table", "name", String(table.name))
	schema.set_value("table", "primary_key", String(table.primary_key))
	for column in table.columns:
		var section := "column:%s" % column.name
		schema.set_value(section, "type", column.data_type)
		schema.set_value(section, "nullable", column.nullable)
		schema.set_value(section, "unique", column.unique)
		schema.set_value(section, "auto_increment", column.auto_increment)
		if column.default_value != null:
			schema.set_value(section, "default", column.default_value)
	if schema.save(schema_path) != OK:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(table_path))
		return _error(
			&"GDSQL_CATALOG_SCHEMA_SAVE_FAILED",
			"Could not save table schema '%s'." % schema_path,
		)
	table.database_name = database_name
	var result := GDSQLCatalogOperationResult.new()
	result.value = table
	return result


func _complete_missing_table_storage(
		database_name: StringName,
		table: GDSQLTableDefinition,
		table_path: String,
) -> GDSQLCatalogOperationResult:
	if _ensure_directory(table_path.get_base_dir()) != OK:
		return _error(
			&"GDSQL_CATALOG_DIRECTORY_UNWRITABLE",
			"Could not create table directory '%s'." % table_path.get_base_dir(),
		)
	var empty_table := ConfigFile.new()
	if empty_table.save(table_path) != OK:
		return _error(
			&"GDSQL_CATALOG_TABLE_STORAGE_CREATE_FAILED",
			"Could not create table storage '%s'." % table_path,
		)
	table.database_name = database_name
	var result := GDSQLCatalogOperationResult.new()
	result.value = table
	result.add_diagnostic(
		GDSQLQueryDiagnostic.new(
			&"GDSQL_CATALOG_TABLE_STORAGE_COMPLETED",
			"Created missing storage for table '%s.%s'." % [database_name, table.name],
			GDSQLQueryDiagnostic.Severity.INFO,
		),
	)
	return result


func _stored_schema_matches(
		database_name: StringName,
		requested: GDSQLTableDefinition,
) -> bool:
	var stored := _catalog.get_table(database_name, requested.name)
	if stored == null \
			or stored.primary_key != requested.primary_key \
			or stored.columns.size() != requested.columns.size():
		return false
	for requested_column in requested.columns:
		var stored_column := stored.get_column(requested_column.name)
		if stored_column == null \
				or stored_column.data_type != requested_column.data_type \
				or stored_column.nullable != requested_column.nullable \
				or stored_column.unique != requested_column.unique \
				or stored_column.auto_increment != requested_column.auto_increment \
				or stored_column.default_value != requested_column.default_value:
			return false
	return true


func _validate_table(
		database_name: StringName,
		table: GDSQLTableDefinition,
) -> GDSQLCatalogOperationResult:
	if not _path_resolver.is_valid_name(database_name):
		return _error(&"GDSQL_CATALOG_INVALID_DATABASE_NAME", "Invalid database name '%s'." % database_name)
	if table == null or not _path_resolver.is_valid_name(table.name):
		return _error(&"GDSQL_CATALOG_INVALID_TABLE_NAME", "Table name must be a valid identifier.")
	if table.columns.is_empty():
		return _error(&"GDSQL_CATALOG_COLUMNS_REQUIRED", "Table '%s' requires at least one column." % table.name)
	var column_names: Dictionary = { }
	for column in table.columns:
		if column == null or not _path_resolver.is_valid_name(column.name):
			return _error(&"GDSQL_CATALOG_INVALID_COLUMN_NAME", "Every column requires a valid identifier name.")
		if column_names.has(column.name):
			return _error(&"GDSQL_CATALOG_DUPLICATE_COLUMN", "Column '%s' appears more than once." % column.name)
		if column.data_type == TYPE_NIL:
			return _error(&"GDSQL_CATALOG_COLUMN_TYPE_REQUIRED", "Column '%s' requires a Variant type." % column.name)
		column_names[column.name] = true
	if table.primary_key == &"" or not column_names.has(table.primary_key):
		return _error(&"GDSQL_CATALOG_PRIMARY_KEY_REQUIRED", "Table primary key must reference a declared column.")
	var primary_key := table.get_primary_key()
	primary_key.nullable = false
	primary_key.unique = true
	return GDSQLCatalogOperationResult.new()


func _ensure_directory(path: String) -> Error:
	return DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))


func _error(code: StringName, message: String) -> GDSQLCatalogOperationResult:
	var result := GDSQLCatalogOperationResult.new()
	result.add_diagnostic(GDSQLQueryDiagnostic.new(code, message))
	return result
