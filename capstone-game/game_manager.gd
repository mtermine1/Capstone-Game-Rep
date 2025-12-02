extends Node3D

var qb_past_los := false
var ball_spot: Vector3 = Vector3.ZERO

@export var line_of_scrimmage_node: Node3D
@export var qb: Node3D
@export var receiver: Node3D
@export var qb_depth: float = 1.5       # how far behind LOS QB lines up
@export var receiver_depth: float = 0.5 # how far behind LOS WR lines up (0 = on the line)


func start_play():
	qb_past_los = false
	# you can also reposition LOS from ball_spot here if you start using it
	# if line_of_scrimmage_node:
	#     line_of_scrimmage_node.global_position.z = ball_spot.z


func mark_qb_past_los():
	qb_past_los = true


func end_play(result: String):
	match result:
		"catch":
			print("Play ends: catch")
		"tackle_qb":
			print("Play ends: QB tackled")
		"tackle_wr":
			print("Play ends: WR tackled")
		"touchdown":
			print("TOUCHDOWN")

	# After logging result, prepare the next play
	reset_for_next_play()


func reset_for_next_play():
	if not line_of_scrimmage_node:
		return

	var los_z = line_of_scrimmage_node.global_position.z

	# Reset QB
	if qb:
		var qpos = qb.global_position
		qpos.z = los_z + qb_depth
		qb.global_position = qpos
		qb.play_started = false
		qb.has_ball = true

	# Reset Receiver
	if receiver:
		var rpos = receiver.global_position
		rpos.z = los_z + receiver_depth
		receiver.global_position = rpos
		receiver.start_position = rpos
		receiver.running_route = true
		receiver.has_ball = false
