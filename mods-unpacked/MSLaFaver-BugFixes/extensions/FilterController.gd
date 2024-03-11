extends "res://scripts/FilterController.gd"

func _ready():
	super._ready()
	if get_tree().get_root().get_child(2).name == "main":
		var dispenser = get_tree().get_root().get_child(2).get_node("restroom_CLUB/Cube_112")
		var material = dispenser.mesh.surface_get_material(0) as StandardMaterial3D
		var image = Image.load_from_file("res://mods-unpacked/MSLaFaver-BugFixes/dispenser_clean.png")
		var texture = ImageTexture.create_from_image(image)
		material.albedo_texture = texture
		dispenser.mesh.surface_set_material(0,material)