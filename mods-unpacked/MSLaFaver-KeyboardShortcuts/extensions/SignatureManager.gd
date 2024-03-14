extends "res://scripts/SignatureManager.gd"

var active = false
var signed = false

var charArray = [
	["sign_a", "sign_b", "sign_c", "sign_d", "sign_e", "sign_f", "sign_g", "sign_h", "sign_i", "sign_j", "sign_k", "sign_l", "sign_m", "sign_n", "sign_o", "sign_p", "sign_q", "sign_r", "sign_s", "sign_t", "sign_u", "sign_v", "sign_w", "sign_x", "sign_y", "sign_z", "sign_backspace", "sign_enter"],
	[KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, KEY_I, KEY_J, KEY_K, KEY_L, KEY_M, KEY_N, KEY_O, KEY_P, KEY_Q, KEY_R, KEY_S, KEY_T, KEY_U, KEY_V, KEY_W, KEY_X, KEY_Y, KEY_Z, KEY_BACKSPACE, KEY_ENTER],
	["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "backspace", "enter"]
]

func PickUpWaiver():
	speaker_bootup.play()
	parent_signatureMachineMainParent.visible = true
	intrbranch_waiver.interactionAllowed = false
	cursor.SetCursor(false, false)
	anim_waiver.play("pickup waiver")
	for letter in letterArray: letter.text = ""
	UpdateMarkerPosition()
	UpdateLEDArray()
	blinking = true
	BlinkMarker()
	var ev = InputEventKey.new()
	ev.keycode = KEY_R
	InputMap.erase_action("reset")
	for i in range(28): AddKey(charArray[0][i], charArray[1][i])
	active = true
	await get_tree().create_timer(2.77, false).timeout #.9 anim speed
	for intbr in intbranches : intbr.interactionAllowed = true
	if (!signed): cursor.SetCursor(true, true)

func Input_Enter():
	var chararray = []
	fullstring = ""
	for letter in letterArray:
		if (letter.text != ""):
			chararray.append(letter.text)
	for l in chararray: fullstring += l
	lettercount = chararray.size()
	if (fullstring == ""): return
	if (fullstring == "dealer"): return
	if (fullstring == "god"): return
	if (fullstring != ""):
		for br in intbranches:
			var el = br.get_parent().get_child(2)
			br.interactionAllowed = false
			el.set_collision_layer_value(1, false)
			el.set_collision_mask_value(1, false)
	signed = true
	active = false
	InputMap.erase_action("sign_r")
	AddKey("reset",KEY_R)
	cursor.SetCursor(false, false)
	await get_tree().create_timer(.25, false).timeout
	for i in range(lettercount):
		letterArray_signature_joined[i].text = chararray[i].to_upper()
		letterArray_signature_separate[i].text = chararray[i].to_upper()
		ledArray[i].visible = false
		await get_tree().create_timer(.17, false).timeout
		speaker_punch.pitch_scale = randf_range(.95, 1)
		speaker_punch.play()
	await get_tree().create_timer(.17, false).timeout
	parent_shotgun.transform.origin = origpos_shotgun
	anim_waiver.play("put away waiver")
	speaker_bootup.stop()
	speaker_shutdown.play()
	roundManager.playerData.playername = fullstring
	roundManager.playerData.hasSignedWaiver = true
	ReturnToMainBatch()
	await get_tree().create_timer(1.72, false).timeout
	parent_signatureMachineMainParent.visible = false
	parent_separateWaiver.visible = false
	await get_tree().create_timer(.4, false).timeout
	parent_waiver.queue_free()

func _unhandled_input(event):
	if (active):
		if (event.is_action_pressed(charArray[0][0])): if (active): GetInput(charArray[2][0],"")
		if (event.is_action_pressed(charArray[0][1])): if (active): GetInput(charArray[2][1],"")
		if (event.is_action_pressed(charArray[0][2])): if (active): GetInput(charArray[2][2],"")
		if (event.is_action_pressed(charArray[0][3])): if (active): GetInput(charArray[2][3],"")
		if (event.is_action_pressed(charArray[0][4])): if (active): GetInput(charArray[2][4],"")
		if (event.is_action_pressed(charArray[0][5])): if (active): GetInput(charArray[2][5],"")
		if (event.is_action_pressed(charArray[0][6])): if (active): GetInput(charArray[2][6],"")
		if (event.is_action_pressed(charArray[0][7])): if (active): GetInput(charArray[2][7],"")
		if (event.is_action_pressed(charArray[0][8])): if (active): GetInput(charArray[2][8],"")
		if (event.is_action_pressed(charArray[0][9])): if (active): GetInput(charArray[2][9],"")
		if (event.is_action_pressed(charArray[0][10])): if (active): GetInput(charArray[2][10],"")
		if (event.is_action_pressed(charArray[0][11])): if (active): GetInput(charArray[2][11],"")
		if (event.is_action_pressed(charArray[0][12])): if (active): GetInput(charArray[2][12],"")
		if (event.is_action_pressed(charArray[0][13])): if (active): GetInput(charArray[2][13],"")
		if (event.is_action_pressed(charArray[0][14])): if (active): GetInput(charArray[2][14],"")
		if (event.is_action_pressed(charArray[0][15])): if (active): GetInput(charArray[2][15],"")
		if (event.is_action_pressed(charArray[0][16])): if (active): GetInput(charArray[2][16],"")
		if (event.is_action_pressed(charArray[0][17])): if (active): GetInput(charArray[2][17],"")
		if (event.is_action_pressed(charArray[0][18])): if (active): GetInput(charArray[2][18],"")
		if (event.is_action_pressed(charArray[0][19])): if (active): GetInput(charArray[2][19],"")
		if (event.is_action_pressed(charArray[0][20])): if (active): GetInput(charArray[2][20],"")
		if (event.is_action_pressed(charArray[0][21])): if (active): GetInput(charArray[2][21],"")
		if (event.is_action_pressed(charArray[0][22])): if (active): GetInput(charArray[2][22],"")
		if (event.is_action_pressed(charArray[0][23])): if (active): GetInput(charArray[2][23],"")
		if (event.is_action_pressed(charArray[0][24])): if (active): GetInput(charArray[2][24],"")
		if (event.is_action_pressed(charArray[0][25])): if (active): GetInput(charArray[2][25],"")
		if (event.is_action_pressed(charArray[0][26])): if (active): GetInput("",charArray[2][26])
		if (event.is_action_pressed(charArray[0][27])): if (active): GetInput("",charArray[2][27])

func AddKey(action, keycode):
	var ev = InputEventKey.new()
	ev.keycode = keycode
	InputMap.add_action(action)
	InputMap.action_add_event(action,ev)