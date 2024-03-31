extends "res://scripts/TimeScaleManager.gd"

var disabled = false

func _unhandled_input(event):
	if (event.is_action_pressed("pause")):
		disabled = !disabled

func LerpTimeScale():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / timeScaleLerpDuration, 0.0 , 1.0)
		c = ease(c, 0.4)
		var val = lerpf(from, to, c)
		if (not disabled):
			Engine.time_scale = val
