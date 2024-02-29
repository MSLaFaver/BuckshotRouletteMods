extends "res://scripts/ResetManager.gd"

func _unhandled_input(event):
	super._unhandled_input(event)
	Engine.time_scale = 1
	
