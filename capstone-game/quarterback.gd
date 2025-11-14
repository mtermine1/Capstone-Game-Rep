extends CharacterBody3D

# Movement + mouse settings
@export var speed: float = 6.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003

# Aim settings (arrow keys)
var aim_x: float = 0.0     # horizontal aim (-left to +right)
var aim_y: float = 0.0     # vertical aim (-down to +up)
@export var aim_speed: float = 1.5   # how fast aiming moves

# Gravity from project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var camera = $Head/Camera


func _ready():
	# Lock mouse to center
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	# Mouse look
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)    # horizontal turn
		head.rotate_x(-event.relative.y * mouse_sensitivity)  # vertical tilt

		# Clamp vertical mouse look
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -75, 75)


func _physics_process(delta):
	# ----------------------------------------------------------
	# -------------- PLAYER MOVEMENT (WASD) ---------------------
	# ----------------------------------------------------------
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

	# Gravity + Jump
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	# ----------------------------------------------------------
	# ---------------------- AIMING -----------------------------
	# ----------------------------------------------------------
	var aim_input_x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	var aim_input_y = Input.get_action_strength("aim_up") - Input.get_action_strength("aim_down")

	aim_x += aim_input_x * aim_speed * delta
	aim_y += aim_input_y * aim_speed * delta

	# Clamp vertical aim [-0.5..1] ~ (-down/+up)
	aim_y = clamp(aim_y, -0.5, 1.0)

	# TEMP: Rotate head visually based on aim
	# (We will replace this when adding a crosshair and throw direction)
	head.rotation_degrees.y = aim_x * 45.0
	head.rotation_degrees.x = clamp(-aim_y * 45.0, -75, 75)

	# ----------------------------------------------------------
	# ---------------------- THROWING ---------------------------
	# ----------------------------------------------------------
	# We’ll implement the full throw mechanic next,
	# but this detects the input correctly:
	if Input.is_action_just_pressed("throw/throw_power"):
		print("Begin charging throw...")
	if Input.is_action_just_released("throw/throw_power"):
		print("Throw released!")

	# ----------------------------------------------------------
	# ------------------ FINISH MOVEMENT ------------------------
	# ----------------------------------------------------------
	move_and_slide()
