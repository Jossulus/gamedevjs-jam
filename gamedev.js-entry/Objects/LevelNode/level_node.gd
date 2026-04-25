extends Node2D
class_name LevelNode


@export var spawn_x_min : float = -100
@export var spawn_x_max : float = 100
@export var spawn_y : float = -60


const _ITEM_SCENES : Dictionary = {
	"Wind Up Mouse": preload("res://Objects/Items/Wind Up Mouse/wind_up_mouse.tscn"),
	"Kick Robot": preload("res://Objects/Items/Kick Robot/kick_robot.tscn"),
	"Flying Ball": preload("res://Objects/Items/Flying Ball/flying_ball.tscn"),
	"Cymbal Monkey Bot": preload("res://Objects/Items/Cymbal Monkey Bot/cymbal_monkey_bot.tscn"),
}


func _ready() -> void:
	Globals.level_node = self
	ScoreKeeper.reset_for_new_game()
	ScoreKeeper.spawn_next_item.connect(_on_spawn_next_item)
	ScoreKeeper.state = ScoreKeeper.STATE.QUEST_GIVING


func _on_spawn_next_item(data: ItemData) -> void:
	var scene : PackedScene = _ITEM_SCENES.get(data.name)
	if scene == null:
		return
	var inst := scene.instantiate()
	inst.item_data = data
	inst.position = Vector2(randf_range(spawn_x_min, spawn_x_max), spawn_y)
	add_child(inst)
