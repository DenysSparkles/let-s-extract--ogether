extends Node

var current_raid := false
var stash_inventory : InventoryComponent
var backpack_inventory : InventoryComponent
var vendor_sell_inventory : InventoryComponent
var container_inventory : InventoryComponent
const LOBBY_SCENE = "res://scenes/main_lobby.tscn"
var money : int = 0

func _ready():

	initialize_game_data()

	SaveSystem.load_game()

func initialize_game_data():

	stash_inventory = InventoryComponent.new()
	stash_inventory.max_slots = 100
	stash_inventory.use_weight_limit = false
	stash_inventory.initialize_slots()


	backpack_inventory = InventoryComponent.new()
	backpack_inventory.max_slots = 500
	backpack_inventory.use_weight_limit = true
	backpack_inventory.max_weight = 100.0
	backpack_inventory.initialize_slots()


	vendor_sell_inventory = InventoryComponent.new()
	vendor_sell_inventory.max_slots = 20
	vendor_sell_inventory.use_weight_limit = false
	vendor_sell_inventory.initialize_slots()


	money = 0


func show_loading():
	set_crosshair_visible(false)
	var loading = get_tree().get_first_node_in_group(
		"loading_screen"
	)
	if loading:
		loading.visible = true

func hide_loading():
	set_crosshair_visible(true)
	var loading = get_tree().get_first_node_in_group(
		"loading_screen"
	)
	if loading:
		loading.visible = false

func load_lobby():
	show_loading()
	await get_tree().create_timer(1.0).timeout
	current_raid = false
	game_state = GameState.LOBBY
	get_tree().change_scene_to_file(
		"res://scenes/lobby/main_lobby.tscn"
	)

func load_raid():
	show_loading()
	await get_tree().create_timer(1.0).timeout
	current_raid = true
	game_state = GameState.RAID
	get_tree().change_scene_to_file(
		"res://scenes/raid/raid_map.tscn"
	)
	await get_tree().process_frame
	hide_loading()

func set_crosshair_visible(state : bool):
	var crosshair = get_tree().get_first_node_in_group(
		"crosshair"
	)
	if crosshair:
		crosshair.visible = state

enum GameState {
	LOBBY,
	RAID
}

var game_state = GameState.LOBBY
