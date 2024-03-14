extends "res://scripts/IntroManager.gd"

const OptionsManager = preload("res://scripts/OptionsManager.gd")
static var font = load("res://fonts/fake receipt.otf")

var paused = false
var colorRect
var text
var text1
var cursor_visible
var interactionManager
var checking
var optionsManager
var windowed = false

func _ready():
	super._ready()

	AddKey("exit", KEY_ESCAPE)
	AddKey("volume_down", KEY_F2)
	AddKey("volume_up", KEY_F3)
	AddKey("toggle_fullscreen", KEY_F4)

	interactionManager = get_node("/root/main/standalone managers/interaction manager")
	optionsManager = OptionsManager.new()

	colorRect = ColorRect.new()
	colorRect.set_color(Color(0,0,0,0.5))
	colorRect.size = DisplayServer.screen_get_size()
	add_child(colorRect)
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
	if (event.is_action_pressed("exit")):
		if (paused == false):
			paused = true
			interactionManager.enabled = false
			checking = interactionManager.checking
			interactionManager.checking = false			
			AudioServer.set_bus_mute(0,true)
			musicmanager.speaker_music.set_stream_paused(true)
			Engine.time_scale = 0
			colorRect.show()
			cursor.SetCursorImage("point")
			cursor_visible = cursor.cursor_visible
			cursor.SetCursor(true,false)
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
	paused = false
	cursor.SetCursor(cursor_visible,false)
	colorRect.hide()
	Engine.time_scale = 1
	musicmanager.speaker_music.set_stream_paused(false)
	AudioServer.set_bus_mute(0,false)
	interactionManager.checking = checking
	interactionManager.enabled = true

func UpdateVolume():
	text1.text = "PRESS ESC AGAIN TO RESUME\nCLICK ANYWHERE TO QUIT TO MENU\n\nVOLUME: " + str(snapped(optionsManager.setting_volume * 100,5)) + "%"