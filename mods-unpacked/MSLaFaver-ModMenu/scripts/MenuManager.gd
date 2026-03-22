extends Object

const id = "MSLaFaver-ModMenu"

var parent_mods: Control
var manager: MenuManager
var mods_label: Label
var mods_button_true: Button
var mods_button_class: ButtonClass

func _ready(chain: ModLoaderHookChain):
	Engine.time_scale = 1
	manager = chain.reference_object
	chain.execute_next_async()
	
	setup_main()
	setup_mods()

func setup_main():
	var main_screen = manager.get_node("/root/menu/Camera/dialogue UI/menu ui/main screen")
	
	var buttons = [
		"true button_exit",
		"button_exit"
	]
	
	var prefix = ""
	
	for button_name in buttons:
		var button = main_screen.get_node(button_name) as Control
		var new_button
		var position = button.position
		var y_pos = position.y
		button.position = Vector2(position.x, position.y + 26)
		if prefix == "":
			mods_button_true = button.duplicate()
			mods_button_true.get_children().front().queue_free()
			mods_button_true.name = "true button_mods"
			prefix = "true "
			new_button = mods_button_true
		else:
			mods_label = button.duplicate()
			mods_label.name = "button_mods"
			mods_label.text = tr("MODMENU_MODS")
			prefix = ""
			new_button = mods_label
		new_button.position.y = y_pos
		var credits = main_screen.get_node(prefix + "button_credits") as Control
		var exit = main_screen.get_node(prefix + "button_exit") as Control
		new_button.focus_neighbor_top = credits.get_path()
		new_button.focus_neighbor_bottom = exit.get_path()
		main_screen.add_child(new_button)
		var path = new_button.get_path()
		credits.focus_neighbor_bottom = path
		exit.focus_neighbor_top = path
	
	mods_button_class = ButtonClass.new()
	mods_button_class.name = "button class_mods"
	mods_button_class.cursor = manager.cursor
	mods_button_class.alias = "mods"
	mods_button_class.isActive = true
	mods_button_class.isDynamic = true
	mods_button_class.ui = mods_label
	mods_button_class.speaker_press = manager.get_node("/root/menu/speaker_press")
	mods_button_class.speaker_hover = manager.get_node("/root/menu/speaker_hover")
	mods_button_class.playing = true
	mods_button_class.ui_opacity_active = 0.5
	mods_button_true.add_child(mods_button_class)
	mods_button_class.connect("is_pressed", Mods)
	
	if GlobalVariables.using_steam:
		for child in main_screen.get_children():
			if child.name.contains("button"):
				child.position.y -= 15

func setup_mods():
	parent_mods = load("res://mods-unpacked/%s/assets/mods.tscn" % id).instantiate()
	manager.get_node("/root/menu/Camera/dialogue UI/menu ui").add_child(parent_mods)
	manager.screens.append(parent_mods)

func Mods():
	manager.Show("mods")
	manager.ResetButtons()

func Show(chain: ModLoaderHookChain, what: String):
	var assigningFocus = chain.reference_object.assigningFocus
	if what == "mods":
		chain.reference_object.assigningFocus = false
	chain.execute_next_async([what])
	chain.reference_object.assigningFocus = assigningFocus
	if what == "mods":
		parent_mods.visible = true
		if (assigningFocus):
			var focus = parent_mods.get_node("true button_return")
			if (chain.reference_object.cursor.controller_active):
				focus.grab_focus()
			chain.reference_object.controller.previousFocus = focus

func ReturnToLastScreen(chain: ModLoaderHookChain):
	var mod_main = ModLoader.get_node(id)
	if not mod_main.suppress_return and not parent_mods.warning.visible:
		if parent_mods.in_config:
			parent_mods._on_return_pressed()
		else:
			chain.execute_next_async()
