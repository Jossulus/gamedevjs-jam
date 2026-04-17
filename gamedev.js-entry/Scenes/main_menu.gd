extends Node2D

func _ready() -> void:
	print("MainMenu loaded successfully")

func _on_start_pressed() -> void:
	print("START button pressed - attempting to load game scene")
	var result = get_tree().change_scene_to_file("res://Scenes/game.tscn")
	if result != OK:
		print("ERROR: Failed to load game scene. Error code: ", result)

func _on_quit_pressed() -> void:
	get_tree().quit()
