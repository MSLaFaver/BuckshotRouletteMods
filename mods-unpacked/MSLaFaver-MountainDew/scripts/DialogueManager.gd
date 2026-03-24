extends Object

func ShowText_ForDuration(chain: ModLoaderHookChain, activeText : String, showDuration : float):
	var mod_main = ModLoader.get_node("MSLaFaver-MountainDew")
	if mod_main.god_help_us_all:
		activeText = tr("MOUNTAINDEW_GOD HELP US ALL")
		mod_main.god_help_us_all = false
		chain.reference_object.get_node("/root/main/standalone managers/round manager").shellLoadingSpedUp = true
	chain.execute_next_async([activeText, showDuration])
