extends CharacterBody3D

@export var move_speed := 3.5
@export var chase_speed := 5.5

@export var attack_damage := 10.0
@export var attack_range := 2.0
@export var attack_cooldown := 1.2

@export var max_hp := 50.0
var hp := 50.0

var player = null
var state := "idle"

var can_attack := true

@export var loot_scene : PackedScene


func _physics_process(delta):
	match state:
		"idle":
			idle_state(delta)
		"chase":
			chase_state(delta)
		"attack":
			attack_state(delta)


func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		state = "chase"


func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		state = "idle"


func idle_state(delta):
	velocity.x = 0
	velocity.z = 0
	move_and_slide()


func chase_state(delta):
	if player == null:
		state = "idle"
		return

	var dir = player.global_position - global_position
	dir.y = 0
	dir = dir.normalized()

	velocity.x = dir.x * chase_speed
	velocity.z = dir.z * chase_speed

	move_and_slide()

	if global_position.distance_to(player.global_position) <= attack_range:
		state = "attack"


func attack_state(delta):
	if player == null:
		state = "idle"
		return

	if global_position.distance_to(player.global_position) > attack_range:
		state = "chase"
		return

	velocity.x = 0
	velocity.z = 0
	move_and_slide()

	if can_attack:
		attack()


func attack():
	can_attack = false

	if player and player.has_method("take_damage"):
		player.take_damage(attack_damage)

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()


func die():
	spawn_loot()
	queue_free()


func spawn_loot():
	if loot_scene == null:
		return

	var loot = loot_scene.instantiate()
	get_parent().add_child(loot)
	loot.global_position = global_position
