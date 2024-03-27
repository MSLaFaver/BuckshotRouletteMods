extends "res://scripts/CameraManager.gd"

func BeginLerp(lerpName : String):
	pass

func _unhandled_input(event):
	if (event.is_action_pressed("debug_1")): super.BeginLerp("enemy")
	if (event.is_action_pressed("debug_2")): super.BeginLerp("briefcase")
