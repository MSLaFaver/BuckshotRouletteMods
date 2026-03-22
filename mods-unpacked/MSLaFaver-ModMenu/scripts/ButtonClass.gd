extends Object

func _ready(chain: ModLoaderHookChain):
	var mod_menu = ModLoader.get_node("MSLaFaver-ModMenu")
	mod_menu.button_class_array.append(chain.reference_object)
	chain.reference_object.get_parent().scale = Vector2(1,1)
	chain.execute_next_async()
