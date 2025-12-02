extends Area3D

@export var gm: Node
@export var scoring_team: String = "player"

func _on_body_entered(body):
	if not gm:
		return

	if (
		(body.is_in_group("wr") and body.has_ball)
		or
		(body.is_in_group("qb") and body.has_ball)
	):
		print("TOUCHDOWN for ", scoring_team)
		gm.end_play("touchdown", scoring_team)
