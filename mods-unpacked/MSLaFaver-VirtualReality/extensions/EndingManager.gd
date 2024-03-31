extends "res://scripts/EndingManager.gd"

func SetupEnding():
	await get_tree().create_timer(.1, false).timeout
	uiparent.visible = true
	for b in blockout: b.visible = true
	pp.environment.adjustment_contrast = 1.3
	pp.environment.adjustment_saturation = .26
	cam.moving = false
	animator_streetlights.play("looping")
	animator_backdrop.play("loop exterior")
	animator_cam.play("camera loop car")