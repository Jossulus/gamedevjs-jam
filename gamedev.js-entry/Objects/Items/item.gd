extends CharacterBody2D
class_name Item


var is_grabbed : bool = false

var initial_drop_speed : int = 80


func _physics_process(_delta: float) -> void:
	if !is_on_floor() and !is_grabbed:
		velocity += get_gravity()
		move_and_slide()
	else:
		velocity.y = initial_drop_speed
	
