extends Node

const id = "MSLaFaver-MountainDew"

const hooks = [
	"scripts/DialogueManager.gd",
	"scripts/HandManager.gd",
	"scripts/ItemInteraction.gd",
	"scripts/ItemManager.gd",
	"scripts/RoundManager.gd",
	"scripts/ShellLoader.gd",
	"scripts/ShellSpawner.gd"
]

var texture1
var texture_sheet1
var texture2
var texture_sheet2

var material0
var material1
var material4
var beer_animation
var angles_original

var god_help_us_all = false

func _init():
	for hook in hooks:
		ModLoaderMod.install_script_hooks("res://%s" % hook,
			"res://mods-unpacked/%s/%s" % [id, hook])

func _ready():
	texture1 = ImageTexture.create_from_image(Image.load_from_file("res://mods-unpacked/%s/dew.png" % id))
	texture_sheet1 = ImageTexture.create_from_image(Image.load_from_file("res://mods-unpacked/%s/dew sheet.png" % id))
	texture2 = ImageTexture.create_from_image(Image.load_from_file("res://mods-unpacked/%s/dew2.png" % id))
	texture_sheet2 = ImageTexture.create_from_image(Image.load_from_file("res://mods-unpacked/%s/dew2 sheet.png" % id))

func _process(delta):
	var main = get_tree().get_current_scene()
	if main.name == "main" and not main.has_node("do the dew"):
		var doTheDew = Node.new()
		doTheDew.name = "do the dew"
		main.add_child(doTheDew)
	
		beer_animation = main.get_node("player item interaction parent/beer can pivot parent/beer can parent")
		material0 = beer_animation.mesh.surface_get_material(0) as StandardMaterial3D
		material0.texture_repeat = false
		material1 = beer_animation.mesh.surface_get_material(1) as StandardMaterial3D
		material1.albedo_texture = null
		material4 = beer_animation.mesh.surface_get_material(4) as StandardMaterial3D

		var beer_dealer = main.get_node("dealer hands main1/dealer hands parent/hand parent left/dealer hand left_beer/beer can dealer hand")
		beer_dealer.mesh.surface_set_material(0,material0)
		beer_dealer.mesh.surface_set_material(1,material1)
		beer_dealer.mesh.surface_set_material(4,material4)

func RandomizeDew(itemManager: ItemManager, dealer: bool = false):
	var idx = randi_range(0,1)
	var rot_can = randf_range(0,360)
	var instanceArray
	instanceArray = itemManager.instanceArray if not dealer else itemManager.instanceArray_dealer
	if angles_original ==  null:
		angles_original = [
			instanceArray[2].rot_inBriefcase,
			instanceArray[2].rot_inHand,
			instanceArray[2].rot_offset
		]
	var angles = angles_original.duplicate()
	RotateAll(angles, rot_can)
	print(angles)
	instanceArray[2].rot_inBriefcase = angles[0]
	instanceArray[2].rot_inHand = angles[1]
	instanceArray[2].rot_offset = angles[2]
	SetMaterial(idx)
	if not dealer:
		UpdateInstances(itemManager.instanceArray)
	else:
		UpdateInstances(itemManager.instanceArray_dealer)
	return idx

func SetMaterial(idx: int):
	var texture
	var texture_sheet
	var color
	if bool(idx):
		texture = texture1
		texture_sheet = texture_sheet1
		color = Color(0.5,0.68,0.2,1)
	else:
		texture = texture2
		texture_sheet = texture_sheet2
		color = Color(0.25,0.67,0.29,1)
	
	material0.albedo_texture = texture
	material4.albedo_texture = texture_sheet
	material1.albedo_color = color

func UpdateInstances(instanceArray: Array):
	for item in instanceArray:
		if item.itemName == "beer":
			var beer_item = item.instance.instantiate()
			beer_item.mesh.surface_set_material(0,material0.duplicate())
			beer_item.mesh.surface_set_material(1,material1.duplicate())
			beer_item.mesh.surface_set_material(4,material4.duplicate())
			var dew = PackedScene.new()
			dew.pack(beer_item)
			item.instance = dew
			break

func Rotate(rotation: Vector3, delta: float) -> Vector3:
	var basis = Basis.from_euler(rotation * PI / 180.0)
	var rot = Basis(Vector3.UP, deg_to_rad(delta))
	return (basis * rot).get_euler() * 180.0 / PI

func RotateAll(angles, rot):
	for i in range(0, angles.size()):
		angles[i] = Rotate(angles[i], rot)
		if i > 0:
			var prev_y = angles[i - 1].y
			var cur_y = angles[i].y
			var flip = false
			while cur_y < prev_y:
				flip = not flip
				cur_y += 180
			var v: Vector3 = angles[i]
			v.y = cur_y
			if flip:
				v.x = -v.x
				v.z = -v.z
			angles[i] = v
