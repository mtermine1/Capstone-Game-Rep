extends Area3D

@export var gm: Node3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("qb") and body.has_ball and gm:
		gm.mark_qb_past_los()
		print("QB crossed line of scrimmage")
