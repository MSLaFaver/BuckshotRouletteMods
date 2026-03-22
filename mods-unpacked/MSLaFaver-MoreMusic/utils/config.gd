extends Control

@export var main: Control
@export var extra: Control
@export var button_class_main: ButtonClass
@export var button_class_extra: ButtonClass
@export var button_class_default: ButtonClass
@export var scroll: ScrollContainer
@export var list: VBoxContainer
@export var toggle_blankshell: CheckButton
@export var toggle_seventyk: CheckButton
@export var toggle_truedeath: CheckButton
@export var rounds: Array[Label]
@export var hint: Label

var check_off_texture: ImageTexture
var check_on_texture: ImageTexture
var play_texture: ImageTexture
var pause_texture: ImageTexture

var mod_main
var albums
var speaker_music: AudioStreamPlayer2D
var speaker_press: AudioStreamPlayer2D

var has_multi_toggled = false

var id = "MSLaFaver-MoreMusic"
var id_modmenu = "MSLaFaver-ModMenu"

func _ready():
	var buttons = [button_class_main, button_class_extra, button_class_default]
	for button in buttons:
		button.cursor = get_node("/root/menu/standalone managers/cursor manager")
		button.speaker_press = get_node("/root/menu/speaker_press")
		button.speaker_hover = get_node("/root/menu/speaker_hover")
	
	button_class_main.connect("is_pressed", func():
		extra.visible = false
		main.visible = true
	)
	button_class_extra.connect("is_pressed", func():
		main.visible = false
		extra.visible = true
		if has_multi_toggled:
			hint.modulate.a = 0
	)
	button_class_default.connect("is_pressed", func():
		for track in list.get_children():
			if track.track:
				for i in range(track.rounds.size()):
					var full_name = "%s - %s" % [track.album, track.title.text]
					var default = mod_main.config_defaults.tracks.get(full_name) == [i]
					if track.rounds[i].button_pressed != default:
						track.rounds[i].button_pressed = default
		for toggle in [toggle_blankshell, toggle_seventyk, toggle_truedeath]:
			toggle.button_pressed = false
	)
	
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		if config.data.hint:
			hint.modulate.a = 1
		
		var data = config.data.tracks
	
		mod_main = ModLoader.get_node(id)
		albums = mod_main.albums
		speaker_music = get_node("/root/menu/speaker_music")
		speaker_press = get_node("/root/menu/speaker_press")
		
		var check_off_image = Image.load_from_file("res://mods-unpacked/%s/assets/check-off.png" % id_modmenu)
		check_off_texture = ImageTexture.create_from_image(check_off_image)
		var check_on_image = Image.load_from_file("res://mods-unpacked/%s/assets/check-on.png" % id_modmenu)
		check_on_texture = ImageTexture.create_from_image(check_on_image)
		
		var play_image = Image.load_from_file("res://mods-unpacked/%s/assets/play.png" % id)
		play_texture = ImageTexture.create_from_image(play_image)
		var pause_image = Image.load_from_file("res://mods-unpacked/%s/assets/pause.png" % id)
		pause_texture = ImageTexture.create_from_image(pause_image)
		
		for album in albums:
			var album_node = load("res://mods-unpacked/%s/assets/album.tscn" % id).instantiate()
			var album_title = "%s - %s" % [album.get("composer"), album.get("title")]
			album_node.title.text = album_title
			list.add_child(album_node)
			
			for track in album.get("tracks"):
				var track_node = load("res://mods-unpacked/%s/assets/track.tscn" % id).instantiate()
				var track_title = track.get("title")
				track_node.title.text = track_title
				track_node.album = album_title
				track_node.composer = album.get("composer")
				track_node.config = self
				track_node.speaker_press = speaker_press
				var full_title = [album_title, track_title]
				if mod_main.current_menu_track == full_title:
					track_node.playing = true
				var track_rounds = data.get("%s - %s" % full_title)
				if track_rounds != null and track_rounds is Array:
					for track_round in track_rounds:
						track_node.rounds[track_round].button_pressed = true
				list.add_child(track_node)
		
		toggle_blankshell.button_pressed = config.data.extras.get("blank_shell")
		toggle_seventyk.button_pressed = config.data.extras.get("70k")
		toggle_truedeath.button_pressed = config.data.extras.get("true_death")
	
	toggle_blankshell.toggled.connect(_on_toggled_blankshell)
	toggle_seventyk.toggled.connect(_on_toggled_seventyk)
	toggle_truedeath.toggled.connect(_on_toggled_truedeath)
	
	var toggle_off_image = Image.load_from_file("res://mods-unpacked/%s/assets/toggle-off.png" % id_modmenu)
	var toggle_off_texture = ImageTexture.create_from_image(toggle_off_image)
	var toggle_on_image = Image.load_from_file("res://mods-unpacked/%s/assets/toggle-on.png" % id_modmenu)
	var toggle_on_texture = ImageTexture.create_from_image(toggle_on_image)
	
	for toggle in [toggle_blankshell, toggle_seventyk, toggle_truedeath]:
		toggle.add_theme_icon_override("unchecked", toggle_off_texture)
		toggle.add_theme_icon_override("checked", toggle_on_texture)

