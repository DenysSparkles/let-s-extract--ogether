extends StaticBody3D
class_name LootContainer

@export var loot_table : LootTable
@export var loot_count_min := 1
@export var loot_count_max := 3

var inventory : InventoryComponent
var generated := false

func interact(player):

	if not generated:

		generate_loot()

	open_container_ui()

func generate_loot():
	generated = true
	inventory = InventoryComponent.new()
	inventory.max_slots = 20
	inventory.use_weight_limit = false
	inventory.initialize_slots()
	var count = randi_range(
		loot_count_min,
		loot_count_max
	)
	for i in count:
		var entry = loot_table.roll_item()
		if entry == null:
			continue
		var amount = randi_range(
			entry.min_amount,
			entry.max_amount
		)
		inventory.add_item(
			entry.item,
			amount
		)

func open_container_ui():
	var ui = get_tree().get_first_node_in_group(
		"inventory_ui"
	)
	if ui == null:
		return
	ui.current_container = self
	ui.inventory_mode = (
		ui.InventoryMode.CONTAINER
	)
	ui.visible = true
	ui.update_mode_ui()
	ui.update_inventory()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
