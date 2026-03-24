extends Object

func PickupItemFromTable(chain: ModLoaderHookChain, itemParent : Node3D, passedItemName : String):
	if passedItemName == "beer":
		var idx = 0
		if itemParent.name.begins_with("dew1"):
			idx = 1
		ModLoader.get_node("MSLaFaver-MountainDew").SetMaterial(idx)
	chain.execute_next_async([itemParent, passedItemName])
