extends Node2D
class_name LevelNode

func _ready() -> void:
	Globals.level_node = self
	ScoreKeeper.reset()
	ScoreKeeper.state = ScoreKeeper.STATE.QUEST_GIVING
