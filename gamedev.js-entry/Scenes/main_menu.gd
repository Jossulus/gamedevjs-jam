extends Node2D

func _ready() -> void:
	print("MainMenu loaded successfully")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_music_slider_changed(value: float) -> void:
	var db := linear_to_db(value / 4.0) if value > 0 else -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_sound_slider_changed(value: float) -> void:
	var db := linear_to_db(value / 4.0) if value > 0 else -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
