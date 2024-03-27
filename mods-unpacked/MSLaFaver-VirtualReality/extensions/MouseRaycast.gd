extends "res://scripts/MouseRaycast.gd"

var fixed = false
var xr_camera

func _ready():
	var xr_origin = XROrigin3D.new()
	xr_origin.name = "xr origin"
	xr_origin.world_scale = 0.1
	#xr_origin.position = Vector3(0, -15.3, 0)
	xr_camera = XRCamera3D.new()
	xr_camera.name = "xr camera"
	xr_origin.add_child(xr_camera)
	add_child(xr_origin)
	xr_camera.make_current()

func get_selection():
	var worldspace = xr_camera.get_world_3d().direct_space_state
	var start = xr_camera.project_ray_origin(mouse)
	var end = xr_camera.project_position(mouse, 20000)
	result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
