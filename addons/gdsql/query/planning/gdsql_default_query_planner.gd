class_name GDSQLDefaultQueryPlanner
extends GDSQLQueryPlanner

func create_plan(query: GDSQLBoundQuery) -> GDSQLQueryPlanningResult:
	var result := GDSQLQueryPlanningResult.new()
	if query == null or not query.root_operation is GDSQLBoundInsertQuery:
		result.add_diagnostic(
			GDSQLQueryDiagnostic.new(
				&"GDSQL_PLANNING_OPERATION_UNSUPPORTED",
				"Only bound insert queries are supported by the first planner. Remove when progressing",
			),
		)
		return result
	var bound_insert := query.root_operation as GDSQLBoundInsertQuery
	var insert_plan := GDSQLInsertPlan.new()
	insert_plan.target = bound_insert.target
	insert_plan.rows = bound_insert.rows.duplicate()
	result.plan = GDSQLQueryPlan.new(insert_plan)
	result.value = result.plan
	return result
