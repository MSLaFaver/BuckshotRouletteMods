extends Object

const id = "MSLaFaver-MountainDew"
var i = 0
var shown = false
var done = false

func LoadShells(chain: ModLoaderHookChain):
	if ModLoader.get_node(id).god_help_us_all:
		var shellLoader = chain.reference_object
		shellLoader.roundManager.shellLoadingSpedUp = false
		shellLoader.speaker_loadShell.finished.connect(func():
			i += 1
			if i >= 37 and not shown:
				shown = true
				shellLoader.dialogue.ShowText_Forever(tr("MOUNTAINDEW_JORKING"))
			if i >= 40 and not done:
				done = true
				var death = shellLoader.roundManager.death
				death.viewblocker.visible = true
				shellLoader.speaker_loadShell.volume_db = linear_to_db(0)
				shellLoader.dialogue.speaker_click.volume_db = linear_to_db(0)
				death.DisableSpeakers()
				shellLoader.roundManager.endless = true
				death.MainDeathRoutine()
		)
	chain.execute_next_async()
