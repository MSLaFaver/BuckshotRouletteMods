extends Object

var id = "MSLaFaver-MoreMusic"

var data

var bpmlight
var mod_main
var playerData
var initialized = false

func _ready(chain: ModLoaderHookChain):
	chain.execute_next_async()
	randomize()
	
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		if config.data.has("tracks"):
			data = config.data.tracks
		
		if config.data.has("extras") and config.data.extras.get("true_death",false):
			var file_name = ""
			for album in ModLoader.get_node(id).extras:
				if album.title == "Unused tracks" and album.composer == "Mike Klubnika":
					for track in album.tracks:
						if track.title == "true death":
							file_name = "%s.%s" % [track.file_path, track.file_type]
							break
					break
			var truedeath_alt = load(file_name) as AudioStreamOggVorbis
			truedeath_alt.loop = true
			chain.reference_object.roundManager.healthCounter.speaker_truedeath.stream = truedeath_alt
	
	bpmlight = chain.reference_object.get_node("../../backroom main parent/club light underside_CLUB US/bpm light branch")
	mod_main = ModLoader.get_node(id)
	playerData = chain.reference_object.roundManager.playerData.duplicate()
	if not (playerData.playerEnteringFromDeath
		and not playerData.enteringFromTrueDeath):
		mod_main.currentBatchIndex = null
		mod_main.current_track = ""

func LoadTrack(chain: ModLoaderHookChain):
	var currentBatch = playerData.currentBatchIndex
	var death = playerData.playerEnteringFromDeath
	var trueDeath = playerData.enteringFromTrueDeath
	var track = ""
	var bpm = 0.0
	var bpmIncrement = 0.0
	
	if mod_main.currentBatchIndex != currentBatch and (initialized or not (death or trueDeath)):
		var possible_tracks = []
		for possible_track in data:
			if data[possible_track].has(float(currentBatch)):
				possible_tracks.append(possible_track)
		if possible_tracks.is_empty():
			chain.reference_object.speaker_music.stop()
		else:
			track = possible_tracks.pick_random()
			mod_main.currentBatchIndex = currentBatch
			mod_main.current_track = track
	else:
		track = mod_main.current_track
		
	if track != "":
		var file_path
		var file_type
		var loop_seek = 0.0
		var loop_begin
		var double
		var track_data = Array(track.split(" - "))
		for album in mod_main.albums:
			if album.composer == track_data[0] and album.title == track_data[1]:
				for album_track in album.tracks:
					if album_track.title == track_data[2]:
						if album_track.has("file_name"):
							file_path = "res://mods-unpacked/%s/music/%s" % [id, album_track.get("file_name")]
							loop_begin = album_track.get("loop_begin",0)
							double = album_track.get("double", false)
						else:
							var loop_path = album_track.get("loop_path")
							if loop_path != null and death and not chain.reference_object.trackset:
								file_path = loop_path
							else:
								file_path = album_track.get("file_path")
						bpm = album_track.get("bpm",0.0)
						bpmIncrement = album_track.get("bpm_increment",0.0)
						if death and not chain.reference_object.trackset:
							loop_seek = album_track.get("loop_seek", 0.0)
							chain.reference_object.trackset = true
						file_type = album_track.get("file_type")
						break
				break
		
		var stream = load("%s.%s" % [file_path, file_type])
		if file_type == "ogg":
			stream.loop = true
		elif file_type == "wav":
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_begin = loop_begin
			stream.loop_end = stream.data.size() / (4 if double else 8)
		
		chain.reference_object.filter.effect_lowPass.cutoff_hz = 436.0
		chain.reference_object.filter.moving = false
		chain.reference_object.speaker_music.stream = stream
		chain.reference_object.speaker_music.play()
		if loop_seek > 0.0:
			chain.reference_object.speaker_music.seek(loop_seek)
	
	if bpmIncrement > 0.0:
		bpmlight.delay = bpmIncrement
	else:
		bpmlight.delay = 60.0 / bpm
	
	initialized = true
