extends CharacterBody3D

@export var speed: float = 4.0
@export var speed_after_catch: float = 6.0
@export var qb: Node3D
@export var route_type: String = "curl"

#@onready var gm = gm 
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var start_position: Vector3
var running_route := true
var has_ball := false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var was_moving := false
var is_catching := false
var route_step := 0

func _ready():
	start_position = global_position
	if GameManager:
		set_route(GameManager.selected_route)


func set_route(new_route: String):
	route_type = new_route
	route_step = 0
	running_route = true
	start_position = global_position

func _physics_process(delta):
	if qb and not qb.play_started:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if is_catching:
		move_and_slide()
		return

	if has_ball:
		player_control(delta)
		update_animation()
		move_and_slide()
		return

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
	if not running_route:
		start_position = global_position
		return

	var forward = -transform.basis.z
	var right = transform.basis.x

	if route_type == "fly":
		velocity.x = forward.x * speed
		velocity.z = forward.z * speed
		update_animation()
		return

	if route_type == "slant":
		if route_step == 0:
			velocity.x = forward.x * speed
			velocity.z = forward.z * speed
			if global_position.distance_to(start_position) >= 4.0:
				route_step = 1
		elif route_step == 1:
			var slant_dir = (forward + right).normalized()
			velocity.x = slant_dir.x * speed
			velocity.z = slant_dir.z * speed
		update_animation()
		return

	if route_type == "curl":
		var curl_forward := 8.0
		var curl_return := 2.0
		var dist := global_position.distance_to(start_position)

		if route_step == 0:
			velocity.x = forward.x * speed
			velocity.z = forward.z * speed
			if dist >= curl_forward:
				route_step = 1
		elif route_step == 1:
			velocity.x = -forward.x * speed
			velocity.z = -forward.z * speed
			if dist <= curl_forward - curl_return:
				velocity = Vector3.ZERO
				#running_route = false

		update_animation()
		return

func reset_receiver():
	has_ball = false
	is_catching = false
	running_route = true
	route_step = 0
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
	if body.is_in_group("football") and not is_catching:
		print("Receiver caught the ball!")
		has_ball = true
		body.has_been_caught = true
		body.queue_free()
		await play_catch_animation()
		qb.get_node("Head/Camera").current = false
		$"/root/Field/FollowCam".current = true

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
