extends CharacterBody3D

@export var speed: float = 4.0
@export var cushion: float = 6.0
@export var reaction_time: float = 0.6
@export var blitz_delay: float = 7.0
@export var mode: String = "cover"
@onready var gm = get_tree().get_first_node_in_group("game_manager")
@export var target: Node3D
@export var qb: Node3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var reaction_timer := 0.0
var blitz_timer := 0.0
var blitz_started := false

func _physics_process(delta):
	if qb and not qb.play_started:
		velocity = Vector3.ZERO
		return

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
	reaction_timer += delta
	if reaction_timer < reaction_time:
		velocity.x = 0
		velocity.z = 0
		return

	var target_pos = target.global_position
	var my_pos = global_position
	var dist = my_pos.distance_to(target_pos)

	if dist > cushion:
		var chase_dir = (target_pos - my_pos).normalized()
		velocity.x = chase_dir.x * speed
		velocity.z = chase_dir.z * speed
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)

func run_blitz(delta):
	blitz_timer += delta
	if blitz_timer >= blitz_delay:
		blitz_started = true

	if blitz_started:
		var dir = (qb.global_position - global_position).normalized()
		velocity.x = dir.x * speed * 1.4
		velocity.z = dir.z * speed * 1.4


func _on_hit_zone_body_entered(body: Node3D) -> void:
	# Tackle QB only if he has ball
	if body.is_in_group("qb") and body.has_ball:
		print("tackled qb")
		gm.end_play("tackle_qb")

	# Tackle WR only if he has ball
	if body.is_in_group("wr") and body.has_ball:
		gm.end_play("tackle_wr")
