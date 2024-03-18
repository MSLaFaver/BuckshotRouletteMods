extends "res://scripts/RoundManager.gd"

var enable_customization = false
var playername = ""
var don = false
var swap_dealer_mesh = false
var multi_round_config = false
var carryover = 4	# BINARY
var carryover_array
var round_order = 0

var isPlayernameValid = false
var introManager
var totalWeights
var playerStartsRound = [true, true, true]
var playerTurn = true
var firstRound = true
var myTurnMessage = "MY TURN."

var customizer
var customizer_round1 = {
	"lives_min": 2,
	"lives_max": 4,
	"shells_total_min": 2,
	"shells_total_max": 8,
	"shells_live_percentage_min": 0.5,
	"shells_live_percentage_max": 0.5,
	"items_on": true,
	"items_even": false,
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
	"start_round": 0,	# Player / Dealer / Random
	"start_load": 0		# Starter / Alternate / Persist
}
var customizer_round2 = {}
var customizer_round3 = {}

func _process(delta):
	LerpScore()
	if (don):
		if (introManager.allowingPills):
			don = false
			introManager.parent_pills.visible = false
			introManager.endlessmode.SetupEndless()

func _ready():
	HideDealer()

	for key in customizer_round1:
		customizer_round2[key] = customizer_round1[key]
		customizer_round3[key] = customizer_round1[key]

	var config_filename = OS.get_executable_path().get_base_dir()+"/config/MSLaFaver-FullCustomizer.cfg"
	var config = ConfigFile.new()
	var err = config.load(config_filename)
	
	if (err != OK):
		if FileAccess.file_exists(config_filename):
			print("ERROR: Ignored corrupted /config/MSLaFaver-FullCustomizer.cfg.")
		else:
			config.set_value("main", "enable", true)
			config.set_value("main", "name", playername)
			config.set_value("main", "don", don)
			config.set_value("main", "swap_dealer_mesh", swap_dealer_mesh)
			config.set_value("main", "multi_round_config", multi_round_config)
			config.set_value("main", "carryover", carryover)
			for key in customizer_round1: config.set_value("round1", key, customizer_round1[key])
			for key in customizer_round2: config.set_value("round2", key, customizer_round2[key])
			for key in customizer_round3: config.set_value("round3", key, customizer_round3[key])
			err = config.save(config_filename)
			if (err != OK): print("ERROR: Could not save /config/MSLaFaver-FullCustomizer.cfg.")
	elif config.get_value("main", "enable"):
		enable_customization = true
		var regex = RegEx.new()
		regex.compile("^[a-zA-Z]+$")
		playername = config.get_value("main", "name")
		isPlayernameValid = (playername.length() <= 6) && regex.search(playername)
		if (isPlayernameValid):
			playerData.playername = playername.to_upper()
			playerData.hasSignedWaiver = true
		don = config.get_value("main", "don")
		if (don):
			introManager = get_tree().get_root().get_child(2).get_node("standalone managers/intro manager")
		swap_dealer_mesh = config.get_value("main", "swap_dealer_mesh")
		multi_round_config = config.get_value("main", "multi_round_config")
		carryover = config.get_value("main", "carryover")
		if (carryover > 7 || carryover < 0):
			carryover = 4
		var keys = config.get_section_keys("round1")
		for key in keys:
			customizer_round1[key] = config.get_value("round1", key)
		keys = config.get_section_keys("round2")
		for key in keys:
			customizer_round2[key] = config.get_value("round2", key)
		keys = config.get_section_keys("round3")
		for key in keys:
			customizer_round3[key] = config.get_value("round3", key)

	if (multi_round_config):
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
		if (!multi_round_config): break

	carryover_array = [bool(carryover % 2), bool((carryover / 2) % 2), bool((carryover / 4) % 2)]

func ShortRandom(min_val, min_min, max_val, max_max, isFloat = false):
	if min_val == max_val:
		return min_val
	else:
		if isFloat: return randf_range(max(min_val, min_min), min(max_val, max_max))
		else: return randi_range(max(min_val, min_min), min(max_val, max_max))

