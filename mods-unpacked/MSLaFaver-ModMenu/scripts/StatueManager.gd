extends Object

func CheckStatus(chain: ModLoaderHookChain):
	if (chain.reference_object.rm.playerData.playername == "vellon"):
		chain.reference_object.cup.visible = false
		chain.reference_object.statue.visible = true
	chain.execute_next_async()
