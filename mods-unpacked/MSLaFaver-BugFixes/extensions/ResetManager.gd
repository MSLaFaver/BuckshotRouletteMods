extends "res://scripts/ResetManager.gd"

var fixedTowels = false

func _unhandled_input(event):
	if (event.is_action_pressed("reset")):
		Engine.time_scale = 1
	super._unhandled_input(event)
