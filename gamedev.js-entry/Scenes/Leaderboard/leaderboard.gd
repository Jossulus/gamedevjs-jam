extends Control

@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var entries_box: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/EntriesVBox

const FONT_PATH := "res://Fonts/Pix32.ttf"
const COLOR_WHITE := Color(1, 1, 1, 1)
const COLOR_BLACK := Color(0, 0, 0, 1)

var _font: Font

func _ready() -> void:
	_font = load(FONT_PATH) as Font
	_load_entries()


func _load_entries() -> void:
	_clear_entries()
	_set_status("Loading leaderboard...")

	if not _is_web_build():
		_set_status("Leaderboard is available in Web builds only.")
		return

	# Descending + numeric display so higher score ranks first.
	var leaderboard = await WavedashSDK.get_or_create_leaderboard("endless-mode", 1, 0)
	if not leaderboard.get("success", false):
		_set_status("Leaderboard unavailable.\n%s" % str(leaderboard.get("message", "Try again later.")))
		return

	var leaderboard_data = leaderboard.get("data", {})
	if not (leaderboard_data is Dictionary) or not leaderboard_data.has("id"):
		_set_status("Leaderboard unavailable.\nMissing leaderboard ID.")
		return

	var entries_result = await WavedashSDK.get_leaderboard_entries(str(leaderboard_data["id"]), 0, 10, false)
	if not entries_result.get("success", false):
		_set_status("Failed to load scores.\n%s" % str(entries_result.get("message", "Try again later.")))
		return

	var entries := _extract_entries(entries_result.get("data", null))
	if entries.is_empty():
		_set_status("No scores yet. Be the first!")
		return

	_set_status("Top 10 Endless Scores")
	_render_entries(entries)


func _extract_entries(data: Variant) -> Array:
	if data is Array:
		return data
	if data is Dictionary:
		var dict_data := data as Dictionary
		if dict_data.has("entries") and dict_data["entries"] is Array:
			return dict_data["entries"]
		if dict_data.has("rows") and dict_data["rows"] is Array:
			return dict_data["rows"]
		if dict_data.has("data") and dict_data["data"] is Array:
			return dict_data["data"]
	return []


func _render_entries(entries: Array) -> void:
	for i in range(min(entries.size(), 10)):
		var row := Label.new()
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.add_theme_font_size_override("font_size", 20)
		row.add_theme_color_override("font_color", COLOR_WHITE)
		row.add_theme_constant_override("outline_size", 2)
		row.add_theme_color_override("font_outline_color", COLOR_BLACK)
		if _font:
			row.add_theme_font_override("font", _font)

		row.text = _format_entry(entries[i], i + 1)
		entries_box.add_child(row)


func _format_entry(entry_data: Variant, fallback_rank: int) -> String:
	if not (entry_data is Dictionary):
		return "%02d. %s" % [fallback_rank, str(entry_data)]

	var entry := entry_data as Dictionary
	var rank := int(entry.get("globalRank", entry.get("rank", fallback_rank)))
	var score := int(entry.get("score", entry.get("value", 0)))
	var username := _extract_username(entry)

	return "%02d. %s - %d" % [rank, username, score]


func _extract_username(entry: Dictionary) -> String:
	var username := str(entry.get("username", ""))
	if username != "":
		return username

	var user_data: Variant = entry.get("user", null)
	if user_data is Dictionary:
		var nested_name := str(user_data.get("username", ""))
		if nested_name != "":
			return nested_name

	var user_id := str(entry.get("userId", ""))
	if user_id != "":
		var short_len: int = mini(user_id.length(), 6)
		return "Player %s" % user_id.substr(0, short_len)

	return "Anonymous"


func _set_status(text_value: String) -> void:
	status_label.text = text_value


func _clear_entries() -> void:
	for child in entries_box.get_children():
		child.queue_free()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _is_web_build() -> bool:
	return OS.get_name() == "Web"
