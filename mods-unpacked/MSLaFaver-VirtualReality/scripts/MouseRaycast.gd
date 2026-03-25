extends Object

var xr_camera
var xr_origin
var left_hand
var right_hand
var world_scale = 1
var adjust_amt
var cursor_3d : MeshInstance3D
var cursorManager = null
var eyes_flag = false
var briefcaseEyes
var scene
var pressing = false

func _process(chain: ModLoaderHookChain, delta):
	var mouseRaycast = chain.reference_object
	if not mouseRaycast.has_node("ready run"):
		var ready_run = Node.new()
		ready_run.name = "ready run"
		mouseRaycast.add_child(ready_run)
		xr_origin = XROrigin3D.new()
		xr_origin.name = "xr origin"
		scene = mouseRaycast.get_tree().get_current_scene()
		if scene.name == "main":
			world_scale = 10
			briefcaseEyes = scene.get_node("briefcase machine eyes")
		xr_origin.world_scale = world_scale
		#xr_origin.position = Vector3(0, -15.3, 0)
		xr_camera = XRCamera3D.new()
		xr_camera.name = "xr camera"
		xr_origin.add_child(xr_camera)
		mouseRaycast.add_child(xr_origin)
		
		var ghost_hand = load("res://addons/godot-xr-tools/hands/materials/ghost_hand.tres")
		ghost_hand.next_pass = null
		ghost_hand.albedo_color.a = 0.02
		
		left_hand = XRController3D.new()
		left_hand.name = "left hand"
		left_hand.tracker = "left_hand"
		var left_physics_hand = load("res://addons/godot-xr-tools/hands/scenes/highpoly/left_physics_hand.tscn").instantiate()
		left_hand.add_child(left_physics_hand)
		left_physics_hand.owner = left_hand
		xr_origin.add_child(left_hand)
		left_physics_hand.hand_material_override = ghost_hand
		
		right_hand = XRController3D.new()
		right_hand.name = "right hand"
		right_hand.tracker = "right_hand"
		var right_physics_hand = load("res://addons/godot-xr-tools/hands/scenes/highpoly/right_physics_hand.tscn").instantiate()
		right_hand.add_child(right_physics_hand)
		right_physics_hand.owner = right_hand
		xr_origin.add_child(right_hand)
		right_physics_hand.hand_material_override = ghost_hand
		
		# CODE FROM teddybear082 ON DISCORD
		cursor_3d = MeshInstance3D.new()
		var cursor_3d_sphere : SphereMesh = SphereMesh.new()
		var unshaded_material : StandardMaterial3D = StandardMaterial3D.new()
		unshaded_material.disable_ambient_light = true
		unshaded_material.disable_receive_shadows = true
		unshaded_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		unshaded_material.no_depth_test = true
		unshaded_material.render_priority = 2
		cursor_3d_sphere.radius = 0.002 * world_scale
		cursor_3d_sphere.height = 2 * cursor_3d_sphere.radius
		cursor_3d.mesh = cursor_3d_sphere
		cursor_3d.material_override = unshaded_material
		cursor_3d.transparency = 0.5
		cursor_3d.visible = true
		cursor_3d.name = "Cursor3D"
		right_hand.add_child(cursor_3d)
		cursor_3d.transform.origin.z = -world_scale
	
	get_selection(mouseRaycast)
	if xr_origin.position == Vector3(0,0,0):
		adjust_amt = xr_camera.position.y - xr_origin.position.y
		xr_origin.position.y -= adjust_amt
	elif briefcaseEyes != null and briefcaseEyes.visible and not eyes_flag:
		eyes_flag = true
	elif xr_origin.global_position.z < -50 and eyes_flag and not mouseRaycast.has_node("end flag"):
		xr_origin.world_scale = 1
		xr_origin.position.y = 0
		mouseRaycast.rotation_degrees = Vector3(0,-19,0)
		var end_flag = Node.new()
		end_flag.name = "end flag"
		mouseRaycast.add_child(end_flag)
	if cursorManager == null:
		cursorManager = scene.get_node("standalone managers/cursor manager")
	else:
		cursor_3d.visible = cursorManager.cursor_visible
	
	var speed = 0.01
	if Input.is_key_pressed(KEY_CTRL):
		speed = 0.02
	if Input.is_key_pressed(KEY_LEFT) and not Input.is_key_pressed(KEY_RIGHT):
		mouseRaycast.rotation.y += speed
	elif not Input.is_key_pressed(KEY_LEFT) and Input.is_key_pressed(KEY_RIGHT):
		mouseRaycast.rotation.y -= speed
	if Input.is_key_pressed(KEY_UP) and not Input.is_key_pressed(KEY_DOWN):
		mouseRaycast.rotation.x += speed
	elif not Input.is_key_pressed(KEY_UP) and Input.is_key_pressed(KEY_DOWN):
		mouseRaycast.rotation.x -= speed
	
	if right_hand.is_button_pressed("trigger") and not pressing:
		pressing = true
		var ev = InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = true
		Input.parse_input_event(ev)
	elif not right_hand.is_button_pressed("trigger"):
		pressing = false

func get_selection(mouseRaycast):
	var worldspace = right_hand.get_world_3d().direct_space_state
	var from = right_hand.global_position
	var to = cursor_3d.global_position
	var end = from + (to - from) * 100
	mouseRaycast.result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(from, end))
