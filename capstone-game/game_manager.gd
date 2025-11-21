extends Node

var offense := "player"
var score := {"player": 0, "cpu": 0}
var down := 1
var max_downs := 4

func start_play():
	down += 1

func end_play(result: String):
	if result == "catch":
		return
	if result == "td":
		score[offense] += 7
		switch_possession()
		return
	if result in ["incomplete", "sack", "interception"]:
		if down > max_downs:
			switch_possession()
		return

func switch_possession():
	offense = "cpu" if offense == "player" else "player"
	down = 1
