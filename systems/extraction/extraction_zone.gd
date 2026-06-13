extends Area3D

var extracting := false
var player_inside := false

var extraction_ui


func _ready():

	await get_tree().process_frame
	extraction_ui = get_tree().get_first_node_in_group(
		"extraction_ui"
	)


func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	player_inside = true
	if not extracting:
		start_extraction()


func _on_body_exited(body):
	if not body.is_in_group("player"):
		return
	player_inside = false
	extracting = false
	if extraction_ui:
		extraction_ui.visible = true
		extraction_ui.text = "Extraction canceled"
		await get_tree().create_timer(1.5).timeout
		extraction_ui.visible = false
	print("Extraction canceled")


func start_extraction():
	extracting = true
	var countdown := 5
	while countdown > 0:
		if not player_inside:
			print("Extraction interrupted")
			return
		if extraction_ui:
			extraction_ui.visible = true
			extraction_ui.text = (
				"Extracting in " +
				str(countdown)
			)
		await get_tree().create_timer(1.0).timeout
		countdown -= 1
	if extraction_ui:
		extraction_ui.visible = false
	SaveSystem.save_game() # ===============================================save
	GameManager.load_lobby()
