extends "res://scripts/ItemManager.gd"

var totalWeights_player = 0
var totalWeights_dealer = 0
var itemsGrabbed = []

func BeginItemGrabbing():
	itemsGrabbed.clear()
	super.BeginItemGrabbing()

func GetRandomItemFromWeight(player)->int:
	var array
	var weights
	var index
	if (player):
		array = availableItemsToGrabArray_player
		weights = totalWeights_player
	else:
		array = availableItemsToGrabArray_dealer
		weights = totalWeights_dealer
	var random = randi_range(1, weights)
	for item in array:
		random -= roundManager.customizer[roundManager.mainBatchIndex].items[item][1]
		if (random <= 0): return array.find(item)
	return 0

func GrabItem():
	if (roundManager.playerData.currentBatchIndex == 1 and roundManager.currentRound == 1):
		if (spook_counter == 1 and not spook_fired and not roundManager.playerData.seenGod):
			GrabSpook()
			roundManager.playerData.seenGod = true
			spook_fired = true
			return
		spook_counter += 1

	if (numberOfCigs_player >= 2 and not (availableItemsToGrabArray_player == ["cigarettes"] and numberOfItemsGrabbed == 0)):
		var hasInArray = availableItemsToGrabArray_player.find("cigarettes")
		if (hasInArray != -1):
			availableItemsToGrabArray_player.erase("cigarettes")
			totalWeights_player -= roundManager.customizer[roundManager.mainBatchIndex].items["cigarettes"][1]
	elif (roundManager.customizer[roundManager.mainBatchIndex].items["cigarettes"][0]):
		var hasInArray = availableItemsToGrabArray_player.find("cigarettes")
		if (hasInArray == -1):
			availableItemsToGrabArray_player.append("cigarettes")
			totalWeights_player += roundManager.customizer[roundManager.mainBatchIndex].items["cigarettes"][1]
	if (numberOfCigs_player >= 1 and (availableItemsToGrabArray_player == ["cigarettes"] or availableItemsToGrabArray_player.size() == 0)):
		numberOfItemsGrabbed = roundManager.roundArray[roundManager.currentRound].numberOfItemsToGrab - 1
	availableItemsToGrabArray_player.shuffle()	

	#GET RANDOM ITEM
	PlayItemGrabSound()
	interaction_intake.interactionAllowed = false
	var selectedResource : ItemResource
	randindex = GetRandomItemFromWeight(true)
	numberOfItemsGrabbed += 1
	#SPAWN ITEM
	for i in range(instanceArray.size()):
		if (availableItemsToGrabArray_player[randindex] == instanceArray[i].itemName):
			selectedResource = instanceArray[i]
	var itemInstance = selectedResource.instance.instantiate()
	activeItem = itemInstance
	itemSpawnParent.add_child(itemInstance)
	itemInstance.transform.origin = selectedResource.pos_inBriefcase
	itemInstance.rotation_degrees = selectedResource.rot_inBriefcase
	activeItem_offset_pos = selectedResource.pos_offset
	activeItem_offset_rot = selectedResource.rot_offset
	#ADD ITEM TO PICKUP INDICATOR & INTERACTION BRANCH ARRAY
	if (numberOfOccupiedGrids != 8):
		temp_indicator = activeItem.get_child(0)
		temp_interaction = activeItem.get_child(1)
		items_dynamicIndicatorArray.append(temp_indicator)
		items_dynamicInteractionArray.append(temp_interaction)
		var ind = items_dynamicIndicatorArray.size() - 1
		temp_indicator.locationInDynamicArray = ind
	#DISABLE ITEM COLLIDER
	var childArray = activeItem.get_children()
	for i in childArray.size():
		if (childArray[i] is StaticBody3D): childArray[i].get_child(0).disabled = true
	#LERP TO HAND
	pos_current = itemInstance.transform.origin
	rot_current = itemInstance.rotation_degrees
	pos_next = selectedResource.pos_inHand
	rot_next = selectedResource.rot_inHand
	elapsed = 0
	moving = true
	await get_tree().create_timer(lerpDuration - .2, false).timeout
	if (not roundManager.playerData.indicatorShown): grid.ShowGridIndicator()
	if (numberOfOccupiedGrids != 8):
		itemsGrabbed.append(availableItemsToGrabArray_player[randindex])
		GridParents(true)
	else:
		#NOT ENOUGH SPACE. PUT ITEM BACK AND END ITEM GRABBING
		dialogue.ShowText_Forever("OUT OF SPACE.")
		await get_tree().create_timer(1.8, false).timeout
		dialogue.ShowText_Forever("HOW UNFORTUNATE ...")
		await get_tree().create_timer(2.2, false).timeout
		dialogue.HideText()
		pos_current = activeItem.transform.origin
		rot_current = activeItem.rotation_degrees
		pos_next = selectedResource.pos_inBriefcase
		rot_next = selectedResource.rot_inBriefcase
		elapsed = 0
		moving = true
		cursor.SetCursor(false, false)
		PlayItemGrabSound()
		await get_tree().create_timer(lerpDuration, false).timeout
		moving = false
		activeItem.queue_free()
		EndItemGrabbing()
	pass

