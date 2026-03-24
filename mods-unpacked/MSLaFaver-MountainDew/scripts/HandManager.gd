extends Object

func BeginHandLerp(chain: ModLoaderHookChain, whichHand : String, gridIndex : int, whichSide : String):
	var itemManager = chain.reference_object.itemManager
	var pos
	if gridIndex < 8:
		pos = itemManager.gridParentArray_enemy[gridIndex].transform.origin
	else:
		pos = itemManager.gridParentArray[gridIndex - 8].transform.origin
	for dew in itemManager.itemSpawnParent.get_children():
		if abs(dew.transform.origin - pos) < Vector3(1.2,1.2,1.2) and dew.name.begins_with("dew"):
			var idx = 0
			if dew.name.begins_with("dew1"):
				idx = 1
			ModLoader.get_node("MSLaFaver-MountainDew").SetMaterial(idx)
			break
	chain.execute_next_async([whichHand, gridIndex, whichSide])
