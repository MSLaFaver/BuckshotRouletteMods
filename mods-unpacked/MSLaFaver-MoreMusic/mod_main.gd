extends Node

const albums = [
	{
		"title": "OST Vol. I",
		"composer": "Mike Klubnika",
		"tracks": [
			{
				"title": "General Release",
				"file_path": "res://audio/music/music main_techno techno",
				"loop_path": "res://audio/music/music main second loop_techno techno",
				"file_type": "ogg",
				"bpm_increment": 0.41
			},
			{
				"title": "Before Every Load",
				"file_path": "res://audio/music/music main_error",
				"loop_path": "res://audio/music/music main second loop_error",
				"file_type": "ogg",
				"bpm_increment": 0.42
			},
			{
				"title": "Socket Calibration",
				"file_path": "res://audio/music/music main_room",
				"loop_path": "res://audio/music/music main second loop_room",
				"file_type": "ogg",
				"bpm_increment": 0.47
			},
		]
	},
	{
		"title": "OST Vol. II",
		"composer": "Alex Peipman",
		"tracks": [
			{
				"title": "Surrounded",
				"file_path": "res://multiplayer/audio/music/mp_music bearing loop1",
				"loop_seek": 76.8,
				"file_type": "ogg",
				"bpm": 150.0,
				"round": 0
			},
			{
				"title": "Twice or it's Luck",
				"file_path": "res://multiplayer/audio/music/mp_music jungle loop1",
				"loop_seek": 115.28,
				"file_type": "ogg",
				"bpm": 140.0,
				"round": 1
			},
			{
				"title": "Overdose Casino",
				"file_path": "res://multiplayer/audio/music/mp_music alarm loop1",
				"loop_seek": 54.86,
				"file_type": "ogg",
				"bpm": 140.0,
				"round": 2
			},
		],
		"steam": true
	},
	{
		"title": "KLUB EP",
		"composer": "XIX",
		"tracks": [
			{
				"title": "KLUB001",
				"file_name": "klub001",
				"loop_seek": 53.32,
				"file_type": "wav",
				"round": 1,
				"bpm": 144.0,
				"loop_begin": 587936,
			},
			{
				"title": "KLUB002",
				"file_name": "klub002",
				"loop_seek": 80.55,
				"file_type": "wav",
				"bpm": 143.0,
				"round": 2
			},
			{
				"title": "KLUB003",
				"file_name": "klub003",
				"loop_seek": 40.0,
				"file_type": "wav",
				"bpm": 144.0,
				"round": 2
			},
			{
				"title": "KLUB004",
				"file_name": "klub004",
				"loop_seek": 99.56,
				"file_type": "wav",
				"bpm": 135.0,
				"round": 0
			},
			{
				"title": "KLUB005",
				"file_name": "klub005",
				"loop_seek": 69.57,
				"file_type": "wav",
				"bpm": 138.0,
				"round": 2,
				"loop_begin": 306308
			},
			{
				"title": "KLUB006",
				"file_name": "klub006",
				"loop_seek": 85.97,
				"file_type": "wav",
				"bpm": 134.0,
				"round": 0
			},
			{
				"title": "KLUB007",
				"file_name": "klub007",
				"loop_seek": 42.98,
				"file_type": "wav",
				"bpm": 134.0,
				"round": 0,
				"loop_begin": 316042
			},
			{
				"title": "KLUB008",
				"file_name": "klub008",
				"loop_seek": 83.47,
				"file_type": "wav",
				"bpm": 138.0,
				"round": 1
			},
		]
	},
	{
		"title": "Single",
		"composer": "NYCS",
		"tracks": [
			{
				"title": "Burner Phone",
				"file_name": "burnerphone",
				"loop_seek": 111.48,
				"file_type": "wav",
				"bpm": 155.0,
				"round": 1,
				"double": true
			}
		]
	},
	{
		"title": "Unused tracks",
		"composer": "Mike Klubnika",
		"tracks": [
			{
				"title": "helicopter",
				"file_path": "res://audio/music_helicopter vol1",
				"loop_seek": 41.14,
				"file_type": "ogg",
				"bpm": 140.0
			}
		]
	},
]

const extras = [
	{
		"title": "Synthwave Covers",
		"composer": "Leslie Mag",
		"tracks": [
			{
				"title": "Blank Shell",
				"file_name": "blankshell",
				"file_type": "wav",
				"loop_begin": 2160000,
				"double": true
			},
			{
				"title": "70K",
				"file_name": "seventyk",
				"file_type": "wav",
				"double": true
			},
		]
	},
	{
		"title": "Unused tracks",
		"composer": "Mike Klubnika",
		"tracks": [
			{
				"title": "true death",
				"file_path": "res://audio/music_true death vol1",
				"file_type": "ogg"
			}
		]
	}
]

var config_defaults = {
	"tracks": {},
	"extras": {
		"blank_shell": false,
		"70k": false,
		"true_death": false
	},
	"hint": true
}

const hooks = [
	"scripts/BpmLight.gd",
	"scripts/EndingManager.gd",
	"scripts/MusicManager.gd",
	"scripts/MenuManager.gd"
]

const id = "MSLaFaver-MoreMusic"

var menu_manager
var blank_shell_mk: AudioStream
var blank_shell_lm: AudioStream

var menu_stream_original: AudioStream
var menu_playback_position = 0.0
var menu_original_playing = true
var current_menu_track = ["",""]
var lerping = false

var currentBatchIndex
var current_track

func _init():
	for hook in hooks:
		ModLoaderMod.install_script_hooks("res://%s" % hook,
			"res://mods-unpacked/%s/%s" % [id, hook])

func _ready():
	for album in albums:
		for track in album.tracks:
			var round_num = track.get("round")
			if round_num != null:
				config_defaults.tracks["%s - %s - %s" % [album.composer, album.title, track.title]] = [round_num]
	
	ModLoader.get_node("MSLaFaver-ModMenu").config_init(id, config_defaults)

func _process(delta):
	if lerping and menu_manager != null:
		var linear = db_to_linear(menu_manager.speaker_music.volume_db)
		var new_vol = min(linear + delta / 2, 1.0)
		menu_manager.speaker_music.volume_db = linear_to_db(new_vol)
		if new_vol >= 1:
			lerping = false

func set_blankshell(enabled: bool):
	if enabled:
		menu_manager.speaker_music.stream = blank_shell_lm
	else:
		menu_manager.speaker_music.stream = blank_shell_mk
	
	menu_stream_original = menu_manager.speaker_music.stream
	
	await get_tree().create_timer(0.1, false).timeout
	menu_manager.speaker_music.play()