func GrabItems_Enemy():
	var selectedResource
	var numberOfItemsGrabbed_enemy_thisLoad = 0
	for i in range(roundManager.roundArray[roundManager.currentRound].numberOfItemsToGrab):
		if (numberOfItemsGrabbed_enemy_thisLoad >= roundManager.roundArray[roundManager.currentRound].numberOfItemsToGrab): break
		if (numberOfItemsGrabbed_enemy != 8):

			if (numberOfCigs_dealer >= 2 and numberOfItemsGrabbed_enemy_thisLoad > 0 and
				(availableItemsToGrabArray_dealer == ["cigarettes"] or availableItemsToGrabArray_dealer.size() == 0)):
				break
			elif (numberOfCigs_dealer >= 2 and not (availableItemsToGrabArray_dealer == ["cigarettes"] and numberOfItemsGrabbed_enemy_thisLoad == 0)):
				var hasInArray = availableItemsToGrabArray_dealer.find("cigarettes")
				if (hasInArray != -1):
					availableItemsToGrabArray_dealer.erase("cigarettes")
					totalWeights_dealer -= roundManager.customizer[roundManager.mainBatchIndex].items["cigarettes"][1]
			elif (roundManager.customizer[roundManager.mainBatchIndex].items["cigarettes"][0]):
				var hasInArray = availableItemsToGrabArray_dealer.find("cigarettes")
				if (hasInArray == -1):
					availableItemsToGrabArray_dealer.append("cigarettes")
					totalWeights_dealer += roundManager.customizer[roundManager.mainBatchIndex].items["cigarettes"][1]
			var randindex = -1
			if (roundManager.customizer[roundManager.mainBatchIndex].items_even):
				while (randindex == -1 and not itemsGrabbed.is_empty()):
					randindex = availableItemsToGrabArray_dealer.find(itemsGrabbed[0])
					itemsGrabbed.remove_at(0)
			if (randindex == -1):
				availableItemsToGrabArray_dealer.shuffle()
				randindex = GetRandomItemFromWeight(false)
			#SPAWN ITEM
			for c in range(instanceArray_dealer.size()):
				if (availableItemArray[randindex] == instanceArray_dealer[c].itemName):
					selectedResource = instanceArray_dealer[c]
					#ADD STRING TO DEALER ITEM ARRAY
					itemArray_dealer.append(instanceArray_dealer[c].itemName)
			var itemInstance = selectedResource.instance.instantiate()
			itemInstance.visible = roundManager.customizer[roundManager.mainBatchIndex].items_visible
			var temp_itemIndicator = itemInstance.get_child(0)
			temp_itemIndicator.isDealerItem = true
			#ADD INSTANCE TO DEALER ITEM ARRAY (mida vittu this code is getting out of hand)
			itemArray_instances_dealer.append(itemInstance)
			activeItem_enemy = itemInstance
			itemSpawnParent.add_child(activeItem_enemy)
			#PLACE ITEM ON RANDOM GRID
			var randgrid = randi_range(0, gridParentArray_enemy_available.size() - 1)
			#higher than z0 is right
			var gridname = gridParentArray_enemy_available[randgrid]
			activeItem_enemy.transform.origin = gridParentArray_enemy_available[randgrid].transform.origin + selectedResource.pos_offset
			activeItem_enemy.rotation_degrees = gridParentArray_enemy_available[randgrid].rotation_degrees + selectedResource.rot_offset
			if (activeItem_enemy.transform.origin.z > 0): temp_itemIndicator.whichSide = "right"
			else: temp_itemIndicator.whichSide = "left"
			temp_itemIndicator.dealerGridIndex = gridParentArray_enemy_available[randgrid].get_child(0).activeIndex
			temp_itemIndicator.dealerGridName = gridname
			if (activeItem_enemy.get_child(1).itemName == "cigarettes"): numberOfCigs_dealer += 1
			gridParentArray_enemy_available.erase(gridname)
			numberOfItemsGrabbed_enemy += 1
			numberOfItemsGrabbed_enemy_thisLoad += 1
		pass
	pass

func HideItems():
	roundManager.ignoring = false
	numberOfItemsGrabbed = 0
	camera.BeginLerp("home")
	await get_tree().create_timer(.8, false).timeout
	comp.CycleCompartment("hide items")
	SetupItemClear()
	await get_tree().create_timer(1.4).timeout
	ClearAllItems()

# FUNCTIONS FROM SMARTERDEALER 1.1.0
func SetupItemClear()->void:
	itemArray_player = []
	await super()
	
func PlaceDownItem(gridIndex : int)->void:
	itemArray_player.append(temp_interaction.itemName)
	super(gridIndex)