extends Object

var id = "MSLaFaver-MoreMusic"

func BeginEnding(chain: ModLoaderHookChain):
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null and config.data.extras.get("70k",false):
		var file_name = ""
		for album in ModLoader.get_node(id).extras:
			if album.title == "Synthwave Covers" and album.composer == "Leslie Mag":
				for track in album.tracks:
					if track.title == "70K":
						file_name = "%s.%s" % [track.file_name, track.file_type]
						break
				break
		var seventyk = load("res://mods-unpacked/%s/music/%s" % [id, file_name]) as AudioStreamWAV
		chain.reference_object.music_ending.stream = seventyk
	chain.execute_next_async()
