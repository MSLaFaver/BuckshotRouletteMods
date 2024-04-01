extends "res://scripts/RoundManager.gd"

var carryover_array
var isPlayernameValid = false
var introManager
var totalWeights
var playerStartsRound = [true, true, true]
var playerTurn = true
var firstRound = true
var myTurnMessage = "MY TURN."

var customizer_main = {
	"enable": false,
	"name": "",
	"don": false,
	"swap_dealer_mesh": true,
	"multi_round_config": false,
	"carryover": 4	# BINARY
}
var customizer
var customizer_round1 = {
	"start_round": 0,	# Player / Dealer / Random
	"start_load": 0,	# Starter / Alternate / Persist
	"lives_min": 2,
	"lives_max": 4,
	"shells_scripted": false,
	"shells_total_min": 2,
	"shells_total_max": 8,
	"shells_live_percentage_min": 0.5,
	"shells_live_percentage_max": 0.5,
	#"shells_difficulty": 0,		# Visible / Total / Hidden	IF USED, THE DEALER CHEATS
	"items_on": true,
	"items_even": false,
	"items_visible": true,
	"items_total_min": 1,
	"items_total_max": 4,
	"items_handsaw_enabled": true,
	"items_handsaw_weight": 10,
	"items_magnifyingglass_enabled": true,
	"items_magnifyingglass_weight": 10,
	"items_beer_enabled": true,
	"items_beer_weight": 10,
	"items_cigarettes_enabled": true,
	"items_cigarettes_weight": 10,
	"items_handcuffs_enabled": true,
	"items_handcuffs_weight": 10,
}
var customizer_round2 = {}
var customizer_round3 = {}

func _process(delta):
	LerpScore()
	if (customizer_main.don):
		if (introManager.allowingPills):
			customizer_main.don = false
			introManager.parent_pills.visible = false
			introManager.endlessmode.SetupEndless()

func _ready():
	HideDealer()

	for key in customizer_round1:
		customizer_round2[key] = customizer_round1[key]
		customizer_round3[key] = customizer_round1[key]
	
	var needToUpdate = true
	ModLoaderStore.mod_data["MSLaFaver-FullCustomizer"].load_configs()
	var config_object = ModLoaderConfig.get_config("MSLaFaver-FullCustomizer", "user")
	if (config_object == null):
		needToUpdate = false
		config_object = ModLoaderConfig.create_config("MSLaFaver-FullCustomizer", "user",
			{"main": customizer_main, "customizer": {"round1": customizer_round1, "round2": customizer_round2, "round3": customizer_round3}})
	var config = config_object.data
	if (needToUpdate and config.main.enable):
		customizer_main.enable = true
		var regex = RegEx.new()
		regex.compile("^[a-zA-Z]+$")
		customizer_main.name = config.main.name
		isPlayernameValid = (customizer_main.name.length() <= 6) and regex.search(customizer_main.name)
		if (isPlayernameValid):
			playerData.playername = customizer_main.name.to_upper()
			playerData.hasSignedWaiver = true
		customizer_main.don = config.main.don
		if (customizer_main.don):
			playerData.seenHint = true
			introManager = get_tree().get_root().get_child(2).get_node("standalone managers/intro manager")
		customizer_main.swap_dealer_mesh = config.main.swap_dealer_mesh
		customizer_main.multi_round_config = config.main.multi_round_config
		customizer_main.carryover = config.main.carryover
		if (customizer_main.carryover > 7 or customizer_main.carryover < 0):
			customizer_main.carryover = 4
		for key in config.customizer.round1:
			customizer_round1[key] = config.customizer.round1[key]
		for key in config.customizer.round2:
			customizer_round2[key] = config.customizer.round2[key]
		for key in config.customizer.round3:
			customizer_round3[key] = config.customizer.round3[key]
	else:
		customizer_main.enable = false	

	if (customizer_main.multi_round_config):
		customizer = [customizer_round1, customizer_round2, customizer_round3]
	else:
		customizer = [customizer_round1, customizer_round1, customizer_round1]

	for customizer_round in customizer:
		customizer_round["items"] = {
			"handsaw": [customizer_round.items_handsaw_enabled, customizer_round.items_handsaw_weight],
			"magnifying glass": [customizer_round.items_magnifyingglass_enabled, customizer_round.items_magnifyingglass_weight],
			"beer": [customizer_round.items_beer_enabled, customizer_round.items_beer_weight],
			"cigarettes": [customizer_round.items_cigarettes_enabled, customizer_round.items_cigarettes_weight],
			"handcuffs": [customizer_round.items_handcuffs_enabled, customizer_round.items_handcuffs_weight]
		}
		if (not customizer_main.multi_round_config): break

	carryover_array = [bool(int(customizer_main.carryover) % 2), bool(int(customizer_main.carryover / 2) % 2), bool(int(customizer_main.carryover / 4) % 2)]

