extends Control


func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameManager.set_crosshair_visible(false)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		GameManager.set_crosshair_visible(true)

func _on_resume_button_pressed():
	toggle_pause()

func _on_quit_button_pressed():
	get_tree().quit()


func _on_reset_save_button_pressed():

	SaveSystem.reset_save()