func _process(delta):
	if has_multi_toggled and hint.modulate.a > 0:
		hint.modulate.a -= delta * 2.0 / 3.0

func play_track(album, track):
	stop_all_tracks(album, track)
	
	if mod_main.menu_original_playing:
		mod_main.menu_playback_position = speaker_music.get_playback_position()
		mod_main.menu_original_playing = false
	
	var file_path
	var file_type
	var loop_begin
	var double
	for album_data in albums:
		if not album_data.get("steam", false) or GlobalVariables.using_steam:
			if "%s - %s" % [album_data.get("composer"), album_data.get("title")] == album:
				for track_data in album_data.get("tracks"):
					if track_data.get("title") == track:
						mod_main.current_menu_track = [album, track]
						if track_data.has("file_name"):
							file_path = "res://mods-unpacked/%s/music/%s" % [id, track_data.get("file_name")]
							loop_begin = track_data.get("loop_begin",0)
							double = track_data.get("double", false)
						else:
							file_path = track_data.get("file_path")
						file_type = track_data.get("file_type")
						break
				break
	
	var stream = load("%s.%s" % [file_path, file_type])
	if file_type == "ogg":
		stream.loop = true
	elif file_type == "wav":
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = loop_begin
		stream.loop_end = stream.data.size() / (4 if double else 8)
	
	speaker_music.stream = stream
	speaker_music.volume_db = 0
	await get_tree().create_timer(0.1, false).timeout
	speaker_music.play()

func stop_track():
	speaker_music.stream = mod_main.menu_stream_original
	await get_tree().create_timer(0.1, false).timeout
	mod_main.lerping = true
	speaker_music.volume_db = linear_to_db(0)
	speaker_music.play()
	speaker_music.seek(mod_main.menu_playback_position)
	mod_main.menu_original_playing = true

func stop_all_tracks(album = null, track = null):
	mod_main.current_menu_track = ["",""]
	for track_node in list.get_children():
		if track_node.playing and not (track_node.album == album and track_node.title.text == track):
			track_node.play_status(false)
			break

func _on_toggled_blankshell(enabled: bool):
	stop_all_tracks()
	speaker_press.play()
	update_config("blank_shell", enabled)
	mod_main.set_blankshell(enabled)

func _on_toggled_seventyk(enabled: bool):
	speaker_press.play()
	update_config("70k", enabled)

func _on_toggled_truedeath(enabled: bool):
	speaker_press.play()
	update_config("true_death", enabled)

func update_config(config_name: String, config_value):
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		config.data.extras[config_name] = config_value
		ModLoaderConfig.update_config(config)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		if main.visible:
			for i in range(rounds.size()):
				if rounds[i].get_global_rect().has_point(get_global_mouse_position()):
					var turn_all_on = false
					for track in list.get_children():
						if track.track:
							if not track.rounds[i].button_pressed:
								turn_all_on = true
								break
					
					for track in list.get_children():
						if track.track:
							if track.rounds[i].button_pressed != turn_all_on:
								track.rounds[i].button_pressed = turn_all_on
					
					hide_hint()
					break

func hide_hint():
	has_multi_toggled = true
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		config.data.hint = false
		ModLoaderConfig.update_config(config)