func ShortRandom(min_val, min_min, max_val, max_max, isFloat = false):
	if (min_val == max_val) or (min_val >= max_val):
		return max(min(max_val, max_max), min_min)
	else:
		if isFloat: return randf_range(max(min_val, min_min), min(max_val, max_max))
		else: return randi_range(max(min_val, min_min), min(max_val, max_max))

func MainBatchSetup(dealerEnterAtStart : bool):
	if (not enteringFromWaiver):
		if (lerping): camera.BeginLerp("enemy")
		currentRound = 0
		if (not dealerAtTable and dealerEnterAtStart):
			await get_tree().create_timer(.5, false).timeout
			if (not dealerCuffed): animator_dealerHands.play("dealer hands on table")
			else: animator_dealerHands.play("dealer hands on table cuffed")
			animator_dealer.play("dealer return to table")
			await get_tree().create_timer(2, false).timeout
			var greeting = true
			if (isPlayernameValid):
				shellLoader.dialogue.ShowText_Forever("LET’S GET THIS OVER WITH.")
				await get_tree().create_timer(2.3, false).timeout
				shellLoader.dialogue.HideText()
				dealerHasGreeted = true
			if (not playerData.hasSignedWaiver):
				shellLoader.dialogue.ShowText_Forever("PLEASE SIGN THE WAIVER.")
				await get_tree().create_timer(2.3, false).timeout
				shellLoader.dialogue.HideText()
				camera.BeginLerp("home")
				sign.AwaitPickup()
				return
			if (not dealerHasGreeted and greeting):
				var tempstring
				if (not playerData.enteringFromTrueDeath): tempstring = "WELCOME BACK."
				else: 
					shellSpawner.dialogue.dealerLowPitched = true
					tempstring = "..."
				if (not playerData.playerEnteringFromDeath):
					shellLoader.dialogue.ShowText_Forever("WELCOME TO\nBUCKSHOT ROULETTE.")
					await get_tree().create_timer(2.3, false).timeout
					shellLoader.dialogue.HideText()
					dealerHasGreeted = true
				else:
					shellLoader.dialogue.ShowText_Forever(tempstring)
					await get_tree().create_timer(2.3, false).timeout
					shellLoader.dialogue.HideText()
					dealerHasGreeted = true
			dealerAtTable = true
	if (dealerAI.swapped and customizer_main.swap_dealer_mesh):
		dealerAI.dealermesh_crushed.set_layer_mask_value(1, false)
		dealerAI.dealermesh_normal.set_layer_mask_value(1, true)
		dealerAI.swapped = false
	enteringFromWaiver = false
	playerData.enteringFromTrueDeath = false
	mainBatchIndex = playerData.currentBatchIndex
	healthCounter.DisableCounter()
	SetupRoundArray()
	if (playerData.hasReadIntroduction): roundArray[0].hasIntroductoryText = false
	else: roundArray[0].hasIntroductoryText = true
	if (roundArray[0].showingIndicator): await(RoundIndicator())
	healthCounter.SetupHealth()
	lerping = true
	#await get_tree().create_timer(1.5, false).timeout
	StartRound(false)
	myTurnMessage = "MY TURN."
	var newDialogues = [
		"SOMETHING FEELS OFF.\nWHAT ARE YOU DOING?",
		"YOU’VE TAMPERED WITH\nTHIS GAME, HAVEN’T YOU?",
		"YOU ARE MERELY TRYING\nTO DELAY YOUR DEATH.",
		"JUST END THIS.\nWE NEED TO MOVE ON.",
		"ARE YOU JUST HERE TO SEE\nWHAT MORE I HAVE TO SAY?",
		"YOU COULD HAVE JUST\nLOOKED IN THE CODE FOR THIS.",
		"WE ARE SO CLOSE.\nSTOP THIS MADNESS.",
		"ALAS, YOUR STALLING HAS CEASED.\nDO NOT TRY ME AGAIN, " + playerData.playername + "."
	]
	if (firstRound):
		for dialogue in newDialogues:
			shellLoader.loadingDialogues.append(dialogue)

