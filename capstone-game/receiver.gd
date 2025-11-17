extends CharacterBody3D

@export var speed: float = 5.0
@export var route_distance: float = 15.0

var start_position: Vector3
var running_route := true

func _ready():
	start_position = global_position

func _physics_process(delta):
	if running_route:
		var forward = -transform.basis.z  # forward direction in Godot
		velocity = forward * speed

		move_and_slide()

		if global_position.distance_to(start_position) >= route_distance:
			running_route = false
			velocity = Vector3.ZERO
