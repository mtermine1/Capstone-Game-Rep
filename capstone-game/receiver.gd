extends CharacterBody3D

@export var speed: float = 5.0
@export var route_distance: float = 15.0
@export var qb: Node3D
@onready var gm = get_tree().get_first_node_in_group("game_manager")

var start_position: Vector3
var has_ball := false
var ball_caught := false
var running_route := true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	start_position = global_position

func _physics_process(delta):
	# STOP until hike
	if qb and not qb.play_started:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Route logic
	if running_route:
		var forward = -transform.basis.z
		velocity.x = forward.x * speed
		velocity.z = forward.z * speed

		if global_position.distance_to(start_position) >= route_distance:
			running_route = false
			velocity = Vector3.ZERO

	move_and_slide()


func _on_catch_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("football"):
		print("Receiver caught the ball!")
		ball_caught = true
		has_ball = true
		gm.end_play("catch")
		body.queue_free()


func _on_hit_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("defender"):
		gm.end_play("tackle_wr")