func GenerateRandomBatches():
	for b in batchArray:
		if (b.batchIndex == null): b.batchIndex = 0
		match customizer[b.batchIndex].start_round:
			1: playerStartsRound[b.batchIndex] = false
			2: playerStartsRound[b.batchIndex] = bool(randi_range(0,1))
			_: playerStartsRound[b.batchIndex] = true
		var minLives = 1
		var usingItems = customizer[b.batchIndex].items_on
		var numberOfItems = ShortRandom(customizer[b.batchIndex].items_total_min, 1, customizer[b.batchIndex].items_total_max, 8)
		if (not endless):
			match b.batchIndex:
				0:
					usingItems = false
					customizer[b.batchIndex].items_on = false
				2:
					minLives = 3
		b.roundArray[0].startingHealth = ShortRandom(customizer[b.batchIndex].lives_min, minLives, customizer[b.batchIndex].lives_max, 6)
		for i in range(b.roundArray.size()):
			if (not customizer[b.batchIndex].shells_scripted):
				var total_shells = ShortRandom(customizer[b.batchIndex].shells_total_min, 1, customizer[b.batchIndex].shells_total_max, 8)
				var amount_live
				if (customizer[b.batchIndex].shells_live_percentage_min == customizer[b.batchIndex].shells_live_percentage_max
					and customizer[b.batchIndex].shells_live_percentage_min == 0.5):
					amount_live = max(1, int(total_shells * 0.5))
				else:
					amount_live = max(1, ceili(float(total_shells) * ShortRandom(customizer[b.batchIndex].shells_live_percentage_min, 0.0, customizer[b.batchIndex].shells_live_percentage_max, 1.0, true)))
				var amount_blank = total_shells - amount_live
				b.roundArray[i].amountBlank = amount_blank
				b.roundArray[i].amountLive = amount_live

			if (not endless and b.batchIndex > 0):
				b.roundArray[i].numberOfItemsToGrab = numberOfItems
			else:
				b.roundArray[i].numberOfItemsToGrab = ShortRandom(customizer[b.batchIndex].items_total_min, 1, customizer[b.batchIndex].items_total_max, 8)
			b.roundArray[i].usingItems = usingItems
			var flip = randi_range(0, 1)
			if flip == 1: b.roundArray[i].shufflingArray = true

func SetupRoundArray():
	if (endless or customizer_main.enable): GenerateRandomBatches()
	roundArray = []
	for i in range(batchArray.size()):
		if (batchArray[i].batchIndex == mainBatchIndex):
			var matched = batchArray[i]
			for z in range(matched.roundArray.size()):
				roundArray.append(matched.roundArray[z])
				pass
	pass

