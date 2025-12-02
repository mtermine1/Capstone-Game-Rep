extends Node

var qb_past_los := false
var ball_spot: Vector3 = Vector3.ZERO   # where the next LOS should be
@export var line_of_scrimmage_node: Node3D
@export var qb: Node3D
var offense := "player"
var score := {"player": 0, "cpu": 0}
var down := 1
var max_downs := 4

func start_play():
	down += 1

func end_play(result: String):
	if result == "catch":
		return
	if result == "td":
		score[offense] += 7
		switch_possession()
		return
	if result in ["incomplete", "sack", "interception"]:
		if down > max_downs:
			switch_possession()
		return

func switch_possession():
	offense = "cpu" if offense == "player" else "player"
	down = 1
	
func start_play():
	qb_past_los = false
	# Position LOS at current ball spot
	if line_of_scrimmage_node:
		line_of_scrimmage_node.global_position.z = ball_spot.z

func mark_qb_past_los():
	qb_past_los = true

func end_play(result: String):
	match result:
		"catch":
			print("Play ends: catch")
			# Example: spot ball where receiver ended
			# You can refine this later
			# ball_spot = some_position
		"tackle_qb":
			print("Play ends: QB tackled")
			# ball_spot = qb.global_position
		"tackle_wr":
			print("Play ends: WR tackled")
			# ball_spot = wr.global_position
		"touchdown":
			print("TOUCHDOWN")
