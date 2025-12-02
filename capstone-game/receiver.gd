extends CharacterBody3D

@export var speed: float = 4.0
@export var route_distance: float = 15.0
@export var speed_after_catch: float = 6.0
@export var qb: Node3D

@onready var gm = get_tree().get_first_node_in_group("game_manager")
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var start_position: Vector3
var running_route := true
var has_ball := false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var was_moving := false
var is_catching := false


func _ready():
	start_position = global_position


func _physics_process(delta):
	# Freeze until hike
	if qb and not qb.play_started:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Freeze while catch animation plays
	if is_catching:
		move_and_slide()
		return

	# After catch, player takes control
	if has_ball:
		player_control(delta)
		update_animation()
		move_and_slide()
		return

	# Otherwise run the assigned route
	run_route(delta)
	move_and_slide()


func update_animation():
	if is_catching:
		return

	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	var is_moving = horizontal_speed > 0.1

	if is_moving and not was_moving:
		if has_ball:
			play_run_with_ball_animation()
		else:
			play_run_animation()

	if not is_moving and was_moving:
		play_idle_animation()

	was_moving = is_moving


func run_route(delta):
	if running_route:
		var forward = -transform.basis.z
		velocity.x = forward.x * speed
		velocity.z = forward.z * speed
		update_animation()  # <- Ensure animation triggers immediately

		if global_position.distance_to(start_position) >= route_distance:
			running_route = false
			velocity = Vector3.ZERO
			update_animation()


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
	if body.is_in_group("football") and not is_catching:
		print("Receiver caught the ball!")

		has_ball = true
		body.queue_free()  # Remove football immediately

		await play_catch_animation()  # Wait for animation to finish

		qb.get_node("Head/Camera").current = false
		$"/root/Field/FollowCam".current = true

		gm.end_play("catch")


# ANIMATION FUNCTIONS

func play_run_animation():
	sprite.play("run-rc")


func play_idle_animation():
	sprite.stop()
	sprite.frame = 0


func play_catch_animation() -> void:
	if is_catching:
		return

	is_catching = true
	velocity = Vector3.ZERO

	sprite.stop()
	sprite.play("catch")

	await sprite.animation_finished

	is_catching = false
	update_animation()


func play_run_with_ball_animation():
	sprite.play("run-ball-back")
