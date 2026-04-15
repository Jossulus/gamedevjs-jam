extends CharacterBody2D
class_name Item


var is_grabbed : bool = false

var initial_drop_speed : int = 80


@export var item_data : ItemData


func _ready() -> void:
	assert(item_data, 'No item_data.')


func _physics_process(_delta: float) -> void:
	apply_gravity()


func apply_gravity() -> void:
	if !is_on_floor() and !is_grabbed:
		velocity += get_gravity()
		move_and_slide()
	else:
		velocity.y = initial_drop_speed
		velocity.x = 0


func is_outside_left_edge() -> bool:
	if not Globals.left_boundary_marker: return false
	return position.x < Globals.left_ground_marker.position.x


func is_outside_right_edge() -> bool:
	if not Globals.right_boundary_marker: return false
	return position.x > Globals.right_ground_marker.position.x
