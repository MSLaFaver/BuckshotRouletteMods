extends Node

const AUTHORNAME_MODNAME_DIR := "MSLaFaver-KeyboardShortcuts"
const AUTHORNAME_MODNAME_LOG_NAME := "MSLaFaver-KeyboardShortcuts:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

var ran_main = false

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir()+(AUTHORNAME_MODNAME_DIR)+"/"
	# Add extensions
	install_script_extensions()

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path+"extensions/"
	const extensions = [
		'TimeScaleManager',
		'InteractionManager',
		'SignatureManager'
	]
	for extension in extensions:
		ModLoaderMod.install_script_extension(extensions_dir_path+extension+".gd")

const OptionsManager = preload("res://scripts/OptionsManager.gd")
static var font = load("res://fonts/fake receipt.otf")

var root_child
var paused = false
var colorRect
var text
var text1
var cursor_visible
var introManager
var interactionManager
var checking
var optionsManager
var windowed = false

func _ready():
	AddKey("pause", KEY_ESCAPE)
	AddKey("volume_down", KEY_F2)
	AddKey("volume_up", KEY_F3)
	AddKey("toggle_fullscreen", KEY_F4)

func _process(delta):
	root_child = get_tree().get_root().get_child(2)			
	if (root_child.name == "main"):
		introManager = root_child.get_node("standalone managers/intro manager")
		optionsManager = OptionsManager.new()
		if not introManager.has_node("pause menu"):
			interactionManager = root_child.get_node("standalone managers/interaction manager")

			colorRect = ColorRect.new()
			colorRect.set_color(Color(0,0,0,0.5))
			colorRect.size = DisplayServer.screen_get_size()
			colorRect.name = "pause menu"
			introManager.add_child(colorRect)
			colorRect.hide()
	
			text = Label.new()
			text.scale = Vector2(0.76, 1)
			text.size = Vector2(960, 35)
			text.pivot_offset = Vector2(480, 0)
			text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			text.set("theme_override_colors/font_shadow_color", Color.BLACK)
			text.set("theme_override_fonts/font", font)
	
			text1 = text.duplicate()	

			text.position = Vector2(0, 120)
			text.set("theme_override_font_sizes/font_size", 48)
			text.text = "GAME PAUSED"

			text1.position = Vector2(0, 200)
			text1.set("theme_override_font_sizes/font_size", 22)

			UpdateVolume()	
			colorRect.add_child(text)
			colorRect.add_child(text1)

func _input(event):
	if event is InputEventMouseButton:
		if (paused):
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
			ResetPause()

func _unhandled_input(event):
	if (event.is_action_pressed("pause") and root_child.name == "main"):
		if (paused == false):
			InputMap.action_erase_events("reset")
			paused = true
			interactionManager.enabled = false
			checking = interactionManager.checking
			interactionManager.checking = false			
			AudioServer.set_bus_mute(0,true)
			introManager.musicmanager.speaker_music.set_stream_paused(true)
			Engine.time_scale = 0
			colorRect.show()
			introManager.cursor.SetCursorImage("point")
			cursor_visible = introManager.cursor.cursor_visible
			introManager.cursor.SetCursor(true,false)
		else:
			ResetPause()
	if (event.is_action_pressed("toggle_fullscreen")):
		if (optionsManager.setting_windowed):
			optionsManager.Adjust("fullscreen")
		else:
			optionsManager.Adjust("windowed")
	if (event.is_action_pressed("volume_down")):
		optionsManager.Adjust("decrease")
		UpdateVolume()
	if (event.is_action_pressed("volume_up")):
		optionsManager.Adjust("increase")
		UpdateVolume()

func AddKey(action, keycode):
	var ev = InputEventKey.new()
	ev.keycode = keycode
	InputMap.add_action(action)
	InputMap.action_add_event(action,ev)

func ResetPause():
	optionsManager.SaveSettings()
	introManager.cursor.SetCursor(cursor_visible,false)
	colorRect.hide()
	Engine.time_scale = 1
	introManager.musicmanager.speaker_music.set_stream_paused(false)
	AudioServer.set_bus_mute(0,false)
	interactionManager.checking = checking
	interactionManager.enabled = true
	paused = false
	var ev = InputEventKey.new()
	ev.keycode = KEY_R
	InputMap.action_add_event("reset",ev)

func UpdateVolume():
	text1.text = "PRESS ESC AGAIN TO RESUME\nCLICK ANYWHERE TO QUIT TO MENU\n\nVOLUME: " + str(snapped(optionsManager.setting_volume * 100,5)) + "%"