func MainBatchSetup(dealerEnterAtStart : bool):
	if (!enteringFromWaiver):
		if (lerping): camera.BeginLerp("enemy")
		currentRound = 0
		if (!dealerAtTable && dealerEnterAtStart):
			await get_tree().create_timer(.5, false).timeout
			if (!dealerCuffed): animator_dealerHands.play("dealer hands on table")
			else: animator_dealerHands.play("dealer hands on table cuffed")
			animator_dealer.play("dealer return to table")
			await get_tree().create_timer(2, false).timeout
			var greeting = true
			if (isPlayernameValid):
				shellLoader.dialogue.ShowText_Forever("LET’S GET THIS OVER WITH.")
				await get_tree().create_timer(2.3, false).timeout
				shellLoader.dialogue.HideText()
				dealerHasGreeted = true
			if (!playerData.hasSignedWaiver):
				shellLoader.dialogue.ShowText_Forever("PLEASE SIGN THE WAIVER.")
				await get_tree().create_timer(2.3, false).timeout
				shellLoader.dialogue.HideText()
				camera.BeginLerp("home")
				sign.AwaitPickup()
				return
			if (!dealerHasGreeted && greeting):
				var tempstring
				if (!playerData.enteringFromTrueDeath): tempstring = "WELCOME BACK."
				else: 
					shellSpawner.dialogue.dealerLowPitched = true
					tempstring = "..."
				if (!playerData.playerEnteringFromDeath):
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
	if (dealerAI.swapped && swap_dealer_mesh):
		dealerAI.dealermesh_crushed.set_layer_mask_value(1, false)
		dealerAI.dealermesh_normal.set_layer_mask_value(1, true)
		dealerAI.swapped = false
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
		if (!endless):
			match b.batchIndex:
				0: usingItems = false
				1: usingItems = true
				2: minLives = 3
		for i in range(b.roundArray.size()):
			b.roundArray[i].startingHealth = ShortRandom(customizer[b.batchIndex].lives_min, minLives, customizer[b.batchIndex].lives_max, 6)
			
			var total_shells = ShortRandom(customizer[b.batchIndex].shells_total_min, 1, customizer[b.batchIndex].shells_total_max, 8)
			var amount_live = max(1, total_shells * ShortRandom(customizer[b.batchIndex].shells_live_percentage_min, 0.0, customizer[b.batchIndex].shells_live_percentage_min, 1.0, true))
			var amount_blank = total_shells - amount_live
			b.roundArray[i].amountBlank = amount_blank
			b.roundArray[i].amountLive = amount_live

			if (!endless && b.batchIndex > 0):
				b.roundArray[i].numberOfItemsToGrab = numberOfItems
			else:
				b.roundArray[i].numberOfItemsToGrab = ShortRandom(customizer[b.batchIndex].items_total_min, 1, customizer[b.batchIndex].items_total_max, 8)
			b.roundArray[i].usingItems = usingItems
			var flip = randi_range(0, 1)
			if flip == 1: b.roundArray[i].shufflingArray = true

func SetupRoundArray():
	if (endless || enable_customization): GenerateRandomBatches()
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
	if (gettingNext && (currentRound +  1) != roundArray.size()): currentRound += 1
	#USINGITEMS: SETUP ITEM GRIDS IF ROUND CLASS HAS SETUP ITEM GRIDS ENABLED
	#UNCUFF BOTH PARTIES BEFORE ITEM DISTRIBUTION
	await (handcuffs.RemoveAllCuffsRoutine())
	#FINAL SHOWDOWN DIALOGUE
	if (playerData.currentBatchIndex == 2 && !defibCutterReady && !endless):
		shellLoader.dialogue.dealerLowPitched = true
		camera.BeginLerp("enemy") 
		await get_tree().create_timer(.6, false).timeout
		#var origdelay = shellLoader.dialogue.incrementDelay
		#shellLoader.dialogue.incrementDelay = .1
		if (!playerData.cutterDialogueRead):
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
	if (roundArray[currentRound].usingItems):
		if (currentRound > 0 || (currentRound == 0 && carryover_array[prevBatchIndex] && customizer[prevBatchIndex].items_on)):
			itemManager.newBatchHasBegun = false
			itemManager.BeginItemGrabbing()
			return
		else:
			itemManager.newBatchHasBegun = true
			itemManager.BeginItemGrabbing()
			return
	else:
		if (!firstRound && !carryover_array[prevBatchIndex] && currentRound == 0):
			await itemManager.HideItems()
	if (currentRound <= 2 && roundArray[currentRound].amountBlank + roundArray[currentRound].amountLive == 1):
		shellLoader.loadingDialogues[currentRound] = singleShellDialogues[currentRound]
	shellSpawner.MainShellRoutine()
	pass

func LoadShells():
	var playerStartsLoad = true
	if (currentRound != 0 || !playerStartsRound[mainBatchIndex]):
		match customizer[mainBatchIndex].start_load:
			1:
				playerStartsLoad = bool((currentRound + 1) % 2)
				if (!playerStartsRound[mainBatchIndex]): playerStartsLoad = !playerStartsLoad
			2: playerStartsLoad = !playerTurn
			_: playerStartsLoad = playerStartsRound[mainBatchIndex]
	camera.BeginLerp("enemy")
	if (!shellLoadingSpedUp): await get_tree().create_timer(.8, false).timeout
	await(shellLoader.DealerHandsGrabShotgun())
	await get_tree().create_timer(.2, false).timeout
	shellLoader.animator_shotgun.play("grab shotgun_pointing enemy")
	await get_tree().create_timer(.45, false).timeout
	if (!endless && !playerData.playerEnteringFromDeath && mainBatchIndex == 0 && playerData.numberOfDialogueRead < 12):	
		if (shellLoader.diaindex == shellLoader.loadingDialogues.size()):
			shellLoader.diaindex = 0
		shellLoader.dialogue.ShowText_ForDuration(shellLoader.loadingDialogues[shellLoader.diaindex], 3)
		shellLoader.diaindex += 1
		await get_tree().create_timer(3, false).timeout
		playerData.numberOfDialogueRead += 1
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
	else:
		await get_tree().create_timer(.6, false).timeout
		shellLoader.dialogue.ShowText_Forever(myTurnMessage)
		if (myTurnMessage == "MY TURN."):
			myTurnMessage = "MY TURN AGAIN."
		await get_tree().create_timer(1.4, false).timeout
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
			if (!dealerCuffed):
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
		if (!ignoring): 
			StartRound(true)

func BeginPlayerTurn():
	super.BeginPlayerTurn()
	playerTurn = true

func EndMainBatch():
	firstRound = false
	super.EndMainBatch()

var singleShellDialogues = [
	"I INSERT THE LONE SHELL\nINTO THE CHAMBER.",
	"IT ENTERS THE CHAMBER\nTO DO YOUR BIDDING.",
	"A SINGLE SHELL\nSPELLS A CLEAR FATE."
]