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
			GameManager.end_play("incomplete")
			if GameManager.current_try > GameManager.max_tries:
				call_deferred("_goto_gameover")
			else:
				call_deferred("_goto_incomplete_pass_scene")
				

			queue_free()
			
			
func _goto_gameover():
	if get_tree():
		get_tree().change_scene_to_file("res://gameover.tscn")

func _goto_incomplete_pass_scene():
	if get_tree():
		get_tree().change_scene_to_file("res://incomplete_pass.tscn")
