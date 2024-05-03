extends Node

const AUTHORNAME_MODNAME_DIR := "MSLaFaver-MtnDew"

var ending
	
func _process(delta):
	var main = GlobalVariables.get_current_scene_node()
	if main.name == "main" and not main.has_node("do the dew"):
		ending = GlobalVariables.get_current_scene_node().get_node("standalone managers/ending manager")

		var doTheDew = Node.new()
		doTheDew.name = "do the dew"
		main.add_child(doTheDew)
		
		var image = Image.load_from_file("res://mods-unpacked/MSLaFaver-MtnDew/dew.png")
		var texture = ImageTexture.create_from_image(image)
	
		var beer_animation = main.get_node("player item interaction parent/beer can pivot parent/beer can parent")
		var material = beer_animation.mesh.surface_get_material(0) as StandardMaterial3D
		material.albedo_texture = texture
		beer_animation.mesh.surface_set_material(0,material)

		var itemManager = main.get_node("standalone managers/item manager")
	
		for item in itemManager.instanceArray:
			if item.itemName == "beer":
				var beer_item = item.instance.instantiate()
				beer_item.mesh.surface_set_material(0,material)
				beer_item.get_node("pickup indicator").itemName = "MTN DEW"
				var dew = PackedScene.new()
				dew.pack(beer_item)
				item.instance = dew
				break
		for item in itemManager.instanceArray_dealer:
			if item.itemName == "beer":
				var beer_item = item.instance.instantiate()
				beer_item.mesh.surface_set_material(0,material)
				beer_item.get_node("pickup indicator").itemName = "MTN DEW"
				var dew = PackedScene.new()
				dew.pack(beer_item)
				item.instance = dew
				break

	if not ending.label_array[4].text.is_empty():
		ending.label_array[4].text = "ml of dew drank ... " + str(ending.roundManager.playerData.stat_beerDrank)
		
		
