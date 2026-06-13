extends Resource
class_name ItemData

enum ItemCategory {
	NONE,
	INDUSTRIAL,
	ORGANIC,
	TECHNOLOGICAL,
	MEDICAL,
	WEAPON,
	AMMO,
	VALUABLE
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
	QUEST
}

@export var item_id : String
@export var category : ItemCategory
@export var item_name : String
@export var rarity : Rarity = Rarity.COMMON
@export var value : int = 1
@export var weight : float = 1.0
@export var max_stack : int = 20
@export var icon : Texture2D
@export_multiline var description : String

@export var pickup_scene : PackedScene


func get_category_name():

	return ItemCategory.keys()[category]

func get_rarity_name() -> String:
	return Rarity.keys()[rarity]

func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON:
			return Color(1, 1, 1, 0.15)
		Rarity.UNCOMMON:
			return Color(0, 1, 0, 0.15)
		Rarity.RARE:
			return Color(0.2, 0.5, 1, 0.15)
		Rarity.EPIC:
			return Color(0.7, 0.3, 1, 0.15)
		Rarity.LEGENDARY:
			return Color(1, 0.8, 0, 0.15)
	return Color(1, 1, 1, 0.15)

func get_rarity_multiplier():
	match rarity:
		Rarity.COMMON:
			return 1.0
		Rarity.UNCOMMON:
			return 1.5
		Rarity.RARE:
			return 2.5
		Rarity.EPIC:
			return 5.0
		Rarity.LEGENDARY:
			return 10.0
	return 1.0
