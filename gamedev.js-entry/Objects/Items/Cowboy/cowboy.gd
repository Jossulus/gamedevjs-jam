extends Item
class_name Cowboy


enum State{IDLE, WALKING, THROWING, RETRACTING}
var state : State = State.IDLE: set= change_state

@export var state_change_timer : Timer

@export var wander_direction : int
@export var speed : float

@export_group('Balance')
@export var throw_distance : float
@export var catch_radius : float
@export var throw_speed : float

func change_state(new_state : State) -> void:
	state = new_state
	match state:
		State.IDLE:
			state_change_timer.start()
		State.WALKING:
			wander_direction = 1 if randf_range(0, 1) > 0 else -1
			state_change_timer.start()


func switch_state_from_timer() -> void:
	if state == State.THROWING or state == State.RETRACTING: return
	match state:
		State.IDLE:
			if position.distance_to(Globals.claw.position) <= throw_distance:
				change_state(State.THROWING)
			change_state(State.WALKING)
		State.WALKING:
			change_state(State.THROWING)


func _physics_process(_delta: float) -> void:
	match state:
		State.IDLE:
			velocity.x = 0
			if !is_on_floor():
				apply_gravity()
			else:
				velocity.y = 0
		State.WALKING:
			velocity.x = speed * wander_direction
			if !is_on_floor():
				apply_gravity()
			else:
				velocity.y = 0
	
	move_and_slide()
