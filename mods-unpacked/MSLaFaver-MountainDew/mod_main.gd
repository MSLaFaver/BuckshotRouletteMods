extends Node

const id = "MSLaFaver-MountainDew"

var ending
	
func _process(delta):
	var main = get_node("/root").get_children().back()
	if main.name == "main" and not main.has_node("do the dew"):
		ending = main.get_node("standalone managers/ending manager")

		var doTheDew = Node.new()
		doTheDew.name = "do the dew"
		main.add_child(doTheDew)
		
		var image = Image.load_from_file("res://mods-unpacked/%s/dew2.png" % id)
		var texture = ImageTexture.create_from_image(image)
		var image_sheet = Image.load_from_file("res://mods-unpacked/%s/dew2 sheet.png" % id)
		var texture_sheet = ImageTexture.create_from_image(image_sheet)
	
		var beer_animation = main.get_node("player item interaction parent/beer can pivot parent/beer can parent")
		var material0 = beer_animation.mesh.surface_get_material(0) as StandardMaterial3D
		material0.albedo_texture = texture
		material0.texture_repeat = false
		var material1 = beer_animation.mesh.surface_get_material(1) as StandardMaterial3D
		material1.albedo_texture = null
		material1.albedo_color = Color(0.25,0.67,0.29,1)	#Color(0.5,0.68,0.2,1)
		var material4 = beer_animation.mesh.surface_get_material(4) as StandardMaterial3D
		material4.albedo_texture = texture_sheet
		beer_animation.mesh.surface_set_material(0,material0)
		beer_animation.mesh.surface_set_material(1,material1)
		beer_animation.mesh.surface_set_material(4,material4)

		var beer_dealer = main.get_node("dealer hands main1/dealer hands parent/hand parent left/dealer hand left_beer/beer can dealer hand")
		beer_dealer.mesh.surface_set_material(0,material0)
		beer_dealer.mesh.surface_set_material(1,material1)
		beer_dealer.mesh.surface_set_material(4,material4)

		var itemManager = main.get_node("standalone managers/item manager")
	
		for item in itemManager.instanceArray:
			if item.itemName == "beer":
				var beer_item = item.instance.instantiate()
				beer_item.mesh.surface_set_material(0,material0)
				beer_item.mesh.surface_set_material(1,material1)
				beer_item.mesh.surface_set_material(4,material4)
				beer_item.get_node("pickup indicator").itemName = "MTN DEW"
				var dew = PackedScene.new()
				dew.pack(beer_item)
				item.instance = dew
				break
		for item in itemManager.instanceArray_dealer:
			if item.itemName == "beer":
				var beer_item = item.instance.instantiate()
				beer_item.mesh.surface_set_material(0,material0)
				beer_item.mesh.surface_set_material(1,material1)
				beer_item.mesh.surface_set_material(4,material4)
				beer_item.get_node("pickup indicator").itemName = "MTN DEW"
				var dew = PackedScene.new()
				dew.pack(beer_item)
				item.instance = dew
				break
