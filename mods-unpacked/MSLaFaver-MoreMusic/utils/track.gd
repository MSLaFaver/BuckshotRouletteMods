extends HBoxContainer

@export var waves_parent: HBoxContainer
@export var waves: Array[ColorRect]
@export var title_parent: Control
@export var title: Label
@export var play: CheckBox
@export var rounds: Array[CheckBox]

const track = true

const id = "MSLaFaver-MoreMusic"

var album
var composer
var config: Control
var speaker_press: AudioStreamPlayer2D
var playing = false
var hovered = false

const min_height = 4
const max_height = 45

var wave_data = []

func _ready():
	for i in range(3):
		rounds[i].add_theme_icon_override("unchecked", config.check_off_texture)
		rounds[i].add_theme_icon_override("checked", config.check_on_texture)
		rounds[i].toggled.connect(func(enabled: bool): _on_check_round(i, enabled))
	
	play.add_theme_icon_override("unchecked", config.play_texture)
	play.add_theme_icon_override("checked", config.pause_texture)
	
	title.size.x = 0	# label will automatically resize
	title_parent.custom_minimum_size.x = title.size.x * 0.76
	title.position.x = title_parent.size.x - title.size.x * 0.76
	
	for wave in waves:
		var height = randi_range(min_height,max_height)
		wave.size.y = height
		wave_data.append(height)
	
	play.toggled.connect(_on_play)
	
	play.mouse_entered.connect(func(): hovered = true)
	play.mouse_exited.connect(func(): hovered = false)
	
	play_status(playing)

func _process(_delta):
	if playing:
		for i in range(waves.size()):
			var y = waves[i].size.y
			if wave_data[i] > y:
				waves[i].size.y = min(max_height, y + 1)
			elif wave_data[i] < y:
				waves[i].size.y = max(min_height, y - 1)
			else:
				wave_data[i] = randi_range(min_height,max_height)
	else:
		play.modulate.a = int(hovered)

func _on_play(enabled: bool):
	play_status(enabled)
	speaker_press.play()
	if enabled:
		config.play_track(album, title.text)
	else:
		config.stop_track()

func play_status(status: bool):
	play.set_pressed_no_signal(status)
	playing = status
	waves_parent.visible = status

func _on_check_round(i: float, enabled: bool):
	speaker_press.play()
	var user_config = ModLoaderConfig.get_config(id, "user")
	if user_config != null and user_config.data.has("tracks"):
		var data = user_config.data.tracks.get("%s - %s" % [album, title.text])
		if data != null:
			if enabled and not data.has(i):
				data.append(i)
				data.sort()
			else:
				data.erase(i)
		else:
			data = [i]
		user_config.data.tracks["%s - %s" % [album, title.text]] = data
		ModLoaderConfig.update_config(user_config)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		if config.main.visible and config.scroll.get_global_rect().has_point(get_global_mouse_position()):
			if title.get_global_rect().has_point(get_global_mouse_position()):
				var turn_all_on = false
				for box in rounds:
					if not box.button_pressed:
						turn_all_on = true
						break
				
				for box in rounds:
					if box.button_pressed != turn_all_on:
						box.button_pressed = turn_all_on
				
				config.hide_hint()
