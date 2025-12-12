extends Button

func _ready() -> void:
	self.modulate.a = 0.0
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	GameManager.reset_game()   # ⬅️ ADD THIS
	get_tree().change_scene_to_file("res://pickaplay.tscn")
