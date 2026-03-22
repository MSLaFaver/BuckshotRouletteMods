extends VBoxContainer

@export var title: Label
@export var version: Label
@export var update: LinkButton
@export var toggle: CheckButton
@export var author: Label
@export var hyphen: Label
@export var config: LinkButton
@export var description: Label

var active: bool
var mod_namespace: String
var id: String
var config_scene: PackedScene
var speaker_hover: AudioStreamPlayer2D
var speaker_press: AudioStreamPlayer2D
var mods: Control
var cursor: CursorManager

func _ready():
	toggle.toggled.connect(_on_toggled)
	config.pressed.connect(_on_config_pressed)
	update.pressed.connect(_on_update_pressed)
	id = "%s-%s" % [mod_namespace, title.text]
	
	var config_path = "res://mods-unpacked/%s/config.tscn" % id
	var config_exists = active and FileAccess.file_exists(config_path)
	hyphen.visible = config_exists
	config.visible = config_exists
	if config_exists:
		config_scene = load(config_path)
	
	for link in [config, update]:
		link.focus_entered.connect(_on_hover)
		link.focus_exited.connect(_on_exit)
		link.mouse_entered.connect(_on_hover)
		link.mouse_exited.connect(_on_exit)
	
	toggle.add_theme_icon_override("unchecked", mods.toggle_off_texture)
	toggle.add_theme_icon_override("unchecked_disabled", mods.toggle_off_texture)
	toggle.add_theme_icon_override("checked", mods.toggle_on_texture)
	toggle.add_theme_icon_override("checked_disabled", mods.toggle_on_texture)

func _on_toggled(enabled: bool):
	speaker_press.play()
	mods.mod_status_changed[id] = enabled
	if enabled:
		ModLoaderUserProfile.enable_mod(id)
	else:
		ModLoaderUserProfile.disable_mod(id)

func _on_config_pressed():
	speaker_press.play()
	mods.in_config = true
	mods.scroll_container.visible = false
	mods.parent_folder.visible = false
	mods.label_mods.text = tr("MODMENU_CONFIG TITLE") % [title.text, version.text]
	mods.config.add_child(config_scene.instantiate())
	cursor.SetCursorImage("point")

func _on_update_pressed():
	speaker_press.play()

func _on_hover():
	speaker_hover.pitch_scale = randf_range(.95, 1.0)
	speaker_hover.play()
	cursor.SetCursorImage("hover")

func _on_exit():
	cursor.SetCursorImage("point")