func StartRound(gettingNext):
	if customizer[mainBatchIndex].items_on:
		itemManager.availableItemArray.clear()
		totalWeights = 0
		for item in customizer[mainBatchIndex].items:
			if (customizer[mainBatchIndex].items[item][0]):
				itemManager.availableItemArray.append(item)
				if (customizer[mainBatchIndex].items[item][1] < 1): customizer[mainBatchIndex].items[item][1] = 1
				if (customizer[mainBatchIndex].items[item][1] > 20): customizer[mainBatchIndex].items[item][1] = 20
				totalWeights += customizer[mainBatchIndex].items[item][1]
		if (itemManager.availableItemArray == ["cigarettes"]):
			customizer[mainBatchIndex].items_total_min = min(customizer[mainBatchIndex].items_total_min, 2)
			customizer[mainBatchIndex].items_total_max = 2
		elif (itemManager.availableItemArray.size() == 0):
			customizer[mainBatchIndex].items_on = false
			roundArray[currentRound].usingItems = false
		itemManager.availableItemsToGrabArray_player = itemManager.availableItemArray
		itemManager.availableItemsToGrabArray_dealer = itemManager.availableItemArray
		itemManager.totalWeights_player = totalWeights
		itemManager.totalWeights_dealer = totalWeights
	if (gettingNext and (currentRound +  1) != roundArray.size()): currentRound += 1
	#USINGITEMS: SETUP ITEM GRIDS IF ROUND CLASS HAS SETUP ITEM GRIDS ENABLED
	#UNCUFF BOTH PARTIES BEFORE ITEM DISTRIBUTION
	await (handcuffs.RemoveAllCuffsRoutine())
	#FINAL SHOWDOWN DIALOGUE
	if (playerData.currentBatchIndex == 2 and not defibCutterReady and not endless):
		if not playerData.hasReadItemDistributionIntro:
			playerData.hasReadItemDistributionIntro2 = true
		shellLoader.dialogue.dealerLowPitched = true
		camera.BeginLerp("enemy") 
		await get_tree().create_timer(.6, false).timeout
		#var origdelay = shellLoader.dialogue.incrementDelay
		#shellLoader.dialogue.incrementDelay = .1
		if (not playerData.cutterDialogueRead):
			shellLoader.dialogue.ShowText_Forever("AT LONG LAST, WE ARRIVE\nAT THE FINAL SHOWDOWN.")
			await get_tree().create_timer(4, false).timeout
			shellLoader.dialogue.ShowText_Forever("NO MORE DEFIBRILLATORS.\nNO MORE BLOOD TRANSFUSIONS.")
			await get_tree().create_timer(4, false).timeout
			shellLoader.dialogue.ShowText_Forever("NOW, YOU AND I, WE ARE DANCING\nON THE EDGE OF LIFE AND DEATH.")
			await get_tree().create_timer(4.8, false).timeout
			shellLoader.dialogue.HideText()
			playerData.cutterDialogueRead = true
		else:
			shellLoader.dialogue.ShowText_Forever("I BETTER NOT\nSEE YOU AGAIN.")
			await get_tree().create_timer(3, false).timeout
			shellLoader.dialogue.HideText()
		await(deficutter.InitialSetup())
		defibCutterReady = true
		trueDeathActive = true
		#await get_tree().create_timer(100, false).timeout

	var prevBatchIndex = mainBatchIndex - 1
	if (prevBatchIndex < 0): prevBatchIndex = 2
	if (roundArray[currentRound].usingItems and customizer[mainBatchIndex].items_on):
		if (currentRound > 0 or (currentRound == 0 and carryover_array[prevBatchIndex] and customizer[prevBatchIndex].items_on)):
			itemManager.newBatchHasBegun = false
			itemManager.BeginItemGrabbing()
			return
		else:
			itemManager.newBatchHasBegun = true
			itemManager.BeginItemGrabbing()
			return
	else:
		if (not firstRound and not carryover_array[prevBatchIndex] and customizer[prevBatchIndex].items_on and currentRound == 0):
			await itemManager.HideItems()
	if (currentRound <= 2 and roundArray[currentRound].amountBlank + roundArray[currentRound].amountLive == 1 and not (customizer[mainBatchIndex].shells_difficulty == 2)):
		shellLoader.loadingDialogues[currentRound] = singleShellDialogues[currentRound]
	MainShellRoutine()
	pass

func LoadShells():
	var playerStartsLoad = true
	if (currentRound != 0 or not playerStartsRound[mainBatchIndex]):
		match customizer[mainBatchIndex].start_load:
			1:
				playerStartsLoad = bool((currentRound + 1) % 2)
				if (not playerStartsRound[mainBatchIndex]): playerStartsLoad = not playerStartsLoad
			2: playerStartsLoad = not playerTurn
			_: playerStartsLoad = playerStartsRound[mainBatchIndex]
	camera.BeginLerp("enemy")
	if (not shellLoadingSpedUp): await get_tree().create_timer(.8, false).timeout
	await(shellLoader.DealerHandsGrabShotgun())
	await get_tree().create_timer(.2, false).timeout
	shellLoader.animator_shotgun.play("grab shotgun_pointing enemy")
	await get_tree().create_timer(.45, false).timeout
	if (not endless and not playerData.playerEnteringFromDeath and mainBatchIndex == 0 and playerData.numberOfDialogueRead < 12):	
		if (shellLoader.diaindex == shellLoader.loadingDialogues.size()):
			shellLoader.diaindex = 0
		shellLoader.dialogue.ShowText_ForDuration(shellLoader.loadingDialogues[shellLoader.diaindex], 3)
		shellLoader.diaindex += 1
		await get_tree().create_timer(3, false).timeout
		playerData.numberOfDialogueRead += 1
	if not (customizer[mainBatchIndex].shells_difficulty == 2):
		var numberOfShells = roundArray[currentRound].amountBlank + roundArray[currentRound].amountLive
		for i in range(numberOfShells):
			shellLoader.speaker_loadShell.play()
			shellLoader.animator_dealerHandRight.play("load single shell")
			if(shellLoadingSpedUp): await get_tree().create_timer(.17, false).timeout
			else: await get_tree().create_timer(.32, false).timeout
			pass
	shellLoader.animator_dealerHandRight.play("RESET")
	dealerAI.Speaker_HandCrack()
	if (shellLoadingSpedUp): await get_tree().create_timer(.17, false).timeout
	else: await get_tree().create_timer(.42, false).timeout
	shellLoader.animator_shotgun.play("enemy rack shotgun start")
	await get_tree().create_timer(.8, false).timeout
	shellLoader.animator_shotgun.play("enemy put down shotgun")
	shellLoader.DealerHandsDropShotgun()
	if (playerStartsLoad):
		camera.BeginLerp("home")
		await get_tree().create_timer(.6, false).timeout
		perm.SetStackInvalidIndicators()
		cursor.SetCursor(true, true)
		perm.SetIndicators(true)
		perm.SetInteractionPermissions(true)
		playerTurn = true
	else:
		await get_tree().create_timer(.6, false).timeout
		shellLoader.dialogue.ShowText_Forever(myTurnMessage)
		if (myTurnMessage == "MY TURN."):
			myTurnMessage = "MY TURN AGAIN."
		await get_tree().create_timer(1.6, false).timeout
		shellLoader.dialogue.HideText()
		await get_tree().create_timer(.2, false).timeout
		EndTurn(false)
	pass

