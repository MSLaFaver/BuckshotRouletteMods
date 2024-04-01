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
		'MouseRaycast',
		'EndingManager'
	]
	for extension in extensions:
		ModLoaderMod.install_script_extension(extensions_dir_path+extension+".gd")

var root
var camera
var introManager
var menuManager
var cursorManager
var deathManager
var descriptionManager
var interactionManager
var itemManager
var endingManager
var worldEnvironment
var smokerDude_flag = false
var brightness_flag = false
var brightness_current = 0.0
var viewblocker
var dialogue_UI
var dialogue_UI_text
var font = preload("res://fonts/fake receipt.otf")
var dealer_dia
var dealer_dia_pos = Vector3(7,2,0)
var smokerdude_dia
var smokerdude_dia_pos = Vector3(0.25,10.5,-4)
var selected_object
var item_description
var ratchet_flag = false
var menu_objects = []
var splash
var labelArray = []

func _ready():
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")

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
		cursorManager = root.get_child(2).get_node("standalone managers/cursor manager")
		worldEnvironment = root.get_child(2).get_node("WorldEnvironment")

		brightness_current = worldEnvironment.environment.adjustment_brightness
		worldEnvironment.environment.adjustment_brightness = 0.0

		MakeInvisible(camera.get_node("post processing"))
		MakeInvisible(camera.get_node("dialogue UI"))
		
		match root.get_child(2).name:
			"menu":
				menuManager = root.get_child(2).get_node("standalone managers/menu manager")
				camera.rotation_degrees = Vector3(9, 88.8, 0)
				viewblocker = root.get_child(2).get_node("Camera/dialogue UI/viewblocker parent/viewblocker")
				menu_objects.clear()
				menu_objects.append(root.get_child(2).get_node("shell waterfall2"))
				menu_objects.append(root.get_child(2).get_node("shell waterfall4"))
				menu_objects.append(root.get_child(2).get_node("title"))
				for object in menu_objects:
					object.visible = false
				worldEnvironment.environment.fog_enabled = false
				worldEnvironment.environment.fog_light_energy = 0.0

				splash = MeshInstance3D.new()
				splash.mesh = root.get_child(2).get_node("title").mesh
				var splash_texture = StandardMaterial3D.new()
				splash_texture.albedo_texture = ImageTexture.create_from_image(Image.load_from_file("res://mods-unpacked/MSLaFaver-VirtualReality/splash.png"))
				splash_texture.transparency = 2
				splash.material_override = splash_texture
				splash.position = Vector3(-4, 0, 12.157)
				splash.rotation_degrees = Vector3(80.3, -90, 180)
				splash.scale *= 1.3
				root.get_child(2).add_child(splash)
				viewblocker.color.a = 1
			"main":
				introManager = root.get_child(2).get_node("standalone managers/intro manager")
				introManager.rot_floor = Vector3(0, -53.5, 0)
				deathManager = root.get_child(2).get_node("standalone managers/death manager")
				descriptionManager = root.get_child(2).get_node("standalone managers/description manager")
				interactionManager = root.get_child(2).get_node("standalone managers/interaction manager")
				itemManager = root.get_child(2).get_node("standalone managers/item manager")
				camera.rotation_degrees = Vector3(0, -90, 0)
				viewblocker = root.get_child(2).get_node("Camera/dialogue UI/viewblocker parent/viewblcoker")

				endingManager = root.get_child(2).get_node("standalone managers/ending manager")
				var vehicle = root.get_child(2).get_node("player vehicle parent")
				
				labelArray.clear()
				var label_congrats = Label3D.new()
				label_congrats.name = "label congrats"				
				label_congrats.font = font
				label_congrats.font_size = 42
				label_congrats.scale = Vector3(0.379, 0.794, 1)
				label_congrats.position = Vector3(-0.075, 1.295, 0.645)
				labelArray.append(label_congrats)

				for i in range(1,6):
					var label = Label3D.new()
					label.name = "label " + str(i)
					label.font = font
					label.position = Vector3(0.13, 1.22 - float(i) * 0.08, 0.715)
					labelArray.append(label)

				var label_score = Label3D.new()
				label_score.name = "label score"
				label_score.font = font
				label_score.font_size = 42
				label_score.position = Vector3(0.07, 0.69, 0.68)
				labelArray.append(label_score)

				for label in labelArray:
					label.rotation_degrees = Vector3(0,158.3,0)
					label.visible = false
					vehicle.add_child(label)

				root.get_child(2).get_node("standalone managers/ending manager/animator_camera briefcase pan").libraries[""]._data["pan to brief"].remove_track(0)

				var introAnimations = root.get_child(2).get_node("intro parent/animator_intro").libraries[""]._data
				introAnimations["camera exit bathroom"].track_insert_key(2,2.0,false)
				var enterBackroom = introAnimations["camera enter backroom"]
				for i in range(1,4):
					var enterBackroom_value = enterBackroom.track_get_key_value(0,enterBackroom.track_get_key_count(0) - i)
					enterBackroom_value.x -= 1.7
					enterBackroom.track_set_key_value(0,enterBackroom.track_get_key_count(0) - i,enterBackroom_value)

				var item_animations = root.get_child(2).get_node("player item interaction parent/animator_player items")
				for i in range(0,2):
					item_animations.libraries[""]._data["player use handsaw"].remove_track(3)
				
				for i in range(0, item_animations.libraries[""]._data["player use beer"].track_get_key_count(0)):
					var pos = item_animations.libraries[""]._data["player use beer"].track_get_key_value(0,i)
					item_animations.libraries[""]._data["player use beer"].track_set_key_value(0,i,pos + Vector3(0,-1,0))
				for i in range(0, item_animations.libraries[""]._data["player use magnifier"].track_get_key_count(0)):
					var pos = item_animations.libraries[""]._data["player use magnifier"].track_get_key_value(0,i)
					item_animations.libraries[""]._data["player use magnifier"].track_set_key_value(0,i,pos + Vector3(0,0,2))
				for i in range(1, item_animations.libraries[""]._data["player use magnifier"].track_get_key_count(5) - 1):
					var pos = item_animations.libraries[""]._data["player use magnifier"].track_get_key_value(5,i)
					item_animations.libraries[""]._data["player use magnifier"].track_set_key_value(5,i,pos + Vector3(2,-2,0))
				for i in range(1, item_animations.libraries[""]._data["player use handsaw"].track_get_key_count(1) - 1):
					var pos = item_animations.libraries[""]._data["player use handsaw"].track_get_key_value(1,i)
					item_animations.libraries[""]._data["player use handsaw"].track_set_key_value(1,i,pos + Vector3(2,0,0))
				for i in range(0, item_animations.libraries[""]._data["player use handsaw"].track_get_key_count(7)):
					var pos = item_animations.libraries[""]._data["player use handsaw"].track_get_key_value(7,i)
					item_animations.libraries[""]._data["player use handsaw"].track_set_key_value(7,i,pos + Vector3(2,0,0))
				for i in range(1, item_animations.libraries[""]._data["player use handsaw"].track_get_key_count(12) - 1):
					var pos = item_animations.libraries[""]._data["player use handsaw"].track_get_key_value(12,i)
					item_animations.libraries[""]._data["player use handsaw"].track_set_key_value(12,i,pos + Vector3(2,0,0))

				dialogue_UI = root.get_child(2).get_node("Camera/dialogue UI")
				dialogue_UI_text = dialogue_UI.get_node("main dialogue/dialogue text")

				dealer_dia = Label3D.new()
				dealer_dia.visible = false
				dealer_dia.font = font
				dealer_dia.position = dealer_dia_pos
				dealer_dia.rotation_degrees = Vector3(-10,-90,0)
				dealer_dia.scale *= 3
				root.get_child(2).get_node("tabletop parent").add_child(dealer_dia)
				
				smokerdude_dia = Label3D.new()
				smokerdude_dia.visible = false
				smokerdude_dia.font = font
				smokerdude_dia.position = smokerdude_dia_pos
				smokerdude_dia.rotation_degrees = Vector3(15,180,-1.9)
				smokerdude_dia.scale *= 2.0/3.0
				root.get_child(2).get_node("intro parent/smoker dude revive player1").add_child(smokerdude_dia)

				item_description = Label3D.new()
				item_description.font = font
				item_description.scale *= 1.5
				item_description.billboard = 1
				root.get_child(2).get_node("tabletop parent").add_child(item_description)
				viewblocker.color.a = 0

				var healthCounter = root.get_child(2).get_node("tabletop parent/main tabletop/health counter")
				for node in healthCounter.get_children():
					if node is AudioStreamPlayer3D:
						node.unit_size = 50

			"heaven":
				camera.rotation_degrees = Vector3(0, 90, 0)
				viewblocker = root.get_child(2).get_node("Camera/dialogue UI/viewblocker parent/viewblcoker")
				viewblocker.color.a = 0
			"death":
				viewblocker = root.get_child(2).get_node("Camera/dialogue UI/viewblocker parent/viewblcoker")
				viewblocker.color.a = 0
		viewblocker.visible = true

		RemoveCameraRotations(root)

		brightness_flag = true

		camera.fixed = true

	match root.get_child(2).name:
		"menu":
			worldEnvironment.environment.adjustment_brightness = brightness_current * (1.0 - viewblocker.color.a)
			if worldEnvironment.environment.adjustment_brightness >= brightness_current and not ratchet_flag:
				ratchet_flag = true
			if worldEnvironment.environment.adjustment_brightness == 0.0 and ratchet_flag:
				worldEnvironment.environment.fog_enabled = true
				splash.visible = false
				for object in menu_objects:
					object.visible = true
		"main":
			if introManager.smokerdude_revival.visible and not smokerDude_flag:
				smokerDude_flag = true
			if not introManager.smokerdude_revival.visible and smokerDude_flag:
				camera.rotation_degrees = Vector3(0, -90, 0)
				smokerDude_flag = false

			if camera.end_flag:
				worldEnvironment.environment.adjustment_brightness = 5.68 * (1.0 - viewblocker.color.a)
				labelArray[0].rotation.z = endingManager.label_congrats.rotation
				labelArray[0].text = endingManager.label_congrats.text.substr(0, endingManager.label_congrats.visible_characters)
				labelArray[0].visible = endingManager.label_congrats.visible
				for i in range(1,7):
					labelArray[i].rotation.z = endingManager.label_array[i-1].rotation
					labelArray[i].scale = Vector3(endingManager.label_array[i-1].scale.x, endingManager.label_array[i-1].scale.y, endingManager.label_array[i-1].scale.x)
					labelArray[i].text = endingManager.label_array[i-1].text
					labelArray[i].visible = endingManager.label_array[i-1].visible
			else:
				if viewblocker.visible and not brightness_flag:
					brightness_current = worldEnvironment.environment.adjustment_brightness
					worldEnvironment.environment.adjustment_brightness = 0.0
					brightness_flag = true
				if not viewblocker.visible and brightness_flag:
					worldEnvironment.environment.adjustment_brightness = brightness_current
					brightness_current = 0.0
					brightness_flag = false

			var characters = dialogue_UI_text.text.substr(0, dialogue_UI_text.visible_characters)
			dealer_dia.text = characters
			smokerdude_dia.text = characters
			dealer_dia.visible = dialogue_UI_text.visible
			smokerdude_dia.visible = dialogue_UI_text.visible
			if dialogue_UI_text.visible:
				var new_pos = [(randf()-0.5)/20.0, (randf()-0.5)/20.0]
				dealer_dia.position = dealer_dia_pos + Vector3(0.0, new_pos[0], new_pos[1])
				await get_tree().create_timer(0.03, false).timeout
			var activeBranch = interactionManager.activeInteractionBranch
			if activeBranch != null:
				match activeBranch.itemName:
					"":
						item_description.global_position = dealer_dia.global_position + Vector3(-9,-0.5,0)
					"beer":
						item_description.global_position = itemManager.gridParentArray[activeBranch.itemGridIndex].global_position + Vector3(-0.5,3.75,0.5)
					_:
						item_description.global_position = itemManager.gridParentArray[activeBranch.itemGridIndex].global_position + Vector3(0,2,0)
			item_description.transparency = 1.0 - descriptionManager.uiArray[0].modulate.a
			item_description.text = descriptionManager.uiArray[1].text + "\n\n" + descriptionManager.uiArray[3].text

		"heaven":
			if not viewblocker.visible and brightness_flag:
				worldEnvironment.environment.adjustment_brightness = brightness_current * (1.0 - viewblocker.color.a)
				brightness_current = 0.0
				brightness_flag = false

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