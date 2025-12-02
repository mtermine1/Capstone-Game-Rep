extends CharacterBody3D

@onready var gm = get_tree().get_first_node_in_group("game_manager")

@export var speed: float = 6.0
@export var aim_speed: float = 1.5
@export var max_throw_power: float = 30.0
@export var line_of_scrimmage: Node3D     # <-- NEW
var past_los := false

var has_ball := true
var play_started := false
var throw_power: float = 0.0
var charging_throw := false
@onready var ball_spawn: Node3D = $Head/Camera/BallSpawn

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var football_scene := preload("res://Football.tscn")

@onready var head = $Head
@onready var camera = $Head/Camera
@onready var aim_arrow = $Head/AimArrow
@onready var power_bar: AnimatedSprite3D = $Head/Camera/PowerBar


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	power_bar.visible = false


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	# If QB no longer has the ball (WR controls), freeze QB
	if not has_ball:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	
	

	# Aiming ALWAYS allowed
	var aim_x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	var aim_y = Input.get_action_strength("aim_up") - Input.get_action_strength("aim_down")

	if aim_x != 0:
		rotate_y(-aim_x * aim_speed * delta)
	if aim_y != 0:
		head.rotate_x(-aim_y * aim_speed * delta)
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -75, 75)

	# Pre-snap freeze
	if not play_started:
		velocity = Vector3.ZERO
		if Input.is_action_just_pressed("throw"):
			play_started = true
			gm.start_play()
			print("Hike!")
		move_and_slide()
		return

	# Post-snap movement
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	var move_vec = (transform.basis * input_dir).normalized()

	if move_vec != Vector3.ZERO:
		velocity.x = move_vec.x * speed
		velocity.z = move_vec.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0


	# START charging throw (still controlled by past_los if you keep that rule)
	if not past_los and Input.is_action_just_pressed("throw"):
		charging_throw = true
		throw_power = 0.0
		power_bar.visible = true
		power_bar.frame = 0
		power_bar.play()  # restore animation!

	# HOLDING throw
	if charging_throw and Input.is_action_pressed("throw"):
		throw_power += 8 * delta
		throw_power = clamp(throw_power, 0, max_throw_power)

		# Move arrow to show throw distance
		aim_arrow.position.z = -1.0 - (throw_power / max_throw_power) * 1.5

	# RELEASE throw
	if charging_throw and Input.is_action_just_released("throw"):
		charging_throw = false
		power_bar.visible = false
		power_bar.stop()     # stop animation!
		aim_arrow.position.z = -1.0
		_spawn_ball()

	move_and_slide()


func _spawn_ball():
	var ball = football_scene.instantiate()
	get_tree().current_scene.add_child(ball)

	# spawn from marker
	ball.global_position = ball_spawn.global_position

	# throw direction with arc
	var dir = -camera.global_transform.basis.z
	dir.y += 0.35
	dir = dir.normalized()

	# apply force to rigidbody
	ball.linear_velocity = dir * (throw_power * 1.4)

	# optional spin
	ball.apply_torque_impulse(Vector3(0, 4, 0))

	has_ball = false
