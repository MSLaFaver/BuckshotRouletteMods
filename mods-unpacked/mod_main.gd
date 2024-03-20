extends Node

var root = null
var post_name = "Camera/post processing/posterization test"
var fixed_image = false

func _process(delta):
	if root == null:
		root = get_tree().get_root()
	elif (!fixed_image && root.get_child(2).name == "menu"):
		var screenSize = DisplayServer.screen_get_size()
		var viewblockerParent = root.get_child(2).get_node("Camera/dialogue UI/viewblocker parent")
		var viewblocker = viewblockerParent.get_node("viewblocker")
		viewblocker.z_index = 1
		var splash = viewblockerParent.get_node("ratchet")
		var texture = ImageTexture.create_from_image(Image.load_from_file("res://mods-unpacked/MSLaFaver-SplashScreen/splash.jpg"))
		splash.texture = texture
		splash.scale = Vector2(0.280073, 0.280073)
		splash.z_index = 1
		splash.offset_left = 960.0 * 0.423322
		splash.offset_top = 540.0 * 0.363683
		var black = ColorRect.new()
		black.color = Color(0, 0, 0, 1)
		black.size = screenSize
		black.z_index = -1
		black.offset_left = -float(screenSize.x) * 0.423322
		black.offset_top = -float(screenSize.y) * 0.363683
		splash.add_child(black)
		fixed_image = true
	else:
		fixed_image = false