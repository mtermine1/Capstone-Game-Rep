extends CharacterBody3D

@export var speed: float = 6.0
@export var aim_speed: float = 1.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var camera = $Head/Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# Movement
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	var direction = (transform.basis * input_dir).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Arrow key aiming
	var aim_input_x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	var aim_input_y = Input.get_action_strength("aim_up") - Input.get_action_strength("aim_down")

	if aim_input_x != 0:
		rotate_y(-aim_input_x * aim_speed * delta)

	if aim_input_y != 0:
		head.rotate_x(-aim_input_y * aim_speed * delta)
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -75, 75)

	# Throw input detection
	if Input.is_action_just_pressed("throw/throw_power"):
		print("Begin throw charge...")
	if Input.is_action_just_released("throw/throw_power"):
		print("Throw released!")

	move_and_slide()
