extends Node

var downs := 0
var max_downs := 2

var offense := "player"
var defense := "cpu"

var score := {
	"player": 0,
	"cpu": 0
}

var game_round := 1
var max_rounds := 4

var play_active := false


func start_play():
	if play_active:
		return
	play_active = true
	downs += 1
	print("\nPlay Started - Down:", downs, " Possession:", offense)


func end_play(reason: String):
	if not play_active:
		return
	play_active = false
	print("Play ended:", reason)

	match reason:
		"incomplete":
			handle_incomplete()

		"tackle_qb":
			handle_incomplete()

		"tackle_wr":
			handle_normal_end()

		"touchdown":
			handle_touchdown()

		_:
			print("Unhandled play result:", reason)


func handle_incomplete():
	print("Incomplete pass.")
	check_turnover()


func handle_normal_end():
	print("Ball carrier down. Play over.")
	end_drive()


func handle_touchdown():
	print("Touchdown by:", offense)
	score[offense] += 7
	end_drive()


func check_turnover():
	if downs >= max_downs:
		print("Turnover on downs!")
		switch_possession()
	else:
		print("Next down coming.")


func end_drive():
	downs = 0
	start_new_round()


func switch_possession():
	print("Possession switching.")
	if offense == "player":
		offense = "cpu"
		defense = "player"
	else:
		offense = "player"
		defense = "cpu"
	downs = 0
	start_new_round()


func start_new_round():
	game_round += 1

	if game_round > max_rounds:
		game_over()
		return
	
	print("\n--- Round", game_round, "Starting ---")
	downs = 0

func game_over():
	print("\nGame Over!")
	print("Final Score:", score)
