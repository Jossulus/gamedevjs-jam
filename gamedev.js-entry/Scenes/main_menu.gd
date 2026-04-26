extends Node2D

@onready var start_button: Button = $UILayer/UI/CenterContainer/VBoxContainer/StartButton
@onready var classic_button: Button = $UILayer/UI/CenterContainer/VBoxContainer/ClassicButton
@onready var endless_button: Button = $UILayer/UI/CenterContainer/VBoxContainer/EndlessButton
@onready var leaderboard_button: Button = $UILayer/UI/CenterContainer/VBoxContainer/LeaderboardButton
@onready var credits_overlay: Control = $UILayer/UI/CreditsOverlay

func _ready() -> void:
	print("MainMenu loaded successfully")
	if _is_web_build():
		leaderboard_button.visible = true
		WavedashSDK.backend_connected.connect(_on_wavedash_connected)
		WavedashSDK.init({"debug": true, "deferEvents": true})
		WavedashSDK.ready_for_events()
	else:
		leaderboard_button.visible = false

func _on_wavedash_connected(_payload) -> void:
	print("Wavedash SDK connected. Playing as: ", WavedashSDK.get_username())

func _on_start_pressed() -> void:
	start_button.visible = false
	classic_button.visible = true
	endless_button.visible = true
	classic_button.grab_focus()

func _on_classic_pressed() -> void:
	Globals.endless_mode = false
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_endless_pressed() -> void:
	Globals.endless_mode = true
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_leaderboard_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Leaderboard/leaderboard.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	credits_overlay.visible = true

func _on_credits_close_pressed() -> void:
	credits_overlay.visible = false

func _on_music_slider_changed(value: float) -> void:
	var db := linear_to_db(value / 4.0) if value > 0 else -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_sound_slider_changed(value: float) -> void:
	var db := linear_to_db(value / 4.0) if value > 0 else -80.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _is_web_build() -> bool:
	return OS.get_name() == "Web"
