extends Item
class_name KickRobot


enum STATE{WANDER, CHASE, JUMP, LAND}
var state : STATE = STATE.WANDER

@export var speed : int = 20
var direction : int = 0

@export var wander_interval_min : int
@export var wander_interval_max : int

@export var interval_timer : Timer

@export var aggro_distance : int = 100

@export var jump_distance : int = 20

var jump_height : int: get = get_jump_height

@export var max_jump_height : int = 30

var push_velocity : Vector2


var push_velocity_length_cutoff : int = 5

@export var push_strength : int = 200

@export var push_claw_distance : int = 10
@export var push_claw_strength : int = 500


func get_jump_height() -> int:
	var clamped_jump_height : int = clampi(int(position.y - Globals.claw.position.y), 0,max_jump_height)
	if clamped_jump_height < 5: return 5
	return clamped_jump_height



func change_state(new_state : STATE) -> void:
	match state:
		STATE.WANDER:
			pass
		STATE.CHASE:
			pass
		STATE.JUMP:
			pass
		STATE.LAND:
			pass
	state = new_state
	match state:
		STATE.WANDER:
			is_grabable = true
			await get_tree().create_timer(1).timeout
			new_wander_interval()
		STATE.CHASE:
			pass
		STATE.JUMP:
			#is_grabable = false
			velocity.x = 0
			$AnimatedSprite2D.play("awake")
			await $AnimatedSprite2D.animation_finished
			velocity.y = -sqrt((2 * get_gravity().y * jump_height)/get_physics_process_delta_time())
		STATE.LAND:
			$AnimatedSprite2D.play("kick")
			push(position.direction_to(Globals.claw.position), push_strength)


func _physics_process(delta: float) -> void:
	print(state)
	if get_direction_to_claw() < 0:
		$AnimatedSprite2D.flip_h = false
	elif get_direction_to_claw() > 0:
		$AnimatedSprite2D.flip_h = true
	match state:
		STATE.WANDER:
			if abs(get_displacement_to_claw()) <= aggro_distance:
				change_state(STATE.CHASE)
			if is_outside_left_edge():
				direction = 1
			elif is_outside_right_edge():
				direction = -1
			velocity.x = direction * speed
			if velocity.x != 0:
				$AnimatedSprite2D.play('run')
			else:
				$AnimatedSprite2D.play("idle")
		STATE.CHASE:
			$AnimatedSprite2D.play("run")
			velocity.x = get_direction_to_claw() * speed
			if abs(get_displacement_to_claw()) <= jump_distance:
				change_state(STATE.JUMP)
			elif abs(get_displacement_to_claw()) > aggro_distance:
				change_state(STATE.WANDER)
		STATE.JUMP:
			if velocity.y > 0:
				change_state(STATE.LAND)
		STATE.LAND:
			if is_on_floor():
				change_state(STATE.WANDER)
			else:
				if position.distance_to(Globals.claw.position) < push_claw_distance:
					Globals.claw.push(position.direction_to(Globals.claw.position), push_claw_strength)
				if push_velocity.length() > push_velocity_length_cutoff:
					velocity = push_velocity
				else:
					push_velocity = Vector2.ZERO
				
				push_velocity = lerp(push_velocity, Vector2.ZERO, 1 - exp(-10 * delta))
	apply_gravity()
	if is_outside_left_edge():
		velocity.x = 1
	elif is_outside_right_edge():
		velocity.x = -1
	if is_grabbed:
		velocity = Vector2.ZERO
	move_and_slide()




func new_wander_interval() -> void:
	direction = randi_range(-1, 1)
	interval_timer.start(randf_range(wander_interval_min, wander_interval_max))




func push(_direction : Vector2, strength : int) -> void:
	push_velocity += _direction.normalized() * strength
