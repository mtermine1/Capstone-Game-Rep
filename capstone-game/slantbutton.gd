extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var gm = get_tree().get_first_node_in_group("game_manager")

	if not gm:
		print("❌ No GameManager found!")
		return

	print("Route BEFORE:", gm.selected_route)

	gm.selected_route = "slant"

	print("Route AFTER:", gm.selected_route)

	# 🔥 IMPORTANT FIX:
	# Tell the receiver to actually update its route right now
	if gm.receiver and gm.receiver.has_method("set_route"):
		gm.receiver.set_route("slant")
		print("Receiver route updated to slant")
	
	get_tree().change_scene_to_file("res://Field.tscn")
