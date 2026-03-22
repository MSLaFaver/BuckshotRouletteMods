extends Object

func Hit(chain: ModLoaderHookChain):
	chain.reference_object.animator.stop()
	chain.execute_next_async()
