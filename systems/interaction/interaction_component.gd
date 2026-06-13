extends Node

@export var interaction_ray : RayCast3D

var prompt


func _ready():
	await get_tree().process_frame
	prompt = get_tree().get_first_node_in_group(
		"interact_prompt"
	)


func _physics_process(delta):
	update_prompt()
	if Input.is_action_just_pressed("interact"):
		try_interact()


func try_interact():
	if not interaction_ray.is_colliding():
		return
	var collider = interaction_ray.get_collider()
	if collider.has_method("interact"):
		collider.interact(get_parent())

func update_prompt():

	if prompt == null:
		return

	if not interaction_ray.is_colliding():

		prompt.visible = false

		return

	var collider = interaction_ray.get_collider()

	if collider.has_method("interact"):

		prompt.visible = true

		prompt.text = "[E] Interact"

	else:

		prompt.visible = false
