extends CharacterBody3D

@export var max_health := 100.0
var health := 100.0
var dead := false
var health_display := 100.0

@export var walk_speed := 6.0
@export var sprint_speed := 10.0
@export var crouch_speed := 3.0

@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.12

@export var standing_height := 1.8
@export var crouching_height := 1.0

@export var standing_camera_height := 1.6
@export var crouching_camera_height := 0.9

@export var crouch_lerp_speed := 10.0
var pitch := 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var current_speed := 6.0
var is_crouching := false
#===STAMINA===
@export var max_stamina := 100.0

@export var jump_stamina_cost := 15.0

@export var stamina_drain := 20.0
@export var stamina_regen := 15.0

@export var exhausted_regen_delay := 3.0
@export var normal_regen_delay := 0.8

var stamina := 100.0
var stamina_ui
var regen_timer := 0.0
var exhausted := false

@export var low_stamina_threshold := 20.0
@export var flash_speed := 8.0
#====
@onready var collision = $CollisionShape3D

@onready var head = $Head
@onready var pitch_pivot = $Head/PitchPivot
@onready var camera_bob = $Head/PitchPivot/CameraBob
@onready var camera = $Head/PitchPivot/CameraBob/Camera3D

@export var bob_frequency := 2.0
@export var bob_amplitude := 0.08

var bob_time := 0.0
var flash_time := 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().process_frame
	stamina_ui = get_tree().get_first_node_in_group(
		"stamina_ui"
	)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(
			deg_to_rad(
				-event.relative.x * mouse_sensitivity
			)
		)
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -89.0, 89.0)
		pitch_pivot.rotation_degrees.x = pitch
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta):
	if dead:
		return

	update_health_ui(delta)
	handle_gravity(delta)

	handle_jump()

	handle_crouch(delta)

	handle_speed()

	handle_movement()

	handle_headbob(delta)
	handle_stamina(delta)
	move_and_slide()



func handle_gravity(delta):

	if not is_on_floor():
		velocity.y -= gravity * delta


func handle_jump():
	if is_crouching:
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		regen_timer = 0.0
		if stamina >= jump_stamina_cost:
			stamina -= jump_stamina_cost
			velocity.y = jump_velocity
		else:
			velocity.y = jump_velocity * 0.45
			velocity.x *= 0.8
			velocity.z *= 0.8


func handle_speed():
	if is_crouching:
		current_speed = crouch_speed
	elif Input.is_action_pressed("sprint") and not is_crouching and stamina > 0:
		current_speed = sprint_speed
	else:
		current_speed = walk_speed


func handle_movement():
	var input_dir = Input.get_vector(
		"left",
		"right",
		"forward",
		"back"
	)
	var direction = (
		transform.basis *
		Vector3(input_dir.x, 0, input_dir.y)
	).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			current_speed
		)
		velocity.z = move_toward(
			velocity.z,
			0,
			current_speed
		)


func handle_crouch(delta):
	is_crouching = Input.is_action_pressed("crouch")
	var shape = collision.shape as CapsuleShape3D
	var target_height : float
	var target_camera_height : float
	if is_crouching:
		target_height = crouching_height
		target_camera_height = crouching_camera_height
	else:
		target_height = standing_height
		target_camera_height = standing_camera_height
	shape.height = lerp(
		shape.height,
		target_height,
		delta * crouch_lerp_speed
	)
	head.position.y = lerp(
		head.position.y,
		target_camera_height,
		delta * crouch_lerp_speed
	)

func handle_headbob(delta):
	var horizontal_velocity = Vector3(
		velocity.x,
		0,
		velocity.z
	).length()
	if is_on_floor() and horizontal_velocity > 0.1 and not is_crouching:
		var multiplier := 1.0
		if Input.is_action_pressed("sprint"):
			multiplier = 1.6
		elif is_crouching:
			multiplier = 0.6
		bob_time += delta * bob_frequency * multiplier
		camera_bob.position.y = lerp(
			camera_bob.position.y,
			sin(bob_time * 10.0) * bob_amplitude,
			delta * 10.0
		)
	else:
		camera_bob.position.y = lerp(
			camera_bob.position.y,
			0.0,
			delta * 10.0
		)

func handle_stamina(delta):
	var is_sprinting = (
		Input.is_action_pressed("sprint")
		and velocity.length() > 0.1
		and not is_crouching
	)
	if is_sprinting and stamina > 0:
		stamina -= stamina_drain * delta
		stamina = max(stamina, 0)
		regen_timer = 0.0
		if stamina <= 5:
			exhausted = true
	else:
		regen_timer += delta
		var required_delay := normal_regen_delay
		if exhausted:
			required_delay = exhausted_regen_delay
		if regen_timer >= required_delay:
			stamina += stamina_regen * delta
			stamina = min(stamina, max_stamina)
			if stamina > 20:
				exhausted = false
	update_stamina_ui(delta)

func update_stamina_ui(delta):
	if stamina_ui == null:
		return
	stamina_ui.value = stamina
	var should_show = (
		stamina < max_stamina
		or Input.is_action_pressed("sprint")
	)
	var target_alpha := 0.0
	if should_show:
		target_alpha = 1.0
	stamina_ui.modulate.a = lerp(
		stamina_ui.modulate.a,
		target_alpha,
		delta * 6.0
	)
	if stamina <= low_stamina_threshold:
		flash_time += delta * flash_speed
		var pulse = abs(sin(flash_time))
		stamina_ui.modulate.r = 1.0
		stamina_ui.modulate.g = pulse
		stamina_ui.modulate.b = pulse
	else:
		stamina_ui.modulate.r = 1.0
		stamina_ui.modulate.g = 1.0
		stamina_ui.modulate.b = 1.0

func take_damage(amount: float):
	if dead:
		return
	health -= amount
	health = max(health, 0)
	if health <= 0:
		die()

func die():
	dead = true
	velocity = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().create_timer(2.0).timeout
	GameManager.load_lobby()

func update_health_ui(delta):
	var bar = get_tree().get_first_node_in_group("health_ui")
	if bar == null:
		return
	health_display = lerp(health_display, health, delta * 8.0)
	bar.value = health_display

#func _input(event):

#	GameManager.money += 100

#	SaveSystem.save_game()
