extends Node

var items = {}

func _ready():
	load_items()

func load_items():
	register_item(
		preload("res://resources/items/scrap.tres")
	)
	register_item(
		preload("res://resources/items/cable.tres")
	)



func register_item(item : ItemData):
	items[item.item_id] = item


func get_item(item_id : String):
	return items.get(item_id)
	
