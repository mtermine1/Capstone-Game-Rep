extends CharacterBody3D

@export var speed: float = 4.0
@export var cover_distance: float = 3.0
@export var blitz_delay: float = 7.0
@export var mode: String = "cover"   # "cover" or "blitz"
@export var target: Node3D            # receiver to cover
@export var qb: Node3D  

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var blitz_started := false
var blitz_timer := 0.0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	if mode == "cover" and target:
		run_man_coverage(delta)

	if mode == "blitz" and qb:
		run_blitz(delta)

	move_and_slide()


func run_man_coverage(delta):
	var target_pos = target.global_position
	var my_pos = global_position

	# Stay behind the receiver by cover_distance
	var desired_pos = target_pos + Vector3(0, 0, cover_distance)

	var dir = (desired_pos - my_pos).normalized()

	velocity.x = dir.x * speed
	velocity.z = dir.z * speed


func run_blitz(delta):
	blitz_timer += delta

	if blitz_timer >= blitz_delay:
		blitz_started = true

	if blitz_started:
		var dir = (qb.global_position - global_position).normalized()
		velocity.x = dir.x * speed * 1.4   # slightly faster blitz
		velocity.z = dir.z * speed * 1.4
