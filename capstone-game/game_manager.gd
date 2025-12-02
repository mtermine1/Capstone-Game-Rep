extends Node3D

@export var qb: Node3D
@export var receiver: Node3D

# For future use when you want to add spotting or scoring
var ball_spot: Vector3 = Vector3.ZERO


func start_play():
	print("Play started")


func end_play(result: String):
	match result:
		"incomplete":
			print("Play ends: INCOMPLETE PASS")
			# QB will regain control naturally.

		"tackle_qb":
			print("Play ends: QB TACKLED")

		"tackle_wr":
			print("Play ends: WR TACKLED")

		"touchdown":
			print("TOUCHDOWN!")

		"interception":
			print("INTERCEPTION!")

		_:
			print("Play ended with unknown result: ", result)
