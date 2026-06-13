extends Resource
class_name LootTable

@export var entries : Array[LootEntry]

func roll_item():
	var total_weight := 0
	for entry in entries:
		total_weight += entry.weight
	var roll = randi_range(
		1,
		total_weight
	)
	var current = 0
	for entry in entries:
		current += entry.weight
		if roll <= current:
			return entry
	return null

func _process(delta):

	var result = roll_item()

	print(
		result.item.item_name
	)
