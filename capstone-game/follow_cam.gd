extends Camera3D

@export var target: Node3D        # WR set from editor
@export var distance: float = -10.0
@export var height: float = 5.0
@export var follow_speed: float = 6.0

func _physics_process(delta):
	if not target:
		return

	# Desired camera position behind target
	var backward = -target.transform.basis.z
	var desired_position = target.global_position
	desired_position += backward * distance
	desired_position.y += height

	# Smooth follow
	global_position = global_position.lerp(desired_position, follow_speed * delta)

	# Look at the WR
	look_at(target.global_position, Vector3.UP)
