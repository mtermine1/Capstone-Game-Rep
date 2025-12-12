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

func reset_game():
	ball_spot = Vector3(0,0,10)
	current_try = 1
	get_tree().change_scene_to_file("res://TITLESCREEN.tscn")

func reset_play(ball_pos):
	print(ball_pos)
	ball_spot = ball_pos
	
func end_play(result: String, ball_position: Vector3 = Vector3.ZERO):
	print("END PLAY TRIGGERED!")

	match result:

		"touchdown":
			print("TOUCHDOWN")
			_goto_touchdown()
			return   # ⬅️ STOP EVERYTHING

		"incomplete":
			print("Play ends: INCOMPLETE")

			if current_try >= max_tries:
				print("OUT OF TRIES! Game Over")
				_goto_gameover()
				return   # ⬅️ STOP EVERYTHING

			# Game continues
			next_try()
			_goto_incomplete_pass_scene()
			return

		"tackle_qb", "tackle_wr":
			print("Play ends:", result)
			ball_spot = ball_position

			if current_try >= max_tries:
				print("OUT OF TRIES! Game Over")
				_goto_gameover()
				return   # ⬅️ STOP EVERYTHING

			# Game continues
			next_try()
			reset_play(ball_spot)
			return


	
func _goto_gameover():
	print("Switching to game over scene")
	get_tree().change_scene_to_file("res://gameover.tscn")

func _goto_incomplete_pass_scene():
	print("Switching to incomplete pass scene")
	get_tree().change_scene_to_file("res://incomplete!.tscn")

func _goto_touchdown():
	get_tree().change_scene_to_file("res://touchdown!.tscn")
