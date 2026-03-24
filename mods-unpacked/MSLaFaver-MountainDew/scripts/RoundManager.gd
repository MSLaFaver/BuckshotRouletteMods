extends Object

const id = "MSLaFaver-MountainDew"

func GenerateRandomBatches(chain: ModLoaderHookChain):
	chain.execute_next_async()
	if ModLoader.get_node(id).god_help_us_all:
		for b in chain.reference_object.batchArray:
			for i in range(b.roundArray.size()):
				b.roundArray[i].usingItems = false
