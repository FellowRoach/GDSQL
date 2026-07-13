class_name GDSQLDatabase
extends RefCounted

var context: GDSQLDatabaseContext

func query() -> GDSQLQuery: return null
func table(table_name: StringName) -> GDSQLQuery: return null
func execute_sql(source: String) -> GDSQLQueryResult: return null
