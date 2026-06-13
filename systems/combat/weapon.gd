extends Node3D

@export var damage := 25.0
@export var range := 100.0
@export var fire_rate := 0.2

@onready var camera = get_viewport().get_camera_3d()

var can_shoot := true

func _process(delta):
	if Input.is_action_pressed("shoot"):
		try_shoot()

func try_shoot():
	if not can_shoot:
		return
	can_shoot = false
	shoot()
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func shoot():
	var from = camera.global_position
	var to = from + camera.global_transform.basis.z * -range
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)

	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)

	if result:

		var collider = result.collider

		var enemy = collider

		if collider is Area3D:
			enemy = collider.get_parent()

		if enemy.is_in_group("enemy"):
			enemy.take_damage(damage)
