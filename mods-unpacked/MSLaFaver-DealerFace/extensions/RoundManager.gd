extends "res://scripts/RoundManager.gd"

func MainBatchSetup(dealerEnterAtStart : bool):
	super.MainBatchSetup(dealerEnterAtStart)
	dealerAI.UnswapDealerMesh()
