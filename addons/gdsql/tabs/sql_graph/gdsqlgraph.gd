@icon("res://addons/gdsql/img/GDSQLGraph.svg")
extends Resource
class_name GDSQLGraph

var config: ConfigFile

func load(path: String):
	config = ConfigFile.new()
	config.load(path)
