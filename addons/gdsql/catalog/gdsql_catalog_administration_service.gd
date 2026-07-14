@abstract
class_name GDSQLCatalogAdministrationService
extends RefCounted

@abstract
func create_database(database_name: StringName) -> GDSQLCatalogOperationResult


@abstract
func create_table(
		database_name: StringName,
		table: GDSQLTableDefinition,
) -> GDSQLCatalogOperationResult
