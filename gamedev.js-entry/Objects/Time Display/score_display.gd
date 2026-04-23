extends Label


func _ready() -> void:
	ScoreKeeper.score_display = self
	visible = Globals.endless_mode
	text = "SCORE 0"
