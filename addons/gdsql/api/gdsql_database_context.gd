class_name GDSQLDatabaseContext
extends RefCounted

var catalog: GDSQLCatalogService
var storage: GDSQLTableStorage
var validator: GDSQLQueryValidator
var planner: GDSQLQueryPlanner
var executor: GDSQLQueryExecutor

func execute(query: GDSQLQuerySpec) -> GDSQLQueryResult: return null
func prepare(query: GDSQLQuerySpec) -> GDSQLQueryPlanningResult: return null
