extends Node

const AUTHORNAME_MODNAME_DIR := "MSLaFaver-FullCustomizer"
const AUTHORNAME_MODNAME_LOG_NAME := "MSLaFaver-FullCustomizer:Main"

var mod_dir_path := ""
var extensions_dir_path := ""

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir()+(AUTHORNAME_MODNAME_DIR)+"/"
	# Add extensions
	install_script_extensions()

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path+"extensions/"
	const extensions = [
		'RoundManager',
		'ItemManager',
		'DefibCutter'
	]
	for extension in extensions:
		ModLoaderMod.install_script_extension(extensions_dir_path+extension+".gd")

func _ready() -> void:
	pass

func _process(delta):
	pass
