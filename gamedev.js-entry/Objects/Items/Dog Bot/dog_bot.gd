extends Item
class_name DogBot


enum STATE { WANDER, PLAYING }
var state: STATE = STATE.WANDER

@export var speed: int = 50
@export var yank_strength: int = 400
@export var play_duration: float = 2.5

@export var wander_interval_min: float = 1.0
@export var wander_interval_max: float = 2.5
@export var interval_timer: Timer

@export var detection_area: Area2D

var direction: int = 1


func _ready() -> void:
	super()
	direction = [-1, 1][randi() % 2]
	_new_wander_interval()
	detection_area.area_entered.connect(_on_claw_detected)


func _physics_process(_delta: float) -> void:
	match state:
		STATE.WANDER:
			if is_outside_left_edge():
				direction = 1
			elif is_outside_right_edge():
				direction = -1
			velocity.x = direction * speed
			$AnimatedSprite2D.flip_h = direction < 0
		STATE.PLAYING:
			if is_outside_left_edge():
				direction = 1
			elif is_outside_right_edge():
				direction = -1
			velocity.x = direction * speed * 1.5
			$AnimatedSprite2D.flip_h = direction < 0

	apply_gravity()
	if is_outside_left_edge():
		velocity.x = 1
	elif is_outside_right_edge():
		velocity.x = -1
	if is_grabbed:
		velocity = Vector2.ZERO
	move_and_slide()


func _on_claw_detected(area: Area2D) -> void:
	if area != Globals.claw.get_node("ClawArea"): return
	if state != STATE.WANDER: return
	state = STATE.PLAYING
	is_grabable = false
	var yank_dir := Vector2(sign(Globals.claw.global_position.x - global_position.x), -0.4).normalized()
	Globals.claw.push(yank_dir, yank_strength)
	direction = [-1, 1][randi() % 2]
	await get_tree().create_timer(play_duration).timeout
	state = STATE.WANDER
	is_grabable = true
	_new_wander_interval()


func _new_wander_interval() -> void:
	direction = [-1, 1][randi() % 2]
	interval_timer.start(randf_range(wander_interval_min, wander_interval_max))


func _on_interval_timer_timeout() -> void:
	if state == STATE.WANDER:
		_new_wander_interval()
