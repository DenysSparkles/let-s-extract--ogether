extends Panel

@onready var icon = $Icon
@onready var amount_label = $AmountLabel
@onready var background = $Background


var item_data
var amount

var tooltip
var inventory
var slot_index

func setup(
	slot_data,
	tooltip_ref,
	inventory_ref,
	index
):
	item_data = slot_data.item_data
	amount = slot_data.amount
	tooltip = tooltip_ref
	inventory = inventory_ref
	slot_index = index
	icon.texture = item_data.icon
	amount_label.text = str(amount)
	
	background.color = (
		item_data.get_rarity_color()
	)


func _gui_input(event):
	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			handle_click()
		if (
			event.button_index == MOUSE_BUTTON_RIGHT
			and event.pressed
		):
			handle_drop()

func handle_click():

	var ui = get_tree().get_first_node_in_group(
		"inventory_ui"
	)

	#========================
	# CONTAINER MODE
	#========================
	if ui.inventory_mode == ui.InventoryMode.CONTAINER:

		var container_inventory = (
			ui.current_container.inventory
		)

		if inventory == container_inventory:

			inventory.transfer_slot_to(
				slot_index,
				GameManager.backpack_inventory
			)

		elif inventory == GameManager.backpack_inventory:

			inventory.transfer_slot_to(
				slot_index,
				container_inventory
			)

		ui.update_inventory()
		SaveSystem.save_game()
		return

	#========================
	# RAID
	#========================
	if GameManager.game_state == GameManager.GameState.RAID:
		return

	#========================
	# VENDOR MODE
	#========================
	if ui.inventory_mode == ui.InventoryMode.VENDOR:

		if inventory == GameManager.stash_inventory:

			inventory.transfer_slot_to(
				slot_index,
				GameManager.vendor_sell_inventory
			)

		elif inventory == GameManager.vendor_sell_inventory:

			inventory.transfer_slot_to(
				slot_index,
				GameManager.stash_inventory
			)

		ui.update_inventory()
		return

	#========================
	# NORMAL INVENTORY
	#========================

	var player_inventory = (
		GameManager.backpack_inventory
	)

	var stash_inventory = (
		GameManager.stash_inventory
	)

	if inventory == stash_inventory:

		inventory.transfer_slot_to(
			slot_index,
			player_inventory
		)

	else:

		inventory.transfer_slot_to(
			slot_index,
			stash_inventory
		)

	ui.update_inventory()

	SaveSystem.save_game()

func handle_drop():
	if GameManager.game_state != GameManager.GameState.RAID:
		return
	if inventory != GameManager.backpack_inventory:
		return
	var player = get_tree().get_first_node_in_group(
		"player"
	)
	if player == null:
		return
	var drop_position = (
		player.global_position
		+ player.global_transform.basis.z * -2.0
	)
	inventory.drop_slot(
		slot_index,
		drop_position
	)
	SaveSystem.save_game()
	var ui = get_tree().get_first_node_in_group(
		"inventory_ui"
	)
	if ui:
		ui.update_inventory()

func _on_mouse_entered():
	if tooltip == null:
		return
	tooltip.visible = true
	tooltip.get_node("Label").text = (
		item_data.item_name +
		"\n" +
		item_data.get_rarity_name() +
		"\n" +
		item_data.get_category_name() +
		"\n\n" +
		item_data.description
	)


func _on_mouse_exited():
	if tooltip == null:
		return
	tooltip.visible = false
