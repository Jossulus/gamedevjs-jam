extends Item
class_name WindWizard


enum STATE { IDLE, PUSHING }
var state: STATE = STATE.IDLE

@export var speed: int = 30
@export var push_interval_min: float = 2.0
@export var push_interval_max: float = 3.5
@export var push_strength: int = 300
@export var push_distance: int = 120

@export var interval_timer: Timer

var direction: int = 1


func _ready() -> void:
	super()
	direction = [-1, 1][randi() % 2]
	_schedule_push()


func _physics_process(_delta: float) -> void:
	match state:
		STATE.IDLE:
			if is_outside_left_edge():
				direction = 1
			elif is_outside_right_edge():
				direction = -1
			velocity.x = direction * speed
		STATE.PUSHING:
			velocity.x = 0

	apply_gravity()
	if is_outside_left_edge():
		velocity.x = 1
	elif is_outside_right_edge():
		velocity.x = -1
	if is_grabbed:
		velocity = Vector2.ZERO
	move_and_slide()


func _on_push_timer_timeout() -> void:
	if is_grabbed or abs(get_displacement_to_claw()) > push_distance:
		_schedule_push()
		return
	state = STATE.PUSHING
	var push_dir: int = [-1, 1][randi() % 2]
	$AnimatedSprite2D.flip_h = push_dir < 0
	Globals.claw.push(Vector2(push_dir, -0.2).normalized(), push_strength)
	await get_tree().create_timer(0.6).timeout
	state = STATE.IDLE
	_schedule_push()


func _schedule_push() -> void:
	interval_timer.start(randf_range(push_interval_min, push_interval_max))
