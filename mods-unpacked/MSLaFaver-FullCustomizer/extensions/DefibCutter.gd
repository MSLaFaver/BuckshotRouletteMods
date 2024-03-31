extends "res://scripts/DefibCutter.gd"

func InitialSetup():
	cam.BeginLerp("defib setup")
	await get_tree().create_timer(.6, false).timeout
	animator_main.play("initial setup")
	speaker_motor.play()
	await get_tree().create_timer(3.6, false).timeout
	cam.BeginLerp("defib console")
	speaker_bootup.play()
	await get_tree().create_timer(1.9, false).timeout
	for i in range(consoleArray.size()):
		consoleArray[i].visible = true
		speaker_beep.pitch_scale = randf_range(.8, 1.0)
		speaker_beep.play()
		await get_tree().create_timer(.09, false).timeout
	await get_tree().create_timer(.4, false).timeout
	cam.BeginLerp("defib setup")
	await get_tree().create_timer(.6, false).timeout
	blade_player.Blade("open", true)
	blade_dealer.Blade("open", false)
	await get_tree().create_timer(.5, false).timeout
	animator_main.play("main setup")
	speaker_blademove.play()
	await get_tree().create_timer(.6, false).timeout
	cam.BeginLerp("defib blade insert")
	await get_tree().create_timer(1.8, false).timeout
	if roundManager.playerData.hasReadItemSwapIntroduction and roundManager.customizer[2].items_on:
		cam.BeginLerp("home")
		await get_tree().create_timer(.6, false).timeout