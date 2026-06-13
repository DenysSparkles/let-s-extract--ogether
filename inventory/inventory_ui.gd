extends Control


@onready var money_label = $MoneyLabel
@onready var pickup_label = $PickupLabel
@onready var tooltip = $"../Tooltip"
@onready var stash_grid = $StashPanel/ScrollContainer/ItemGrid
@onready var backpack_grid = $BackpackPanel/GridContainer
@export var slot_scene : PackedScene
@onready var weight_label = $BackpackPanel/WeightLabel
var backpack_inventory
var current_container : LootContainer
@onready var sell_button = $"../VendorUI/VendorPanel/Tab/SellButton/SellButton"

func _ready():
	visible = false
	pickup_label.visible = false
	backpack_inventory = GameManager.backpack_inventory
	if GameManager.game_state == GameManager.GameState.RAID:
		inventory_mode = InventoryMode.RAID
	else:
		inventory_mode = InventoryMode.LOBBY
	update_mode_ui()


func _process(delta):
	if tooltip.visible:
		tooltip.global_position = (
			get_viewport().get_mouse_position()
			+ Vector2(20, 20)
		)
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()

func update_money_ui():
	money_label.text = (
		"$" + str(GameManager.money)
	)

func toggle_inventory():

	visible = !visible

	if visible:

		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		update_inventory()
		update_mode_ui()
		update_money_ui()

	else:

		if inventory_mode == InventoryMode.VENDOR:

			return_vendor_items()

			inventory_mode = InventoryMode.LOBBY

			update_mode_ui()

		elif inventory_mode == InventoryMode.CONTAINER:
			current_container = null
			inventory_mode = InventoryMode.RAID

			update_mode_ui()

		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func update_inventory():

	clear_grid(stash_grid)
	clear_grid(backpack_grid)
	clear_grid(sell_grid)
	clear_grid(grid_container)

	render_inventory(
		GameManager.stash_inventory,
		stash_grid
	)

	render_inventory(
		backpack_inventory,
		backpack_grid
	)

	render_inventory(
		GameManager.vendor_sell_inventory,
		sell_grid
	)

	if current_container:

		render_inventory(
			current_container.inventory,
			grid_container
		)

	update_vendor_total()
	update_weight_ui()

func clear_grid(grid):
	for child in grid.get_children():
		child.queue_free()

func render_inventory(
	inventory,
	grid
):
	for i in inventory.slots.size():
		var slot = inventory.slots[i]
		if slot == null:
			continue
		var slot_ui = slot_scene.instantiate()
		grid.add_child(slot_ui)
		slot_ui.setup(
			slot,
			tooltip,
			inventory,
			i
		)

func show_pickup(item_name : String, amount : int):
	pickup_label.visible = true
	pickup_label.text = (
		"Picked up " +
		item_name +
		" x" +
		str(amount)
	)
	await get_tree().create_timer(2.0).timeout
	pickup_label.visible = false


var inventory_mode = InventoryMode.LOBBY
enum InventoryMode {
	LOBBY,
	RAID,
	VENDOR,
	CONTAINER
}

@onready var stash_panel = $StashPanel
@onready var backpack_panel = $BackpackPanel

func update_mode_ui():

	stash_panel.visible = false
	backpack_panel.visible = false
	vendor_panel.visible = false
	container_panel.visible = false
	money_label.visible = false

	match inventory_mode:

		InventoryMode.LOBBY:
			stash_panel.visible = true
			backpack_panel.visible = true
			container_panel.visible = false
			vendor_panel.visible = false

		InventoryMode.RAID:
			stash_panel.visible = false
			backpack_panel.visible = true
			container_panel.visible = false
			vendor_panel.visible = false

		InventoryMode.VENDOR:
			stash_panel.visible = true
			vendor_panel.visible = true
			money_label.visible = true

		InventoryMode.CONTAINER:
			stash_panel.visible = false
			backpack_panel.visible = true
			vendor_panel.visible = false
			container_panel.visible = true
			money_label.visible = false

func update_weight_ui():
	var inventory = GameManager.backpack_inventory
	weight_label.text = (
		str(snapped(
			inventory.get_current_weight(),
			0.1
		))
		+ " / "
		+ str(inventory.max_weight)
		+ " kg"
	)


@onready var vendor_panel = $"../VendorUI/VendorPanel"
@onready var sell_grid = $"../VendorUI/VendorPanel/Tab/SellButton/SellGrid"
@onready var total_label = $"../VendorUI/VendorPanel/Tab/SellButton/TotalMoneyLabel"


func open_vendor():
	visible = true
	inventory_mode = InventoryMode.VENDOR
	update_mode_ui()
	update_inventory()
	update_vendor_shop()
	update_money_ui()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func update_vendor_total():

	var total = (
		GameManager.vendor_sell_inventory
		.get_total_value()
	)

	total_label.text = (
		"Sell Value: $" + str(total)
	)

	sell_button.disabled = total <= 0

func _on_sell_button_pressed():
	var sell_inventory = (
		GameManager.vendor_sell_inventory
	)
	var total = (
		sell_inventory.get_total_value()
	)
	var notifications = get_tree().get_first_node_in_group(
	"notifications"
	)
	if notifications:
		notifications.add_notification(
			"Sold items for $" + str(total)
		)
	GameManager.money += total
	sell_inventory.initialize_slots()
	update_inventory()
	update_money_ui()
	SaveSystem.save_game()

func return_vendor_items():
	var vendor_inventory = (
		GameManager.vendor_sell_inventory
	)
	for i in vendor_inventory.slots.size():
		var slot = vendor_inventory.slots[i]
		if slot == null:
			continue
		GameManager.stash_inventory.add_item(
			slot.item_data,
			slot.amount
		)
		vendor_inventory.slots[i] = null
	


@export var shop_slot_scene : PackedScene
@onready var buy_grid = $"../VendorUI/VendorPanel/Tab/BuyButton/BuyGrid"
@export var vendor_data : VendorData

func update_vendor_shop():
	clear_grid(buy_grid)
	for item in vendor_data.items:
		var slot = shop_slot_scene.instantiate()
		buy_grid.add_child(slot)
		slot.setup(item,tooltip)

func is_sell_tab_active():
	var tab_container = (
		$"../VendorUI/VendorPanel/Tabs"
	)
	return tab_container.current_tab == 1


func _on_tab_tab_changed(tab):
	if tab == 0:
		return_vendor_items()
		update_inventory()


@onready var container_panel = $ContainerPanel
@onready var grid_container = $ContainerPanel/GridContainer
