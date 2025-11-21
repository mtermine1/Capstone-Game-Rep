extends CharacterBody3D

@export var speed: float = 4.0
@export var cushion: float = 6.0
@export var reaction_time: float = 0.6
@export var blitz_delay: float = 7.0
@export var mode: String = "cover"

@onready var gm = get_tree().get_first_node_in_group("game_manager")
@export var target: Node3D
@export var qb: Node3D
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var was_moving := false
var has_ball := false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var reaction_timer := 0.0
var blitz_timer := 0.0
var blitz_started := false


func chase_receiver(delta):
	var dir = (target.global_position - global_position).normalized()
	velocity.x = dir.x * speed * 1.3
	velocity.z = dir.z * speed * 1.3
	update_animation()  # <- Ensure animation triggers immediately


func _physics_process(delta):      

	# After catch, always chase WR
	if qb and qb.has_ball == false and target and target.has_ball:
		chase_receiver(delta)
		move_and_slide()
		return

	if qb and not qb.play_started:
		velocity = Vector3.ZERO
		update_animation()
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


func update_animation():
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	var is_moving = horizontal_speed > 0.1

	if is_moving and not was_moving:
		print("running")
		play_run_animation()

	if not is_moving and was_moving:
		print("idling")
		play_idle_animation()

	was_moving = is_moving


func run_man_coverage(delta):
	reaction_timer += delta
	if reaction_timer < reaction_time:
		velocity.x = 0
		velocity.z = 0
		update_animation()
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

	update_animation()  # <- animation responds immediately


func run_blitz(delta):
	blitz_timer += delta
	if blitz_timer >= blitz_delay:
		blitz_started = true

	if blitz_started:
		var dir = (qb.global_position - global_position).normalized()
		velocity.x = dir.x * speed * 1.4
		velocity.z = dir.z * speed * 1.4

	update_animation()  # <- animation responds immediately


func _on_hit_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("qb") and body.has_ball:
		print("tackled qb")
		gm.end_play("tackle_qb")

	if body.is_in_group("wr") and body.has_ball:
		print("tackled wr")
		gm.end_play("tackle_wr")


func _on_catch_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("football"):
		print("Interception!")
		has_ball = true
		body.queue_free()


# -------------------------
# ANIMATION FUNCTIONS
# -------------------------

func play_run_animation():
		sprite.play("run!")

func play_idle_animation():
	sprite.stop()
	sprite.frame = 0
	
