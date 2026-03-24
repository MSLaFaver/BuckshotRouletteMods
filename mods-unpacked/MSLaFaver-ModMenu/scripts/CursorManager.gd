extends Object

const id = "MSLaFaver-ModMenu"

func _ready(chain: ModLoaderHookChain):
	chain.execute_next_async()
	var cursorManager = chain.reference_object
	Input.set_custom_mouse_cursor(cursorManager.cursor_point, Input.CURSOR_ARROW, Vector2(12, 0))
	Input.set_custom_mouse_cursor(cursorManager.cursor_hover, Input.CURSOR_POINTING_HAND, Vector2(9, 0))
	Input.set_custom_mouse_cursor(cursorManager.cursor_invalid, Input.CURSOR_FORBIDDEN, Vector2(12, 0))

func SetCursorImage(chain: ModLoaderHookChain, alias: String):
	var shape
	match(alias):
		"point":
			shape = Control.CURSOR_ARROW
		"hover":
			shape = Control.CURSOR_POINTING_HAND
		"invalid":
			shape = Control.CURSOR_FORBIDDEN
	var cursor_override = ModLoader.get_node(id).cursor_override
	if cursor_override != null:
		cursor_override.mouse_default_cursor_shape = shape
