extends "res://scripts/FilterController.gd"

var roundManager
var waitingForDON = true
var lerpFlag = false

func _ready():
	super._ready()
	if get_tree().get_root().get_child(2).name == "main":
		var root = get_tree().get_root().get_child(2)
		var dispenser = root.get_node("restroom_CLUB/Cube_112")
		var material = dispenser.mesh.surface_get_material(0) as StandardMaterial3D
		var image = Image.load_from_file("res://mods-unpacked/MSLaFaver-BugFixes/dispenser_clean.png")
		var texture = ImageTexture.create_from_image(image)
		material.albedo_texture = texture
		dispenser.mesh.surface_set_material(0,material)

		roundManager = root.get_node("standalone managers/round manager")

func _process(delta):
	super._process(delta)
	if (roundManager.doubling && waitingForDON):
		waitingForDON = false

		var max_cash = 70000		
		var cancer_bills = int(roundManager.playerData.stat_cigSmoked * 220)
		var DUI_fine = int(roundManager.playerData.stat_beerDrank * 1.5)
		var total_cash = max_cash - cancer_bills - DUI_fine
		if (total_cash < 0): total_cash = 0
		roundManager.endscore = total_cash
		roundManager.prevscore = total_cash
	
	if (roundManager.ui_doubleornothing.visible && !lerpFlag):
		roundManager.lerpingscore = false
		lerpFlag = true
	elif (!roundManager.ui_doubleornothing.visible && lerpFlag):
		lerpFlag = false