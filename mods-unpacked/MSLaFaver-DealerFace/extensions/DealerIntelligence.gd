extends "res://scripts/DealerIntelligence.gd"

func UnswapDealerMesh():
	if (swapped):
		dealermesh_crushed.set_layer_mask_value(1, false)
		dealermesh_normal.set_layer_mask_value(1, true)
		swapped = false
	pass
