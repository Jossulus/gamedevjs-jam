extends CanvasLayer

var _overlay: Control
var _title_label: Label
var _subtitle_label: Label

const FONT_PATH := "res://Fonts/Pix32.ttf"
const COLOR_GOLD := Color(1, 0.9, 0.3, 1)
const COLOR_RED := Color(1, 0.2, 0.2, 1)
const COLOR_WHITE := Color(1, 1, 1, 1)
const COLOR_BLACK := Color(0, 0, 0, 1)
const COLOR_DARK_RED := Color(0.8, 0.15, 0.15, 1)
const COLOR_BRIGHT_RED := Color(1, 0.25, 0.25, 1)
const COLOR_PANEL := Color(0, 0, 0, 0.85)
const COLOR_BG := Color(0, 0, 0, 0.75)


func _ready() -> void:
	layer = 10
	_build_ui()
	_overlay.visible = false
	ScoreKeeper.state_changed.connect(_on_state_changed)


func _build_ui() -> void:
	var font := load(FONT_PATH) as Font

	_overlay = Control.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)

	var bg := ColorRect.new()
	bg.color = COLOR_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = COLOR_PANEL
	panel_style.border_color = COLOR_GOLD
	panel_style.set_border_width_all(3)
	panel_style.set_content_margin_all(40)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_override("font", font)
	_title_label.add_theme_font_size_override("font_size", 48)
	_title_label.add_theme_constant_override("outline_size", 8)
	_title_label.add_theme_color_override("font_outline_color", COLOR_BLACK)
	vbox.add_child(_title_label)

	_subtitle_label = Label.new()
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.add_theme_font_override("font", font)
	_subtitle_label.add_theme_font_size_override("font_size", 24)
	_subtitle_label.add_theme_color_override("font_color", COLOR_WHITE)
	_subtitle_label.add_theme_constant_override("outline_size", 4)
	_subtitle_label.add_theme_color_override("font_outline_color", COLOR_BLACK)
	vbox.add_child(_subtitle_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer)

	var play_again := _make_button("Play Again", font)
	play_again.pressed.connect(func(): get_tree().reload_current_scene())
	vbox.add_child(play_again)

	var main_menu := _make_button("Main Menu", font)
	main_menu.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/main_menu.tscn"))
	vbox.add_child(main_menu)


func _make_button(label_text: String, font: Font) -> Button:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = COLOR_DARK_RED
	normal_style.border_color = COLOR_GOLD
	normal_style.set_border_width_all(2)
	normal_style.set_content_margin_all(12)
	normal_style.corner_radius_top_left = 4
	normal_style.corner_radius_top_right = 4
	normal_style.corner_radius_bottom_left = 4
	normal_style.corner_radius_bottom_right = 4

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = COLOR_BRIGHT_RED
	hover_style.border_color = COLOR_GOLD
	hover_style.set_border_width_all(2)
	hover_style.set_content_margin_all(12)
	hover_style.corner_radius_top_left = 4
	hover_style.corner_radius_top_right = 4
	hover_style.corner_radius_bottom_left = 4
	hover_style.corner_radius_bottom_right = 4

	var btn := Button.new()
	btn.text = label_text
	btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", COLOR_WHITE)
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.6, 1))
	btn.add_theme_constant_override("outline_size", 4)
	btn.add_theme_color_override("font_outline_color", COLOR_BLACK)
	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("pressed", hover_style)
	btn.add_theme_stylebox_override("focus", normal_style)
	btn.custom_minimum_size = Vector2(220, 50)
	return btn


func _on_state_changed(new_state: ScoreKeeper.STATE) -> void:
	match new_state:
		ScoreKeeper.STATE.GAME_WON:
			_title_label.text = "YOU WIN!"
			_title_label.add_theme_color_override("font_color", COLOR_GOLD)
			_subtitle_label.text = "All toys delivered!"
			_overlay.visible = true
			_disable_claw()
		ScoreKeeper.STATE.GAME_LOST:
			if Globals.endless_mode:
				_title_label.text = "GAME OVER"
				_title_label.add_theme_color_override("font_color", COLOR_RED)
				_subtitle_label.text = "Score: %d\nDeliveries: %d\nSubmitting..." % [ScoreKeeper.score, ScoreKeeper.deliveries]
				_overlay.visible = true
				_disable_claw()
				_submit_endless_score(ScoreKeeper.score)
			else:
				_title_label.text = "TIME'S UP!"
				_title_label.add_theme_color_override("font_color", COLOR_RED)
				_subtitle_label.text = "Better luck next time."
				_overlay.visible = true
				_disable_claw()


func _submit_endless_score(value: int) -> void:
	if not _is_web_build():
		_subtitle_label.text = "Score: %d\n(Leaderboard is Web-only)" % value
		return

	# Descending + numeric display so higher score ranks first.
	var leaderboard = await WavedashSDK.get_or_create_leaderboard("endless-mode", 1, 0)
	if not leaderboard.get("success", false):
		var reason := str(leaderboard.get("message", "Connection issue"))
		_subtitle_label.text = "Score: %d\n(Leaderboard unavailable)\n%s" % [value, reason]
		return

	var leaderboard_data = leaderboard.get("data", {})
	if not (leaderboard_data is Dictionary) or not leaderboard_data.has("id"):
		_subtitle_label.text = "Score: %d\n(Leaderboard unavailable)\nMissing ID" % value
		return

	var result = await WavedashSDK.post_leaderboard_score(str(leaderboard_data["id"]), value, true)
	if result.get("success", false):
		var result_data = result.get("data", {})
		var global_rank = result_data.get("globalRank", 0) if result_data is Dictionary else 0
		_subtitle_label.text = "Score: %d\nGlobal Rank: #%d" % [value, global_rank]
	else:
		var reason := str(result.get("message", "Try again later"))
		_subtitle_label.text = "Score: %d\n(Submit failed)\n%s" % [value, reason]


func _is_web_build() -> bool:
	return OS.get_name() == "Web"


func _disable_claw() -> void:
	if Globals.claw:
		Globals.claw.set_process_mode(Node.PROCESS_MODE_DISABLED)
