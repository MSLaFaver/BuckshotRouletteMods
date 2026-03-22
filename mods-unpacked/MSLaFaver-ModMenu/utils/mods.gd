extends Control

@export var label_mods: Label
@export var button_class_folder: ButtonClass
@export var button_class_return: ButtonClass
@export var button_class_restart: ButtonClass
@export var button_class_do_not: ButtonClass
@export var scroll_container: ScrollContainer
@export var mods_container: VBoxContainer
@export var config: Control
@export var version: Label
@export var parent_folder: Control
@export var warning: Control

const id = "MSLaFaver-ModMenu"
const github = "https://github.com"

var mod_main

var http
var tags = {}
var in_config = false
var mod_status_initial = {}
var mod_status_changed = {}
var warning_shown
var toggle_off_texture: ImageTexture
var toggle_on_texture: ImageTexture
var manager: MenuManager
var request_queue = []
var request_busy = false

func _ready():
	mod_main = ModLoader.get_node(id)
	
	var data
	var user_config = ModLoaderConfig.get_config(id, "user")
	if user_config != null:
		data = user_config.data
	
	version.text = GlobalVariables.currentVersion
	
	manager = get_node("/root/menu/standalone managers/menu manager")
	var buttons = [button_class_folder, button_class_return,
		button_class_restart, button_class_do_not]
	for button in buttons:
		button.cursor = manager.cursor
		button.speaker_press = get_node("/root/menu/speaker_press")
		button.speaker_hover = get_node("/root/menu/speaker_hover")
	
	var path = ProjectSettings.globalize_path("res://mods")
	button_class_folder.connect("is_pressed", func(): OS.shell_open(path))
	button_class_return.connect("is_pressed", _on_return_pressed)
	button_class_restart.connect("is_pressed", func():
		OS.set_restart_on_exit(true)
		manager.Exit()
	)
	button_class_do_not.connect("is_pressed", func():
		self.visible = false
		manager.Show("main")
		set_visibility(true)
	)
	
	var profile = ModLoaderUserProfile.get_current()
	if profile == null:
		ModLoaderUserProfile.create_profile("default")
		profile = ModLoaderUserProfile.get_current()
	
	var toggle_off_image = Image.load_from_file("res://mods-unpacked/MSLaFaver-ModMenu/assets/toggle-off.png")
	toggle_off_texture = ImageTexture.create_from_image(toggle_off_image)
	var toggle_on_image = Image.load_from_file("res://mods-unpacked/MSLaFaver-ModMenu/assets/toggle-on.png")
	toggle_on_texture = ImageTexture.create_from_image(toggle_on_image)
	
	var speaker_hover = get_node("/root/menu/speaker_hover")
	var speaker_press = get_node("/root/menu/speaker_press")
	var cursor = get_node("/root/menu/standalone managers/cursor manager")
	
	var mod_data_set = ModLoaderMod.get_mod_data_all().values()
	mod_data_set.sort_custom(func(a, b):
		var result
		var id_a = "%s-%s" % [a.manifest.mod_namespace, a.manifest.name]
		var id_b = "%s-%s" % [b.manifest.mod_namespace, b.manifest.name]
		if id_a == id:
			result = true
		elif id_b == id:
			result = false
		else:
			result = a.manifest.name.naturalnocasecmp_to(b.manifest.name) <= 0
		return result
	)
	for mod_data in mod_data_set:
		var mod = load("res://mods-unpacked/%s/assets/mod.tscn" % id).instantiate()
		mod.mods = self
		var mod_name = mod_data.manifest.name
		var mod_namespace = mod_data.manifest.mod_namespace
		var full_name = "%s-%s" % [mod_namespace, mod_name]
		var active = profile.mod_list.get(full_name).get("is_active")
		mod_status_initial[full_name] = active
		mod_status_changed[full_name] = active
		
		mod.name = full_name
		mod.mod_namespace = mod_namespace
		mod.title.text = mod_name
		mod.version.text = "V%s" % mod_data.manifest.version_number
		mod.description.text = mod_data.manifest.description
		mod.update.uri = mod_data.manifest.website_url
		mod.active = active
		mod.toggle.button_pressed = active
		if full_name == id:
			mod.toggle.disabled = true
		var authors = Array(mod_data.manifest.authors)
		var authors_formatted = ""
		for i in range(authors.size()):
			var end = i == authors.size() - 1
			if end and i > 0:
				authors_formatted += "& "
			authors_formatted += authors[i]
			if not end:
				if authors.size() > 2:	#oxford comma supremacy
					authors_formatted += ","
				authors_formatted += " "
		mod.author.text = authors_formatted
		
		mod.speaker_hover = speaker_hover
		mod.speaker_press = speaker_press
		mod.cursor = cursor
		
		mods_container.add_child(mod)
	
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	
	if data != null:
		if data.get("check_for_updates"):
			check_for_updates()
		
		if data.get("remove_filter"):
			get_node("/root").content_scale_mode = 1
		
		if data.get("remove_discord"):
			var main_screen = get_node("/root/menu/Camera/dialogue UI/menu ui/main screen")
			for node in main_screen.find_children("*discord*", "", false):
				node.visible = false

func _process(_delta):
	if not request_busy and not request_queue.is_empty():
		request_busy = true
		http.request(request_queue.pop_front(), ["Accept: application/json"])

func set_visibility(visibility):
	for node in self.get_children():
		if node is CanvasItem:
			node.visible = visibility if node.name != "warning" else not visibility

func check_for_updates():
	for mod in ModLoaderMod.get_mod_data_all().values():
		if mod.manifest.website_url.begins_with(github):
			request_queue.append("%s/releases/latest" % mod.manifest.website_url)

func _on_request_completed(_result, response_code, _headers, body):
	request_busy = false
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json.has("tag_name"):
			var tag = json.tag_name
			var author = json.update_url.get_slice("/",1)
			var repo = json.update_url.get_slice("/",2)
			tags["/%s/%s" % [author, repo]] = tag
			var url = "%s/%s/%s/releases/download/%s/latest.json" % [github, author, repo, tag]
			request_queue.append(url)
		else:
			var mods_online = json.get("mods")
			for mod_online in mods_online:
				for mod_loaded in ModLoaderMod.get_mod_data_all().values():
					if mod_online.name == mod_loaded.manifest.name and mod_online.namespace == mod_loaded.manifest.mod_namespace:
						if mod_online.version_number.naturalnocasecmp_to(mod_loaded.manifest.version_number) == 1:
							var filename = "%s-%s-%s.zip" % [mod_online.namespace, mod_online.name, mod_online.version_number]
							var mod = mods_container.get_node("%s-%s" % [mod_online.namespace, mod_online.name])
							var tag = tags.get(Array(mod_loaded.manifest.website_url.split(github)).back())
							mod.update.uri = "%s/releases/%s/%s" % [mod_loaded.manifest.website_url, tag, filename]
							mod.update.visible = true
						break

func _on_return_pressed():
	if in_config:
		in_config = false
		for child in config.get_children():
			child.queue_free()
			mod_main.suppress_return = false
		scroll_container.visible = true
		parent_folder.visible = true
		label_mods.text = tr("MODMENU_LIST")
	elif mod_status_initial != mod_status_changed and !warning_shown:
		warning_shown = true
		set_visibility(false)
		if (manager.assigningFocus):
			var focus = get_node("warning/true button_do not")
			if (manager.cursor.controller_active):
				focus.grab_focus()
			manager.controller.previousFocus = focus
	else:
		self.visible = false
		manager.Show("main")
