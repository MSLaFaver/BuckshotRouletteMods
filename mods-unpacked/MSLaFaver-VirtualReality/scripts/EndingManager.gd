extends Object

func SetupEnding(chain: ModLoaderHookChain):
	var endingManager = chain.reference_object
	await endingManager.get_tree().create_timer(.1, false).timeout
	endingManager.uiparent.visible = true
	for b in endingManager.blockout:
		b.visible = true
	endingManager.pp.environment.adjustment_contrast = 1.3
	endingManager.pp.environment.adjustment_saturation = .26
	endingManager.cam.moving = false
	endingManager.animator_streetlights.play("looping")
	endingManager.animator_backdrop.play("loop exterior")
	endingManager.animator_cam.play("camera loop car")
