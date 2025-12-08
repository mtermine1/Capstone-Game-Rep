extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed():
	var gm = get_tree().get_first_node_in_group("game_manager")
	gm.selected_route = "slant"
	get_tree().change_scene_to_file("res://field.tscn")
