extends Control

func _ready() -> void:
	%StartButton.pressed.connect(_on_start_pressed)
	%QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
