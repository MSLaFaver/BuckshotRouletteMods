extends Object

var id = "MSLaFaver-MoreMusic"

func _ready(chain: ModLoaderHookChain):
	chain.execute_next_async()
	
	var mod_main = ModLoader.get_node(id)
	mod_main.menu_manager = chain.reference_object
	mod_main.menu_original_playing = true
	mod_main.current_menu_track = ["",""]
	
	var file_name = ""
	var double = false
	for album in mod_main.extras:
		if album.title == "Synthwave Covers" and album.composer == "Leslie Mag":
			for track in album.tracks:
				if track.title == "Blank Shell":
					file_name = "%s.%s" % [track.file_name, track.file_type]
					double = track.get("double",false)
					break
			break
	
	var blankshell = load("res://mods-unpacked/%s/music/%s" % [id, file_name]) as AudioStreamWAV
	blankshell.loop_mode = AudioStreamWAV.LOOP_FORWARD
	blankshell.loop_begin = 2160000		#45.5s
	blankshell.loop_end = blankshell.data.size() / 4 if double else 8
	
	mod_main.blank_shell_mk = chain.reference_object.speaker_music.stream
	mod_main.blank_shell_lm = blankshell
	
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null and config.data.extras.get("blank_shell",false):
		chain.reference_object.animator_intro.speed_scale = 0.93
		chain.reference_object.speaker_music.stream = blankshell
		chain.reference_object.speaker_music.play()
	
	mod_main.menu_stream_original = chain.reference_object.speaker_music.stream

func FinishIntro(chain: ModLoaderHookChain):
	chain.reference_object.animator_intro.speed_scale = 1
	chain.execute_next_async()
