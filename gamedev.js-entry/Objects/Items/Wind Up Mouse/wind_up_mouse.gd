extends Item
class_name WindUpMouse

@export var speed : int = 50
@onready var direction : int = 1

@export var wind_up_timer : Timer


func _physics_process(_delta: float) -> void:
	velocity.x = speed * direction if is_on_floor() else 0
	if is_outside_right_edge():
		$AnimatedSprite2D.flip_h = false
		if wind_up_timer.is_stopped():
			wind_up_timer.start()
			direction = -1
		
			position.x -= 1
	elif is_outside_left_edge():
		$AnimatedSprite2D.flip_h = true
		if wind_up_timer.is_stopped():
			wind_up_timer.start()
			direction = 1
			
		if is_on_floor():
			position.x += 1
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = false
	if !is_grabbed and wind_up_timer.is_stopped():
		move_and_slide()
	apply_gravity()
