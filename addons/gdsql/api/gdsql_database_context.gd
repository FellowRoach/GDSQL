class_name GDSQLDatabaseContext
extends RefCounted

var catalog: GDSQLCatalogService
var storage: GDSQLTableStorage
var validator: GDSQLQueryValidator
var planner: GDSQLQueryPlanner
var executor: GDSQLQueryExecutor
var execution_context: GDSQLExecutionContext


func _init(
		_catalog: GDSQLCatalogService = null,
		_storage: GDSQLTableStorage = null,
		_validator: GDSQLQueryValidator = null,
		_planner: GDSQLQueryPlanner = null,
		_executor: GDSQLQueryExecutor = null,
		_execution_context: GDSQLExecutionContext = null,
) -> void:
	catalog = _catalog
	storage = _storage
	validator = _validator
	planner = _planner
	executor = _executor
	execution_context = _execution_context


func execute(query: GDSQLQuerySpec) -> GDSQLQueryResult:
	var public_result := GDSQLQueryResult.new()
	var validation := validator.validate(query)
	public_result.diagnostics.append_array(validation.diagnostics)
	if not validation.is_valid():
		return public_result
	var planning := planner.create_plan(validation.bound_query)
	public_result.diagnostics.append_array(planning.diagnostics)
	if not planning.is_successful() or planning.plan == null:
		return public_result
	var execution := executor.execute(planning.plan, execution_context)
	public_result.diagnostics.append_array(execution.diagnostics)
	if execution.rows != null:
		public_result.rows = execution.rows.rows.duplicate()
	public_result.statistics = execution.statistics.duplicate()
	return public_result


func prepare(query: GDSQLQuerySpec) -> GDSQLQueryPlanningResult:
	var validation := validator.validate(query)
	if not validation.is_valid():
		var result := GDSQLQueryPlanningResult.new()
		result.diagnostics.append_array(validation.diagnostics)
		return result
	return planner.create_plan(validation.bound_query)
