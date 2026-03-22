extends Object

func LoadSettings(chain: ModLoaderHookChain):
	var mod_main = ModLoader.get_node("MSLaFaver-ModMenu")
	if not mod_main.initialized:
		mod_main.initialized = true
		chain.execute_next_async()
	else:
		chain.reference_object.receivedFile = true
