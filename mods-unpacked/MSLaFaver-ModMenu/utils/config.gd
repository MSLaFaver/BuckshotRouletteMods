extends Control

@export var update_toggle: CheckButton
@export var filter_toggle: CheckButton
@export var discord_toggle: CheckButton
@export var burner_toggle: CheckButton
@export var pills_toggle: CheckButton

const id = "MSLaFaver-ModMenu"

var speaker_press: AudioStreamPlayer2D
var update_initial
var mods

func _ready():
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		var data = config.data
		update_toggle.button_pressed = data.get("check_for_updates")
		filter_toggle.button_pressed = data.get("remove_filter")
		discord_toggle.button_pressed = data.get("remove_discord")
		burner_toggle.button_pressed = data.get("burner_fix")
		pills_toggle.button_pressed = data.get("old_pills")
	
	update_initial = update_toggle.button_pressed
	update_toggle.toggled.connect(_on_toggled_update)
	filter_toggle.toggled.connect(_on_toggled_filter)
	discord_toggle.toggled.connect(_on_toggled_discord)
	burner_toggle.toggled.connect(_on_toggled_burner)
	pills_toggle.toggled.connect(_on_toggled_pills)
	
	speaker_press = get_node("/root/menu/speaker_press")
	mods = get_node("/root/menu/Camera/dialogue UI/menu ui/mods")
	
	self.child_exiting_tree.connect(func(_node):
		if not update_initial and update_toggle.button_pressed:
			mods.check_for_updates()
	)
	
	for toggle in [update_toggle, filter_toggle, discord_toggle, burner_toggle, pills_toggle]:
		toggle.add_theme_icon_override("unchecked", mods.toggle_off_texture)
		toggle.add_theme_icon_override("unchecked_disabled", mods.toggle_off_texture)
		toggle.add_theme_icon_override("checked", mods.toggle_on_texture)
		toggle.add_theme_icon_override("checked_disabled", mods.toggle_on_texture)
	
func _on_toggled_update(enabled: bool):
	update_config("check_for_updates", enabled)
	speaker_press.play()

func _on_toggled_filter(enabled: bool):
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS if enabled else Window.CONTENT_SCALE_MODE_VIEWPORT
	update_config("remove_filter", enabled)
	speaker_press.play()
	
func _on_toggled_discord(enabled: bool):
	var main_screen = get_node("/root/menu/Camera/dialogue UI/menu ui/main screen")
	for node in main_screen.find_children("*discord*", "", false):
		node.visible = not enabled
	update_config("remove_discord", enabled)
	speaker_press.play()
	
func _on_toggled_burner(enabled: bool):
	update_config("burner_fix", enabled)
	speaker_press.play()
	
func _on_toggled_pills(enabled: bool):
	update_config("old_pills", enabled)
	speaker_press.play()

func update_config(config_name: String, config_value):
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		config.data[config_name] = config_value
		ModLoaderConfig.update_config(config)
