extends CharacterBody2D
class_name Item


var is_grabbed : bool = false

var initial_drop_speed : int = 80


@export var item_data : ItemData

var is_grabable : bool = true


func _ready() -> void:
	assert(item_data, 'No item_data.')


func _physics_process(_delta: float) -> void:
	apply_gravity()
	move_and_slide()


func apply_gravity() -> void:
	if !is_on_floor() and !is_grabbed:
		velocity += get_gravity()
	elif is_grabbed:
		velocity.y = initial_drop_speed
		velocity.x = 0


func is_outside_left_edge() -> bool:
	if not Globals.left_boundary_marker: return false
	return position.x < Globals.left_ground_marker.position.x


func is_outside_right_edge() -> bool:
	if not Globals.right_boundary_marker: return false
	return position.x > Globals.right_ground_marker.position.x


func get_direction_to_claw() -> int:
	if get_displacement_to_claw() == 0: return 0
	return (get_displacement_to_claw()) / abs(get_displacement_to_claw())


func get_displacement_to_claw() -> int:
	return int(Globals.claw.position.x) - int(position.x)
