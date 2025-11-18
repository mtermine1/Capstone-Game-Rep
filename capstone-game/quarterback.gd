extends CharacterBody3D

@onready var gm = get_tree().get_first_node_in_group("game_manager")
@export var speed: float = 6.0
@export var aim_speed: float = 1.5
@export var max_throw_power: float = 30.0

var has_ball := true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var play_started := false
var throw_power: float = 0.0
var charging_throw := false

var football_scene := preload("res://Football.tscn")

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var aim_arrow = $Head/AimArrow

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# Aiming ALWAYS allowed
	var aim_input_x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	var aim_input_y = Input.get_action_strength("aim_up") - Input.get_action_strength("aim_down")

	if aim_input_x != 0:
		rotate_y(-aim_input_x * aim_speed * delta)

	if aim_input_y != 0:
		head.rotate_x(-aim_input_y * aim_speed * delta)
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -75, 75)

	# Pre-snap: freeze movement + throw until hike
	if not play_started:
		velocity = Vector3.ZERO
		if Input.is_action_just_pressed("throw"):
			play_started = true
			gm.start_play()
			print("Hike!")
		move_and_slide()
		return

	# Movement after hike
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	var movement_dir = (transform.basis * input_dir).normalized()

	if movement_dir != Vector3.ZERO:
		velocity.x = movement_dir.x * speed
		velocity.z = movement_dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Throwing
	if Input.is_action_just_pressed("throw"):
		charging_throw = true
		throw_power = 0.0

	if charging_throw and Input.is_action_pressed("throw"):
		throw_power += 20 * delta
		throw_power = clamp(throw_power, 0, max_throw_power)
		var base_forward = -1.0
		var extension = (throw_power / max_throw_power) * 1.5
		aim_arrow.position.z = base_forward - extension

	if charging_throw and Input.is_action_just_released("throw"):
		charging_throw = false
		aim_arrow.position.z = -1.0

		var ball = football_scene.instantiate()
		get_tree().current_scene.add_child(ball)
		ball.global_position = camera.global_position + Vector3(0, 0.5, 0) + (-camera.global_transform.basis.z * 0.5)

		var throw_dir = -camera.global_transform.basis.z
		ball.linear_velocity = throw_dir * throw_power
		has_ball = false

	move_and_slide()


func _on_hit_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("defender"):
		gm.end_play("tackle_qb")
