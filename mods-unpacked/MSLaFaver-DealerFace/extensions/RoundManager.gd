extends "res://scripts/RoundManager.gd"

func MainBatchSetup(dealerEnterAtStart : bool):
	super.MainBatchSetup(dealerEnterAtStart)
	if (dealerAI.swapped):
		dealerAI.dealermesh_crushed.set_layer_mask_value(1, false)
		dealerAI.dealermesh_normal.set_layer_mask_value(1, true)
		dealerAI.swapped = false
