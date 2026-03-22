extends Object

const id = "MSLaFaver-ModMenu"

func SendDialogue(chain: ModLoaderHookChain):
	var mod_main = ModLoader.get_node(id)
	var config = ModLoaderConfig.get_config(id, "user")
	if not mod_main.burner_override and config != null and config.data.get("burner_fix"):
		var sequence  = chain.reference_object.sh.sequenceArray
		var length = sequence.size()
		var randindex
		var firstpart = ""
		var secondpart = ""
		var fulldia = ""
		if (length != 1):
			randindex = randi_range(1, length - 1)
			if (sequence[randindex] == "blank"): secondpart = tr("BLANKROUND") % ""
			else: secondpart = tr("LIVEROUND") % ""
			match (randindex):
				1:
					firstpart = tr("SEQUENCE2")
				2:
					firstpart = tr("SEQUENCE3")
				3:
					firstpart = tr("SEQUENCE4")
				4:
					firstpart = tr("SEQUENCE5")
				5:
					firstpart = tr("SEQUENCE6")
				6:
					firstpart = tr("SEQUENCE7")
				_:
					firstpart = tr("SEQUENCE8")
			fulldia = tr(firstpart) + "\n" + "... " + tr(secondpart)
		else: fulldia = tr("UNFORTUNATE")
		chain.reference_object.dia.ShowText_Forever(fulldia)
		await chain.reference_object.get_tree().create_timer(3, false).timeout
		chain.reference_object.dia.HideText()
	
	else:
		chain.execute_next_async()
