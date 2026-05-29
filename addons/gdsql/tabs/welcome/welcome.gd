@tool
extends PanelContainer

@onready var center_container: CenterContainer = %CenterContainer
@onready var content: VBoxContainer = %Content
@onready var random_tip_label: RichTextLabel = %RandomTipLabel
@onready var version: Button = %Version
@onready var settings_button: Button = %SettingsButton

var _version: String
var _updater: AcceptDialog

func _ready() -> void:
	var plugin_cfg := ConfigFile.new()
	plugin_cfg.load("res://addons/gdsql/plugin.cfg")
	_version = "v" + plugin_cfg.get_value('plugin', 'version', 'unknown version')
	version.text = _version
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)


func _on_update_button_pressed() -> void:
	if _updater:
		_updater.queue_free()
	_updater = preload("res://addons/gdsql/tabs/plugin_updater/updater.gd").new()
	add_child(_updater)
	_updater.popup_centered()


func _on_license_button_pressed() -> void:
	if GDSQL.WorkbenchManager:
		GDSQL.WorkbenchManager.open_license_tab.emit()


func _on_random_tip_label_resized() -> void:
	if content:
		content.set_deferred(&"size", Vector2(content.size.x, 0))


func _on_settings_button_pressed() -> void:
	if GDSQL.WorkbenchManager:
		GDSQL.WorkbenchManager.open_settings_tab.emit()


func _on_version_mouse_entered() -> void:
	version.flat = false
	version.text = tr("Check updates")


func _on_version_mouse_exited() -> void:
	version.flat = true
	version.text = _version
