class_name GDSQLTableDefinition
extends RefCounted

var name: StringName
var columns: Array[GDSQLColumnDefinition] = []
var primary_key: StringName
var indexes: Array[GDSQLIndexDefinition] = []

