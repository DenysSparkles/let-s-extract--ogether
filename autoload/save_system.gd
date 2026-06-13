extends Node

const SAVE_PATH = "user://save.json"

func save_game():
	var data = {
		"money": GameManager.money,
		"stash": GameManager.stash_inventory.get_save_data(),
		"backpack": GameManager.backpack_inventory.get_save_data()
	}
	var file = FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)
	file.store_string(
		JSON.stringify(data, "\t")
	)
	print("Game Saved")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return
	var file = FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)
	var text = file.get_as_text()
	var json = JSON.parse_string(text)
	if json == null:
		print("Save file corrupted")
		return
	GameManager.money = json.get(
		"money",
		0
	)
	GameManager.stash_inventory.load_save_data(
		json["stash"]
	)
	GameManager.backpack_inventory.load_save_data(
		json["backpack"]
	)
	print("Game Loaded")


func reset_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(
			SAVE_PATH
		)
	print("Save Deleted")
	GameManager.initialize_game_data()
	get_tree().change_scene_to_file(
		GameManager.LOBBY_SCENE
	)
