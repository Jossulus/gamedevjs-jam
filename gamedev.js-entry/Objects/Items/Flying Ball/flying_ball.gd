extends Item
class_name FlyingBall


@export var full_thrust : float = 1850

@export var height_thrust_threshold : int = 80


enum STATE{HOVERING, CHASING}
var state : STATE = STATE.CHASING: set = change_state


func change_state(new_state : STATE) -> void:
	state = new_state

func _physics_process(delta: float) -> void:
	if is_grabbed: return
	if state == STATE.CHASING:
		if position.y > Globals.claw.position.y:
			velocity+=Vector2.from_angle(get_fastest_angle_to(Globals.claw.position))*full_thrust*delta
			rotation = get_fastest_angle_to(Globals.claw.position) + PI/2
	apply_gravity()
	
	if is_outside_left_edge():
		velocity.x = 10
	elif is_outside_right_edge():
		velocity.x = -10
	if is_on_floor():
		velocity.y = -10
	move_and_slide()


func get_fastest_angle_to(goal: Vector2) -> float:
	# 1. Get the direction vector to the goal
	var to_goal = goal - global_position
	
	# 2. Gravity Compensation
	# Gravity pulls DOWN (positive Y). 
	# To cancel it, we need to aim slightly UP (negative Y).
	var g = ProjectSettings.get_setting("physics/2d/default_gravity")/10
	var gravity_vector = Vector2(0, g)
	
	# 3. Calculate the Steering Vector
	# We want: Thrust_Vector + Gravity_Vector = Pure_Direction_To_Goal
	# Therefore: Thrust_Vector = Pure_Direction_To_Goal - Gravity_Vector
	var desired_velocity = to_goal.normalized() * full_thrust
	var steering_vector = desired_velocity - gravity_vector - velocity
	
	return steering_vector.angle()
