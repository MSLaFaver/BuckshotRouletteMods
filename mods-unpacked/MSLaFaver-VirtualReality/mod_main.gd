extends Node

const AUTHORNAME_MODNAME_DIR := "MSLaFaver-VirtualReality"
const AUTHORNAME_MODNAME_LOG_NAME := "MSLaFaver-VirtualReality:Main"

var mod_dir_path := ""
var extensions_dir_path := ""

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir()+(AUTHORNAME_MODNAME_DIR)+"/"
	# Add extensions
	install_script_extensions()

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path+"extensions/"
	const extensions = [
		'CameraManager',
		'MouseRaycast'
	]
	for extension in extensions:
		ModLoaderMod.install_script_extension(extensions_dir_path+extension+".gd")

var root
var camera
var xr_interface
var introManager
var menuManager
var cursorManager
var prepareToFix = false

func _ready():
	var ev = InputEventKey.new()
	ev.keycode = KEY_SPACE
	InputMap.add_action("space")
	InputMap.action_add_event("space",ev)

func _unhandled_input(event):
	if (event.is_action_pressed("space") and root.get_child(2).name == "menu" and cursorManager.cursor_visible):
		menuManager.Start()

func _process(delta):
	root = get_tree().get_root()
	camera = root.get_child(2).get_node("Camera")
	if not camera.fixed:
		xr_interface = XRServer.find_interface("OpenXR")
		if xr_interface and xr_interface.is_initialized():
			print("OpenXR initialized successfully")
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			get_viewport().use_xr = true
		else:
			print("OpenXR not initialized, please check if your headset is connected")

		MakeInvisible(camera.get_node("post processing"))
		MakeInvisible(camera.get_node("dialogue UI"))

		RemoveCameraRotations(root)
		introManager = root.get_child(2).get_node("standalone managers/intro manager")
		introManager.rot_floor = Vector3(0, -53.5, 0)
		match root.get_child(2).name:
			"menu": camera.rotation_degrees = Vector3(9, 88.8, 0)
			"main": camera.rotation_degrees = Vector3(0, -90, 0)
			"heaven": camera.rotation_degrees = Vector3(0, 90, 0)

		camera.fixed = true

		menuManager = root.get_child(2).get_node("standalone managers/menu manager")
		cursorManager = root.get_child(2).get_node("standalone managers/cursor manager")
	
	if introManager.smokerdude_revival.visible:
		prepareToFix = true
	if introManager.smokerdude_revival.visible and prepareToFix:
		introManager.rot_floor = Vector3(0, 0, 0)
		prepareToFix = false
	

func RemoveCameraRotations(node):
	if node is AnimationPlayer:
		for animation in node.libraries[""]._data:
			var i = 0
			var end = node.libraries[""]._data[animation].get_track_count()
			while true:
				if not i < end:
					break
				var path = node.libraries[""]._data[animation].track_get_path(i)
				if path.get_name(path.get_name_count() - 1) + ":" + path.get_concatenated_subnames() == "Camera:rotation":
					node.libraries[""]._data[animation].remove_track(i)
					end -= 1
				i += 1
	for child in node.get_children():
		RemoveCameraRotations(child)

func MakeInvisible(node):
	node.visible = false
	for child in node.get_children():
		MakeInvisible(child)
