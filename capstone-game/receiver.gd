extends CharacterBody3D

@export var speed: float = 5.0
@export var route_distance: float = 15.0
@export var speed_after_catch: float = 6.0
@export var qb: Node3D

@onready var gm = get_tree().get_first_node_in_group("game_manager")

var start_position: Vector3
var running_route := true
var has_ball := false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	start_position = global_position

func _physics_process(delta):
	# Freeze until hike
	if qb and not qb.play_started:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# After catch, player takes control
	if has_ball:
		player_control(delta)
		move_and_slide()
		return

	# Otherwise run the assigned route
	run_route(delta)
	move_and_slide()

func run_route(delta):
	if running_route:
		var forward = -transform.basis.z
		velocity.x = forward.x * speed
		velocity.z = forward.z * speed

		if global_position.distance_to(start_position) >= route_distance:
			running_route = false
			velocity = Vector3.ZERO

func player_control(delta):
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	var move_vec = (transform.basis * input_dir).normalized()

	if move_vec != Vector3.ZERO:
		velocity.x = move_vec.x * speed_after_catch
		velocity.z = move_vec.z * speed_after_catch
	else:
		velocity.x = move_toward(velocity.x, 0, speed_after_catch)
		velocity.z = move_toward(velocity.z, 0, speed_after_catch)

func _on_catch_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("football"):
		print("Receiver caught the ball!")
		has_ball = true
		gm.end_play("catch")
		body.queue_free()
