class_name InventoryComponent
extends Node

@export var max_slots := 20
var slots : Array[InventorySlotData] = []
var use_weight_limit := true
var max_weight : float = 100.0

func _ready():
	initialize_slots()

func initialize_slots():
	slots.clear()
	for i in max_slots:
		slots.append(null)

func add_item(item_data, amount := 1):
	if not can_carry(item_data, amount):
		return false
	for slot in slots:
		if slot == null:
			continue
		if slot.item_data != item_data:
			continue
		var space_left = (
			item_data.max_stack - slot.amount
		)
		if space_left <= 0:
			continue
		var add_amount = min(space_left, amount)
		slot.amount += add_amount
		amount -= add_amount
		if amount <= 0:
			return true
	for i in slots.size():
		if slots[i] != null:
			continue
		var stack_amount = min(
			item_data.max_stack,
			amount
		)
		slots[i] = InventorySlotData.new(
			item_data,
			stack_amount
		)
		amount -= stack_amount
		if amount <= 0:
			return true
	return false


func remove_slot(slot_index : int):
	if slot_index < 0:
		return
	if slot_index >= slots.size():
		return
	slots[slot_index] = null

func transfer_slot_to(
	slot_index : int,
	target_inventory : InventoryComponent
):
	if slot_index < 0:
		return false
	if slot_index >= slots.size():
		return false
	var slot = slots[slot_index]
	if slot == null:
		return false
	var success = target_inventory.add_item(
		slot.item_data,
		slot.amount
	)
	if success:
		slots[slot_index] = null
		return true
	return false

func get_current_weight():
	var total_weight := 0.0
	for slot in slots:
		if slot == null:
			continue
		total_weight += (
			slot.item_data.weight
			* slot.amount
		)
	return total_weight

func can_carry(
	item_data,
	amount
):
	if not use_weight_limit:
		return true
	var future_weight = (
		get_current_weight()
		+ item_data.weight * amount
	)
	return future_weight <= max_weight

#=============SAVE===================

func get_save_data():
	var data = []
	for slot in slots:
		if slot == null:
			data.append(null)
			continue
		data.append({
			"item_id": slot.item_data.item_id,
			"amount": slot.amount
		})
	return data

func load_save_data(data):
	initialize_slots()
	for i in data.size():
		var slot_data = data[i]
		if slot_data == null:
			continue
		var item = ItemDatabase.get_item(
			slot_data["item_id"]
		)
		if item == null:
			continue
		slots[i] = InventorySlotData.new(
			item,
			slot_data["amount"]
		)

func drop_slot(
	slot_index,
	drop_position
):
	if slot_index < 0:
		return
	if slot_index >= slots.size():
		return
	var slot = slots[slot_index]
	if slot == null:
		return
	var pickup_scene = slot.item_data.pickup_scene
	if pickup_scene == null:
		return
	var pickup = pickup_scene.instantiate()
	GameManager.get_tree().current_scene.add_child(
		pickup
	)
	pickup.global_position = drop_position
	pickup.setup_pickup(
		slot.item_data,
		slot.amount
	)
	slots[slot_index] = null

func get_carryable_amount(
	item_data,
	amount
):
	if not use_weight_limit:
		return amount
	var available_weight = (
		max_weight - get_current_weight()
	)
	var item_weight = item_data.weight
	if item_weight <= 0:
		return amount
	var max_amount = floor(
		available_weight / item_weight
	)
	return min(amount, max_amount)

func get_total_value():
	var total := 0
	for slot in slots:
		if slot == null:
			continue
		total += (
			slot.item_data.value
			* slot.amount
		)
	return total
