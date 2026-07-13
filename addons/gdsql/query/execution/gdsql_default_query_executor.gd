class_name GDSQLDefaultQueryExecutor
extends GDSQLQueryExecutor

func execute(plan: GDSQLQueryPlan, context: GDSQLExecutionContext) -> GDSQLQueryExecutionResult:
	var result := GDSQLQueryExecutionResult.new()
	result.rows = GDSQLRowSet.new()
	if plan == null or not plan.root is GDSQLInsertPlan:
		result.add_diagnostic(
			GDSQLQueryDiagnostic.new(
				&"GDSQL_EXECUTION_PLAN_UNSUPPORTED",
				"Only insert plans are supported by the first executor.",
			),
		)
		return result
	if context.cancellation != null and context.cancellation.is_cancelled():
		result.add_diagnostic(
			GDSQLQueryDiagnostic.new(
				&"GDSQL_EXECUTION_CANCELLED",
				"Query execution was cancelled.",
			),
		)
		return result
	var insert_plan := plan.root as GDSQLInsertPlan
	var session := context.transactions.begin()
	for row in insert_plan.rows:
		var stage_result := context.storage.stage_insert(insert_plan.target, row, session)
		result.diagnostics.append_array(stage_result.diagnostics)
		if not stage_result.is_successful():
			context.transactions.rollback(session)
			return result
	var commit_result := context.transactions.commit(session)
	result.diagnostics.append_array(commit_result.diagnostics)
	if not commit_result.is_successful():
		context.transactions.rollback(session)
		return result
	result.rows.rows = insert_plan.rows.duplicate()
	result.statistics = { "affected_rows": insert_plan.rows.size() }
	result.value = result.rows
	return result
