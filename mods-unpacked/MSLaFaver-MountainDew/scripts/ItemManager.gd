extends Object

const id = "MSLaFaver-MountainDew"

func GrabItem(chain: ModLoaderHookChain):
	var idx = ModLoader.get_node(id).RandomizeDew(chain.reference_object)
	chain.execute_next_async()
	var dews = chain.reference_object.itemSpawnParent.get_children()
	for dew in dews:
		if dew is MeshInstance3D and dew.get_node("interaction branch").itemName == "beer":
			if not dew.name.begins_with("dew"):
				dew.name = "dew%s_%s" % [idx, dew.name]
				dew.mesh = dew.mesh.duplicate()

func GrabItems_Enemy(chain: ModLoaderHookChain):
	var itemManager = chain.reference_object
	chain.execute_next_async()
	var dews = itemManager.itemSpawnParent.get_children()
	for dew in dews:
		var idx = ModLoader.get_node(id).RandomizeDew(itemManager, true)
		if dew is MeshInstance3D and dew.get_node("interaction branch").itemName == "beer":
			if not dew.name.begins_with("dew"):
				dew.name = "dew%s_%s" % [idx, dew.name]
				dew.mesh = dew.mesh.duplicate()
				dew.rotation = itemManager.instanceArray_dealer[2].rot_offset
