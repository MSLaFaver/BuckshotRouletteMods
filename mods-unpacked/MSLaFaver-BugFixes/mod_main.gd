extends Node

const AUTHORNAME_MODNAME_DIR := "MSLaFaver-BugFixes"
const AUTHORNAME_MODNAME_LOG_NAME := "MSLaFaver-BugFixes:Main"

var mod_dir_path := ""
var extensions_dir_path := ""

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir()+(AUTHORNAME_MODNAME_DIR)+"/"
	# Add extensions
	install_script_extensions()

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path+"extensions/"
	const extensions = [
		'ResetManager'
	]
	for extension in extensions:
		ModLoaderMod.install_script_extension(extensions_dir_path+extension+".gd")

var root = null
var roundManager
var resetManager
var waitingForDON = true
var lerpFlag = false
var fixedTowels

func _ready():
	pass

func _process(delta):
	if root == null:
		root = get_tree().get_root().get_child(2)
	elif root.name == "main":
		resetManager = root.get_node("standalone managers/reset manager")
		fixedTowels = resetManager.fixedTowels
		if (not fixedTowels):
			resetManager.fixedTowels = true
			fixedTowels = true
			var dispenser = root.get_node("restroom_CLUB/Cube_112")
			var material = dispenser.mesh.surface_get_material(0) as StandardMaterial3D
			var image = Image.load_from_file("res://mods-unpacked/MSLaFaver-BugFixes/dispenser_clean.png")
			var texture = ImageTexture.create_from_image(image)
			material.albedo_texture = texture
			dispenser.mesh.surface_set_material(0,material)

			roundManager = root.get_node("standalone managers/round manager")

		if (roundManager.doubling and waitingForDON):
			waitingForDON = false

			var max_cash = 70000		
			var cancer_bills = int(roundManager.playerData.stat_cigSmoked * 220)
			var DUI_fine = int(roundManager.playerData.stat_beerDrank * 1.5)
			var total_cash = max_cash - cancer_bills - DUI_fine
			if (total_cash < 0): total_cash = 0
			roundManager.endscore = total_cash
			roundManager.prevscore = total_cash

		if (roundManager.ui_doubleornothing.visible and not lerpFlag):
			roundManager.lerpingscore = false
			lerpFlag = true
		elif (not roundManager.ui_doubleornothing.visible and lerpFlag):
			lerpFlag = false