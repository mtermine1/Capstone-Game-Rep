extends CharacterBody3D

@export var speed: float = 4.0
@export var cushion: float = 6.0
@export var reaction_time: float = 0.6
@export var blitz_delay: float = 7.0
@export var mode: String = "cover"

@export var target: Node3D
@export var qb: Node3D
@onready var gm = get_tree().get_first_node_in_group("game_manager")
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var was_moving := false
var ready_played := false
var has_ball := false

var reaction_timer := 0.0
var blitz_timer := 0.0
var blitz_started := false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func reset_defender():
	reaction_timer = 0.0
	blitz_timer = 0.0
	blitz_started = false
	ready_played = false
	has_ball = false
	velocity = Vector3.ZERO


func _physics_process(delta):

	# Pre-snap freeze
	if qb and not qb.play_started:
		velocity = Vector3.ZERO
		if not ready_played:
			play_ready_animation()
			ready_played = true
		move_and_slide()
		return

	# First frame after hike → clear animation
	if ready_played and qb.play_started:
		play_idle_animation()
		ready_played = false

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# COVER OR BLITZ
	if mode == "cover" and target:
		run_man_coverage(delta)

	if mode == "blitz" and qb:
		run_blitz(delta)

	update_animation()
	move_and_slide()


func run_man_coverage(delta):
	reaction_timer += delta

	if reaction_timer < reaction_time:
		velocity.x = 0
		velocity.z = 0
		return

	var dist = global_position.distance_to(target.global_position)

	if dist > cushion:
		var chase_dir = (target.global_position - global_position).normalized()
		velocity.x = chase_dir.x * speed
		velocity.z = chase_dir.z * speed
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)


func run_blitz(delta):
	blitz_timer += delta

	# Start blitz when timer expires
	if not blitz_started and blitz_timer >= blitz_delay:
		blitz_started = true

	if blitz_started:
		var dir = (qb.global_position - global_position).normalized()
		velocity.x = dir.x * speed * 1.4
		velocity.z = dir.z * speed * 1.4


func update_animation():
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	var is_moving = horizontal_speed > 0.1

	if is_moving and not was_moving:
		play_run_animation()

	if not is_moving and was_moving:
		play_idle_animation()

	was_moving = is_moving


# HIT ZONE LOGIC
func _on_hit_zone_body_entered(body):
	if body.is_in_group("qb") and body.has_ball:
		print("tackled qb")
		gm.end_play("tackle_qb", body.global_position)

	if body.is_in_group("wr") and body.has_ball:
		print("tackled wr")
		gm.end_play("tackle_wr", body.global_position)


# CATCH / INT
func _on_catch_zone_body_entered(body):
	if body.is_in_group("football"):
		print("Interception!")
		has_ball = true
		body.has_been_caught = true
		body.queue_free()


# ANIM
func play_run_animation(): sprite.play("run!")
func play_idle_animation(): sprite.play("idle")
func play_ready_animation(): sprite.play("ready")

func _on_animated_sprite_3d_animation_finished(anim):
	if anim == "ready" and qb and not qb.play_started:
		sprite.frame = 1
		sprite.playing = false
