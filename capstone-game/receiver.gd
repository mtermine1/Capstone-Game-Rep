extends CharacterBody3D

@export var speed: float = 5.0
@export var route_distance: float = 15.0
@export var qb: Node3D

var start_position: Vector3
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
	pass # Replace with function body.
