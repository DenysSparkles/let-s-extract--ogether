extends StaticBody3D

var deploying := false
var deploy_ui


func _ready():
	await get_tree().process_frame
	deploy_ui = get_tree().get_first_node_in_group(
		"deploy_ui"
	)


func interact(player):
	if deploying:
		return
	deploying = true
	start_deploy()


func start_deploy():
	var countdown := 3
	if deploy_ui:
		deploy_ui.visible = true
	while countdown > 0:
		if deploy_ui:
			deploy_ui.text = (
				"Deploying in " +
				str(countdown)
			)
		await get_tree().create_timer(1.0).timeout
		countdown -= 1
	if deploy_ui:
		deploy_ui.visible = false
	GameManager.load_raid()
