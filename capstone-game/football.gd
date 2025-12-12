extends RigidBody3D

var has_been_caught := false

func _physics_process(delta):
	if has_been_caught:
		return

	var ray = $GroundCheck
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider.is_in_group("ground"):
			print("INCOMPLETE PASS – ball hit ground")
			has_been_caught = true  # prevent re-entry

			# Notify the singleton (will synchronously change scene)
			GameManager.end_play("incomplete")

			# Stop the ball so it doesn't keep dealing with physics.
			freeze = true
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			visible = false
			return
