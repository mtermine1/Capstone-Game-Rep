extends Node3D

@export var qb: Node3D
@export var receiver: Node3D
@export var football_scene: PackedScene

var football: Node3D
var ball_spot: Vector3 = Vector3.ZERO

func start_play():
	print("Play started")

func spawn_ball():
	if football:
		football.queue_free()

	football = football_scene.instantiate()
	get_tree().current_scene.add_child(football)

	var hand_pos = qb.global_position + Vector3(0, 1.3, 0)
	football.global_position = hand_pos

func reset_play():
	var qb_pos = qb.global_position
	qb_pos.z = ball_spot.z
	qb.global_position = qb_pos
	qb.play_started = false
	qb.velocity = Vector3.ZERO
	qb.has_ball = true

	var wr_pos = receiver.global_position
	wr_pos.z = ball_spot.z
	receiver.global_position = wr_pos
	receiver.has_ball = false
	receiver.running_route = true
	receiver.route_step = 0

	spawn_ball()
	print("Ready for next play")

func end_play(result: String, ball_position: Vector3 = Vector3.ZERO):
	match result:
		"catch":
			print("Play ends: catch")

		"tackle_qb":
			print("Play ends: QB tackled")
			ball_spot = ball_position

		"tackle_wr":
			print("Play ends: WR tackled")
			ball_spot = ball_position

		"incomplete":
			print("Play ends: INCOMPLETE")

		"touchdown":
			print("TOUCHDOWN")

	reset_play()
