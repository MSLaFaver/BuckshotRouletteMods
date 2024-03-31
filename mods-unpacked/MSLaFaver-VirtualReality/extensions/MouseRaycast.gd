extends "res://scripts/MouseRaycast.gd"

var fixed = false
var xr_camera
var xr_origin
var world_scale = 1
var adjust_amt
var cursor_3d : MeshInstance3D
var cursorManager = null
var eyes_flag = false
var end_flag = false
var briefcaseEyes

func _ready():
	xr_origin = XROrigin3D.new()
	xr_origin.name = "xr origin"
	if get_tree().get_root().get_child(2).name == "main":
		world_scale = 10
		briefcaseEyes = get_tree().get_root().get_child(2).get_node("briefcase machine eyes")
	xr_origin.world_scale = world_scale
	#xr_origin.position = Vector3(0, -15.3, 0)
	xr_camera = XRCamera3D.new()
	xr_camera.name = "xr camera"
	xr_origin.add_child(xr_camera)
	add_child(xr_origin)

	# CODE FROM teddybear082 ON DISCORD
	var cursor_distance_from_camera : float = world_scale
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
	xr_camera.add_child(cursor_3d)
	cursor_3d.transform.origin.z = -cursor_distance_from_camera

func _process(delta):
	get_selection()
	if xr_origin.position == Vector3(0,0,0):
		adjust_amt = xr_camera.position.y - xr_origin.position.y
		xr_origin.position.y -= adjust_amt
	elif briefcaseEyes.visible and not eyes_flag:
		eyes_flag = true
	elif xr_origin.global_position.z < -50 and eyes_flag and not end_flag:
		xr_origin.world_scale = 1
		xr_origin.position.y = 0
		rotation_degrees = Vector3(0,-19,0)
		end_flag = true
	if cursorManager == null:
		cursorManager = get_tree().get_root().get_child(2).get_node("standalone managers/cursor manager")
	else:
		cursor_3d.visible = cursorManager.cursor_visible

func get_selection():
	var worldspace = xr_camera.get_world_3d().direct_space_state
	var start = xr_camera.project_ray_origin(mouse)
	var end = xr_camera.project_position(mouse, 20000)
	result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))