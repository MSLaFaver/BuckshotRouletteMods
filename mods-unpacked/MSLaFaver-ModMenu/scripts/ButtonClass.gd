extends Object

func _ready(chain: ModLoaderHookChain):
	var mod_menu = ModLoader.get_node("MSLaFaver-ModMenu")
	mod_menu.button_class_array.append(chain.reference_object)
	var parent = chain.reference_object.get_parent()
	parent.scale = Vector2(1,1)
	parent.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	chain.execute_next_async()
