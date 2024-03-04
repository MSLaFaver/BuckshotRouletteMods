extends "res://scripts/InteractionManager.gd"

var enabled = true

func _input(event):
	if(enabled):
		super._input(event)
