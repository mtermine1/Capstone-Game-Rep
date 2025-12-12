extends Node3D

@export var qb: Node3D
@export var receiver: Node3D
@export var football_scene: PackedScene

var football: Node3D
var ball_spot: Vector3 = Vector3(0,0,10)
var selected_route: String = "curl"

var current_try := 1
var max_tries := 4

#@onready var try_label := $"../TryLabel"

#func _ready():
		#print("Try label is: ", try_label)
#		update_try_label()


# --- TRY FUNCTIONS ---
func next_try():
	current_try += 1
	print(current_try)

	if current_try > max_tries:
		print("OUT OF TRIES! Game Over")
		current_try = 1
		#game over then after back to title screen
		get_tree().change_scene_to_file("res://gameover.tscn")

	#update_try_label()


#func update_try_label():
	#if try_label:
		#try_label.text = "Try: %d/%d" % [current_try, max_tries]

func initialize_first_snap():
	if ball_spot == Vector3.ZERO and qb:
		ball_spot = qb.global_position


func start_play():
	print("Play started")
	
	
func spawn_ball():
	if football:
		football.queue_free()

	football = football_scene.instantiate()
	get_tree().current_scene.add_child(football)
	var hand_pos = qb.global_position + Vector3(0, 1.3, 0)
	football.global_position = hand_pos


func reset_play(ball_pos):
	print(ball_pos)
	ball_spot = ball_pos
	
	##await get_tree().create_timer(0.1).timeout   # fade-out window
#
	#if receiver.has_method("reset_receiver"):
		#receiver.reset_receiver()
#
	#var qb_pos = qb.global_position
	#qb_pos.y = 1.0     # ← FIX: reposition QB above the ground
	#qb_pos.z = ball_spot.z
	#qb.global_position = qb_pos
	#qb.global_position = qb_pos
	#qb.play_started = false
	#qb.velocity = Vector3.ZERO
	#qb.has_ball = true
#
	#var wr_pos = receiver.global_position
	#wr_pos.z = ball_spot.z
	#receiver.global_position = wr_pos
#
	#for d in get_tree().get_nodes_in_group("defender"):
		#if d.has_method("reset_defender"):
			#d.reset_defender()
#
	#await get_tree().process_frame    # ← **required fix**
	#spawn_ball()
#
	#print("Ready for next play")



func end_play(result: String, ball_position: Vector3 = Vector3.ZERO):
	print("END PLAY TRIGGERED!")
	match result:
		"tackle_qb":
			print("Play ends: QB tackled")
			ball_spot = ball_position

		"tackle_wr":
			print("Play ends: WR tackled")
			ball_spot = ball_position

		"incomplete":
			print("Play ends: INCOMPLETE")

		"touchdown":
			print("TOUCHDOWN")
	next_try()

	
	reset_play(ball_spot)
	