func EndTurn(playerCanGoAgain : bool):
	if (barrelSawedOff):
		await get_tree().create_timer(.6, false).timeout
		if (waitingForHealthCheck2): await get_tree().create_timer(2, false).timeout
		waitingForHealthCheck2 = false
		await(segmentManager.GrowBarrel())
	if (shellSpawner.sequenceArray.size() != 0):
		if (playerCanGoAgain):
			BeginPlayerTurn()
		else:
			if (not dealerCuffed):
				playerTurn = false
				dealerAI.BeginDealerTurn()
			else:
				if (waitingForReturn):
					await get_tree().create_timer(1.4, false).timeout
					waitingForReturn = false
				if (waitingForHealthCheck): 
					await get_tree().create_timer(1.8, false).timeout
					waitingForHealthCheck = false
				dealerAI.DealerCheckHandCuffs()
	else:
		if (requestedWireCut):
			await(defibCutter.CutWire(wireToCut)) 
		if (not ignoring): 
			StartRound(true)

func BeginPlayerTurn():
	if (playerCuffed):
		var returning = false
		if (playerAboutToBreakFree == false):
			handcuffs.CheckPlayerHandCuffs(false)
			await get_tree().create_timer(1.4, false).timeout
			camera.BeginLerp("enemy")
			dealerAI.BeginDealerTurn()
			returning = true
			playerAboutToBreakFree = true
		else:
			handcuffs.BreakPlayerHandCuffs(false)
			await get_tree().create_timer(1.4, false).timeout
			camera.BeginLerp("home")
			playerCuffed = false
			playerAboutToBreakFree = false
			returning = false
		if (returning): return
	if (requestedWireCut):
		await(defibCutter.CutWire(wireToCut))
	await get_tree().create_timer(.6, false).timeout
	perm.SetStackInvalidIndicators()
	cursor.SetCursor(true, true)
	perm.SetIndicators(true)
	perm.SetInteractionPermissions(true)
	playerTurn = true

