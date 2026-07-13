class_name GDSQLSelectQueryBuilder
extends RefCounted

var _built: bool = false
var _source: GDSQLQuerySource
var _projections: Array[GDSQLQueryExpression] = []
var _predicate: GDSQLQueryExpression
var _ordering: Array[GDSQLOrderClause] = []
var _limit: int = -1

func from_table(source: GDSQLQuerySource) -> GDSQLSelectQueryBuilder: return self
func where(expression: GDSQLQueryExpression) -> GDSQLSelectQueryBuilder: return self
func join(join_spec: GDSQLJoinSpec) -> GDSQLSelectQueryBuilder: return self
func order_by(clause: GDSQLOrderClause) -> GDSQLSelectQueryBuilder: return self
func limit(value: int) -> GDSQLSelectQueryBuilder: return self
func build() -> GDSQLSelectQuerySpec: return null

