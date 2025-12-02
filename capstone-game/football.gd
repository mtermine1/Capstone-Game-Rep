extends RigidBody3D

var has_been_caught := false
@export var gm: Node

func _ready():
	# Auto-assign Game Manager if not set
	if not gm:
		gm = get_tree().get_first_node_in_group("game_manager")

	# Connect GroundCheck signal
	$GroundCheck.body_entered.connect(_on_ground_hit)

func _on_ground_hit(body):
	if has_been_caught:
		return

	if body.is_in_group("ground"):
		print("INCOMPLETE PASS — ball hit ground")
		gm.end_play("incomplete")
		queue_free()
