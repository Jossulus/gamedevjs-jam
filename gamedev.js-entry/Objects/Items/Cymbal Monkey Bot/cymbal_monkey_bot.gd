extends Item
class_name CymbalMonkeyBot

@export var speed: int = 28

@onready var spurt_timer: Timer = $SpurtTimer

var direction: int = 1
var _moving: bool = true


func _ready() -> void:
	spurt_timer.timeout.connect(_on_spurt_timer_timeout)
	spurt_timer.start(1.5)


func _physics_process(_delta: float) -> void:
	if not is_grabbed:
		velocity.x = speed * direction if (_moving and is_on_floor()) else 0

	if is_outside_right_edge():
		$AnimatedSprite2D.flip_h = false
		direction = -1
		position.x -= 1
	elif is_outside_left_edge():
		$AnimatedSprite2D.flip_h = true
		direction = 1
		position.x += 1

	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = false

	if not is_grabbed:
		move_and_slide()
	apply_gravity()
	apply_push()

	if not is_on_floor():
		velocity.x = 0
		move_and_slide()


func _on_spurt_timer_timeout() -> void:
	_moving = !_moving
	spurt_timer.start(1.5 if _moving else 1.0)
