extends Item
class_name FlyingBall


@export var full_thrust : float = 1850


@export var push_range : int = 20




func _physics_process(delta: float) -> void:
	if is_grabbed: return
	if position.y > Globals.claw.position.y:
		var dir : Vector2 = calculate_accel_direction_fastest(position, velocity, Globals.claw.position, full_thrust)
		velocity += dir*full_thrust*delta
		rotation = dir.angle() + PI/2
	apply_gravity()
	if position.distance_to(Globals.claw.position) < push_range:
		Globals.claw.push(position.direction_to(Globals.claw.position), int(velocity.length()))
		velocity -= position.direction_to(Globals.claw.position)*velocity.length()
	
	if is_outside_left_edge():
		velocity.x = 10
	elif is_outside_right_edge():
		velocity.x = -10
	if is_on_floor():
		velocity.y = -10
	if dropped_into_box:
		velocity.x = 0
	move_and_slide()


func _accel_from_t(dp: Vector2, v0: Vector2, g: Vector2, t: float) -> Vector2:
	return 2.0 * (dp - v0 * t - 0.5 * g * t * t) / (t * t)

func _error(dp: Vector2, v0: Vector2, g: Vector2, t: float, accel_mag: float) -> float:
	if t <= 0.0:
		return INF
	return _accel_from_t(dp, v0, g, t).length() - accel_mag


func calculate_accel_direction_fastest(
	p0: Vector2,
	v0: Vector2,
	p1: Vector2,
	accel_mag: float,
	max_iter: int = 40,
	tol: float = 0.001
) -> Vector2:
	var dp: Vector2 = p1 - p0
	var g: Vector2 = get_gravity()

	var t_min: float = 0.0001
	var t_max: float = 10.0

	while _error(dp, v0, g, t_max, accel_mag) > 0.0:
		t_max *= 2.0
		if t_max > 1e5:
			break

	var t: float = t_max

	for i in max_iter:
		var t_mid: float = (t_min + t_max) * 0.5
		var e: float = _error(dp, v0, g, t_mid, accel_mag)

		if abs(e) < tol:
			t = t_mid
			break

		if e > 0.0:
			t_min = t_mid
		else:
			t_max = t_mid

		t = t_mid

	var accel: Vector2 = _accel_from_t(dp, v0, g, t)
	return accel.normalized()
