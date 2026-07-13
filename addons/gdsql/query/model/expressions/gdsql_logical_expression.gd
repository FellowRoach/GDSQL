class_name GDSQLLogicalExpression
extends GDSQLQueryExpression

enum LogicalOperator { AND, OR, NOT }

var left: GDSQLQueryExpression
var operator: LogicalOperator
var right: GDSQLQueryExpression


func accept(visitor: GDSQLExpressionVisitor) -> Variant:
	return visitor.visit_logical(self)
