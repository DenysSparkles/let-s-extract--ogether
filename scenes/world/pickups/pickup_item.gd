extends StaticBody3D

@export var item_data : ItemData
@export var amount := 1



func interact(player):
	var inventory = GameManager.backpack_inventory
	var success = inventory.add_item(
		item_data,
		amount
	)
	if success:
		SaveSystem.save_game()
		var notifications = get_tree().get_first_node_in_group(
			"notifications"
		)
		notifications.add_notification(
			"Picked up " +
			item_data.item_name +
			" x" +
			str(amount)
		)
		queue_free()

func setup_pickup(
	new_item_data,
	new_amount
):

	item_data = new_item_data
	amount = new_amount
