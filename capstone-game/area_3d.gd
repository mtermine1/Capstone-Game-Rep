extends Area3D

@export var scoring_team: String = "player"

func _on_body_entered(body):
	if (
		(body.is_in_group("wr") and body.has_ball)
		or
		(body.is_in_group("qb") and body.has_ball)
	):
		print("TOUCHDOWN DETECTED")
		GameManager.end_play("touchdown", body.global_position)
