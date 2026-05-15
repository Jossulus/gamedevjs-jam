extends Item
class_name KickRobot


enum STATE{WANDER, CHASE, JUMP, LAND}
var state : STATE = STATE.WANDER

@export_group("Sounds")
@export var jump_sound: AudioStream
@export var hit_sound: AudioStream
@export var miss_sound: AudioStream

@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer

@export var speed : int = 20
var direction : int = 0

@export var wander_interval_min : int
@export var wander_interval_max : int

@export var interval_timer : Timer

@export var aggro_distance : int = 100

@export var jump_distance : int = 20

var jump_height : int: get = get_jump_height

@export var max_jump_height : int = 30


var push_velocity_length_cutoff : int = 5

@export var push_strength : int = 200

@export var push_claw_distance : int = 10
@export var push_claw_strength : int = 500


var _release_cooldown : float = 0.0
var _aggro_cooldown : float = 0.0


func get_jump_height() -> int:
	var clamped_jump_height : int = clampi(int(position.y - Globals.claw.position.y), 0,max_jump_height)
	if clamped_jump_height < 5: return 5
	return clamped_jump_height



func change_state(new_state : STATE) -> void:
	state = new_state
	match state:
		STATE.WANDER:
			is_grabable = true
			await get_tree().create_timer(1).timeout
			if is_grabbed or state != STATE.WANDER: return
			new_wander_interval()
		STATE.CHASE:
			pass
		STATE.JUMP:
			play_sfx(jump_sound)
			velocity.x = 0
			$AnimatedSprite2D.play("awake")
			await $AnimatedSprite2D.animation_finished
			if is_grabbed or state != STATE.JUMP: return
			velocity.y = -sqrt((2 * get_gravity().y * jump_height)/get_physics_process_delta_time())
		STATE.LAND:
			play_sfx(hit_sound)
			$AnimatedSprite2D.play("kick")
			push(position.direction_to(Globals.claw.position), push_strength)


func _physics_process(delta: float) -> void:
	# Disable AI while grabbed or dropped into the box
	if is_grabbed:
		velocity = Vector2.ZERO
		push_velocity = Vector2.ZERO
		if state != STATE.WANDER:
			state = STATE.WANDER
		$AnimatedSprite2D.play("idle")
		_release_cooldown = 0.8
		move_and_slide()
		return
	if _release_cooldown > 0.0:
		_release_cooldown -= delta
		push_velocity = Vector2.ZERO
		apply_gravity()
		move_and_slide()
		return
	if dropped_into_box:
		# Just fall straight in — no AI, no push
		push_velocity = Vector2.ZERO
		apply_gravity()
		move_and_slide()
		return

	if _aggro_cooldown > 0.0:
		_aggro_cooldown -= delta
	if get_direction_to_claw() < 0:
		$AnimatedSprite2D.flip_h = false
	elif get_direction_to_claw() > 0:
		$AnimatedSprite2D.flip_h = true
	match state:
		STATE.WANDER:
			if _aggro_cooldown <= 0.0 and abs(get_displacement_to_claw()) <= aggro_distance:
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
				_aggro_cooldown = 7.0 if is_claw_above_alligator() else 0.5
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
	apply_push()
	if is_outside_left_edge():
		velocity.x = 1
		position.x = Globals.left_ground_marker.position.x + 1
	elif is_outside_right_edge():
		velocity.x = -1
		position.x = Globals.right_ground_marker.position.x - 1
	if !is_above_floor():
		position.y = Globals.right_ground_marker.position.y - 1
	move_and_slide()


func is_above_floor() -> bool:
	return position.y + velocity.y*get_physics_process_delta_time() < Globals.right_ground_marker.position.y


func new_wander_interval() -> void:
	direction = randi_range(-1, 1)
	interval_timer.start(randf_range(wander_interval_min, wander_interval_max))
	
func play_sfx(stream: AudioStream):
	if stream and sfx_player:
		sfx_player.stream = stream
		# This adds that "variety" so they don't all sound the same
		sfx_player.pitch_scale = randf_range(0.9, 1.1)
		sfx_player.play()
