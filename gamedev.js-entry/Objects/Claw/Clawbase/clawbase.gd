extends Node2D
class_name ClawBase

@onready var cable_base : Sprite2D = $CableBase
@onready var cable : Sprite2D = $Cable

var base_cable_height : float

func _ready() -> void:
	base_cable_height = cable.position.y - cable.texture.get_height()/2

func _process(_delta: float) -> void:
	set_cable_height(Globals.claw.position.y - position.y)
	position.x = Globals.claw.position.x - 1

func set_cable_height(height: float) -> void:
	var length: float = height

	cable.scale.y = -get_y_scale(length)
	cable.position.y = (length/2 - base_cable_height)

func get_y_scale(length: float) -> float:
	return length / cable.texture.get_height()
