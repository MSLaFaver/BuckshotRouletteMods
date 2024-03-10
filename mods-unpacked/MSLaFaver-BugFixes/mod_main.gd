extends Node

const AUTHORNAME_MODNAME_DIR := "MSLaFaver-BugFixes"
const AUTHORNAME_MODNAME_LOG_NAME := "MSLaFaver-BugFixes:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

var ran_main = false

# Before v6.1.0
# func _init(modLoader = ModLoader) -> void:
func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir()+(AUTHORNAME_MODNAME_DIR)+"/"
	# Add extensions
	install_script_extensions()

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path+"extensions/"
	const extensions = [
		'ResetManager',
	]
	for extension in extensions:
		ModLoaderMod.install_script_extension(extensions_dir_path+extension+".gd")

	
func _ready() -> void:
	pass

func _process(delta):
	if get_tree().get_root().get_child(2).name == "main":
		var dispenser = get_tree().get_root().get_child(2).get_node("restroom_CLUB/Cube_112")
		var material = dispenser.mesh.surface_get_material(0) as StandardMaterial3D
		var image = Image.load_from_file("res://mods-unpacked/MSLaFaver-BugFixes/dispenser_clean.png")
		var texture = ImageTexture.create_from_image(image)
		material.albedo_texture = texture
		dispenser.mesh.surface_set_material(0,material)
	