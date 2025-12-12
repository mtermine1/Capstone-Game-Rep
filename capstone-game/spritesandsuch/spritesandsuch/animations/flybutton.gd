extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():

	
	GameManager.selected_route = "fly"

	var result = get_tree().change_scene_to_file("res://field.tscn")
	
