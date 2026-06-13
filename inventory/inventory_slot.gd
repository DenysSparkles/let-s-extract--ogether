extends RefCounted
class_name InventorySlotData

var item_data
var amount := 0


func _init(_item_data = null, _amount = 0):

	item_data = _item_data
	amount = _amount
