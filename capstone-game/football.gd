extends RigidBody3D

var has_been_caught := false
@onready var gm = get_tree().get_first_node_in_group("game_manager")

func _physics_process(delta):
	if has_been_caught:
		return

	var ray = $GroundCheck

	# If ray hits something
	if ray.is_colliding():
		var collider = ray.get_collider()

		# Check if it's the ground
		if collider.is_in_group("ground"):
			print("INCOMPLETE PASS – ball hit ground")

			gm.end_play("incomplete")
			get_tree().change_scene_to_file("res://incomplete!.tscn")

			queue_free()
