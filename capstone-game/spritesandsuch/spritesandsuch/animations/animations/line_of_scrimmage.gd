extends Node3D

func _ready() -> void:
	var gpos := global_position
	gpos.z = GameManager.ball_spot.z
	global_position = gpos

	# Debug (temporary)
	print("LOS placing at z =", GameManager.ball_spot.z)
	print("LOS final global_position =", global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
