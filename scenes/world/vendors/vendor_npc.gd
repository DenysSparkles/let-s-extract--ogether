extends StaticBody3D


func interact(player):

	var ui = get_tree().get_first_node_in_group(
		"inventory_ui"
	)

	if ui == null:
		return

	if ui.visible:
		return

	ui.open_vendor()
