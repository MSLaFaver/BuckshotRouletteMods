extends Object

const id = "MSLaFaver-ModMenu"

func _ready(chain: ModLoaderHookChain):
	chain.execute_next_async()
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		var data = config.data
		if data.get("old_pills"):
			var restroom = chain.reference_object.get_node("/root/main/restroom_CLUB")
			var pills = restroom.find_child("xanax")
			if pills == null:
				var bottle_image = Image.load_from_file("res://mods-unpacked/%s/assets/pills/bottle.png" % id)
				var bottle = ImageTexture.create_from_image(bottle_image)
				var cap_image = Image.load_from_file("res://mods-unpacked/%s/assets/pills/cap.png" % id)
				var cap = ImageTexture.create_from_image(cap_image)
				var label_image = Image.load_from_file("res://mods-unpacked/%s/assets/pills/label.png" % id)
				var label = ImageTexture.create_from_image(label_image)
				
				pills = load("res://mods-unpacked/%s/assets/pills/pills.tscn" % id).instantiate()
				
				var bottle_mat = pills.mesh.surface_get_material(0)
				bottle_mat.albedo_texture = bottle
				pills.mesh.surface_set_material(0, bottle_mat)
				var cap_mat = pills.mesh.surface_get_material(1)
				cap_mat.albedo_texture = cap
				pills.mesh.surface_set_material(1, cap_mat)
				var label_mat = pills.mesh.surface_get_material(2)
				label_mat.albedo_texture = label
				pills.mesh.surface_set_material(0, label_mat)
				
				restroom.add_child(pills)

func ReturnToMainBatch(chain: ModLoaderHookChain):
	var playername = chain.reference_object.roundManager.playerData.playername
	chain.reference_object.roundManager.playerData.playername = playername.trim_prefix(" ")
	chain.execute_next_async()