func MainShellRoutine():
	if (playerData.currentBatchIndex != 0):
		shellLoadingSpedUp = true
	shellSpawner.sequenceArray = []
	if (roundArray[currentRound].bootingUpCounter):
		camera.BeginLerp("health counter")
		await get_tree().create_timer(.5, false).timeout
		healthCounter.Bootup()
		await get_tree().create_timer(1.4, false).timeout
	camera.BeginLerp("shell compartment")
	await get_tree().create_timer(.5, false).timeout
	var temp_nr = roundArray[currentRound].amountBlank + roundArray[currentRound].amountLive
	var temp_live = roundArray[currentRound].amountLive
	var temp_blank = roundArray[currentRound].amountBlank
	var temp_shuf = roundArray[currentRound].shufflingArray

	for i in range(shellSpawner.spawnedShellObjectArray.size()):
		shellSpawner.spawnedShellObjectArray[i].queue_free()
	shellSpawner.spawnedShellObjectArray = []
	
	shellSpawner.sequenceArray = []
	shellSpawner.tempSequence = []
	for i in range(temp_live):
		shellSpawner.tempSequence.append("live")
	for i in range(temp_blank):
		shellSpawner.tempSequence.append("blank")
	if (temp_shuf):
		shellSpawner.tempSequence.shuffle()
	for i in range(shellSpawner.tempSequence.size()):
		shellSpawner.sequenceArray.append(shellSpawner.tempSequence[i])
		pass
	
	if not (customizer[mainBatchIndex].shells_difficulty == 2):
		shellSpawner.locationIndex = 0
		for i in range(temp_nr):
			shellSpawner.spawnedShell = shellSpawner.shellInstance.instantiate()
			shellSpawner.shellBranch = shellSpawner.spawnedShell.get_child(0)
			if (not (customizer[mainBatchIndex].shells_difficulty == 1) and shellSpawner.sequenceArray[i] == "live"):
				shellSpawner.shellBranch.isLive = true
			else: shellSpawner.shellBranch.isLive = false
			shellSpawner.shellBranch.ApplyStatus()
			shellSpawner.spawnParent.add_child(shellSpawner.spawnedShell)
			shellSpawner.spawnedShell.transform.origin = shellSpawner.shellLocationArray[shellSpawner.locationIndex]
			shellSpawner.spawnedShell.rotation_degrees = Vector3(-90, -90, 180)
			shellSpawner.spawnedShellObjectArray.append(shellSpawner.spawnedShell)
			shellSpawner.locationIndex += 1

	if not (customizer[mainBatchIndex].shells_difficulty == 2):
		shellSpawner.seq = shellSpawner.sequenceArray.duplicate()
		if (customizer[mainBatchIndex].shells_difficulty == 1):
			for i in range(shellSpawner.seq.size()):
				if (randi_range(0,1) == 1): shellSpawner.seq[i] = "live"
				else: shellSpawner.seq[i] = "blank"
		shellSpawner.anim_compartment.play("show shells")
		shellSpawner.PlayLatchSound()
		shellSpawner.PlayAudioIndicators()
		await get_tree().create_timer(1, false).timeout
	ignoring = false
	var finalstring : String
	match customizer[mainBatchIndex].shells_difficulty:
		1:
			var text_total
			if (temp_nr == 1): text_total = "ROUND."
			else: text_total = "ROUNDS."
			finalstring = str(temp_nr) + " " + text_total + " LIVE OR BLANK."
		2:
			finalstring = "NOTHING HERE FOR OUR EYES ..."
		_:
			var text_lives
			var text_blanks
			if (temp_live == 1): text_lives = "LIVE ROUND."
			else: text_lives = "LIVE ROUNDS."
			if (temp_blank == 1): text_blanks = "BLANK."
			else: text_blanks = "BLANKS."
			finalstring = str(temp_live) + " " + text_lives + " " + str(temp_blank) + " " + text_blanks
	var maindur = 1.3
	if (playerData.currentBatchIndex == 2):
		playerData.skippingShellDescription = true
	if (not playerData.skippingShellDescription or customizer[mainBatchIndex].shells_difficulty == 2):
		shellSpawner.dialogue.ShowText_Forever(finalstring)
	if (playerData.skippingShellDescription and not shellSpawner.skipDialoguePresented):
		shellSpawner.dialogue.ShowText_Forever("YOU KNOW THE DRILL.")
		maindur = 2.5
		shellSpawner.skipDialoguePresented = true
	if (not playerData.skippingShellDescription or customizer[mainBatchIndex].shells_difficulty == 2):
		await get_tree().create_timer(2.5, false).timeout
	else: await get_tree().create_timer(maindur, false).timeout
	shellSpawner.dialogue.HideText()
	if not(customizer[mainBatchIndex].shells_difficulty == 2):
		shellSpawner.anim_compartment.play("hide shells")
		shellSpawner.PlayLatchSound()
	if(shellLoadingSpedUp): await get_tree().create_timer(.2, false).timeout
	else: await get_tree().create_timer(.5, false).timeout
	if (roundArray[currentRound].insertingInRandomOrder):
		shellSpawner.sequenceArray.shuffle()
		shellSpawner.sequenceArray.shuffle()
	LoadShells()
	return

func ReturnFromItemGrabbing():
	MainShellRoutine()

func EndMainBatch():
	firstRound = false
	super.EndMainBatch()

var singleShellDialogues = [
	"I INSERT THE LONE SHELL\nINTO THE CHAMBER.",
	"IT ENTERS THE CHAMBER\nTO DO OUR BIDDING.",
	"A SINGLE SHELL\nSPELLS A CLEAR FATE."
]