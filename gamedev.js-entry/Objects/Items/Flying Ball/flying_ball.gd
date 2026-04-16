extends Item
class_name FlyingBall


@export var hover_thrust : float = 1700
@export var full_thrust : float = 2000

var thrust : float: get = get_thrust

func get_thrust() -> float:
	if Input.is_action_pressed('test_push_up'): return full_thrust
	return hover_thrust

func _physics_process(delta: float) -> void:
	velocity.y -= get_thrust() * delta
	apply_gravity()
	if !is_grabbed:
		move_and_slide()
