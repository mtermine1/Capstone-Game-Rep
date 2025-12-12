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
var receiver_in_range

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func reset_defender():
	reaction_timer = 0.0
	blitz_timer = 0.0
	blitz_started = false
	ready_played = false
	has_ball = false
	velocity = Vector3.ZERO

func _physics_process(delta):
	if qb and not qb.play_started:
		velocity = Vector3.ZERO
		if not ready_played:
			play_ready_animation()
			ready_played = true
		move_and_slide()
		return

	if ready_played and qb.play_started:
		play_idle_animation()
		ready_played = false

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	if mode == "cover" and target:
		run_man_coverage(delta)

	if mode == "blitz" and qb:
		run_blitz(delta)

	update_animation()
	move_and_slide()
	
	if receiver_in_range:
		if receiver_in_range.has_ball:
			print("tackled wr")
			velocity = Vector3.ZERO
			blitz_started = false
			GameManager.end_play("tackle_wr", receiver_in_range.global_position)
		if GameManager.current_try > GameManager.max_tries:
			call_deferred("_goto_gameover")
		else:
			call_deferred("_goto_tackled_scene")

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

func _on_hit_zone_body_entered(body):
	if body.is_in_group("qb") and body.has_ball:
		print("sacked")
		velocity = Vector3.ZERO
		blitz_started = false
		GameManager.end_play("tackle_qb", body.global_position)
		GameManager.next_try()

		if GameManager.current_try > GameManager.max_tries:
			call_deferred("_goto_gameover")
		else:
			call_deferred("_goto_tackled_scene")

	if body.is_in_group("wr"): 
		receiver_in_range = body

		


func _on_catch_zone_body_entered(body):
	if body.is_in_group("football"):
		print("Interception!")
		has_ball = true
		body.has_been_caught = true
		GameManager.next_try()

		if GameManager.current_try > GameManager.max_tries:
			call_deferred("_goto_gameover")
		else:
			call_deferred("_goto_intercept_scene")

		body.queue_free()


func play_run_animation(): sprite.play("run!")
func play_idle_animation(): sprite.play("idle")
func play_ready_animation(): sprite.play("ready")

func _on_animated_sprite_3d_animation_finished(anim):
	if anim == "ready" and qb and not qb.play_started:
		sprite.frame = 1
		sprite.playing = false

#new things im trying
func _on_hit_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("wr"):
		receiver_in_range = false

func _goto_gameover():
	if get_tree():
		get_tree().change_scene_to_file("res://gameover.tscn")

func _goto_tackled_scene():
	if get_tree():
		get_tree().change_scene_to_file("res://tackled!.tscn")

func _goto_intercept_scene():
	if get_tree():
		get_tree().change_scene_to_file("res://intercepted.tscn")
