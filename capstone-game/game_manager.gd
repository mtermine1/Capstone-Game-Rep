extends Node3D

var qb_past_los := false
var ball_spot: Vector3 = Vector3.ZERO

@export var line_of_scrimmage_node: Node3D
@export var qb: Node3D

func start_play():
	qb_past_los = false
	if line_of_scrimmage_node:
		line_of_scrimmage_node.global_position.z = ball_spot.z

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
