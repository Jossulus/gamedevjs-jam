extends CharacterBody2D
class_name Claw


@export var claw_sprite : AnimatedSprite2D

@export var ground_position_marker : Marker2D


@export var left_boundary_marker : Marker2D
@export var right_boundary_marker : Marker2D


@export var left_ground_marker : Marker2D
@export var right_ground_marker : Marker2D


@export var claw_grab_position_marker : Marker2D


var returned_position : Vector2


var grabbed_item : Item = null


enum INPUT{IDLE, FREE, DOWN, UP, RETURN}
var input : INPUT = INPUT.IDLE


@export var speed : int = 150

@export var down_speed : int = 200

@export var up_speed : int = 80


var push_velocity : Vector2


func set_global_variables() -> void:
	Globals.claw = self
	Globals.ground_position_marker = ground_position_marker
	Globals.left_boundary_marker = ground_position_marker
	Globals.right_boundary_marker = right_boundary_marker
	Globals.left_ground_marker = left_ground_marker
	Globals.right_ground_marker = right_ground_marker


func _ready() -> void:
	set_global_variables()
	assert(is_x_position_in_boundary(), "Claw not inside boundaries.")
	assert(ground_position_marker, "Claw does not know where the ground is, because no ground_position_marker is assigned.")
	returned_position = position


func change_input(new_input : INPUT) -> void:
	match input:
		INPUT.UP:
			if new_input == INPUT.FREE:
				claw_sprite.play('open')
	input = new_input
	match input:
		INPUT.IDLE:
			drop()
			claw_sprite.play('open')
		INPUT.FREE:
			velocity.y = 0
		INPUT.DOWN:
			velocity.x = 0
			velocity.y = down_speed
		INPUT.UP:
			velocity.y = up_speed
		INPUT.RETURN:
			velocity = Vector2.ZERO
			return_claw()


func _physics_process(delta: float) -> void:
	match input:
		INPUT.IDLE:
			handle_idle()
		INPUT.FREE:
			handle_free()
		INPUT.DOWN:
			handle_down()
		INPUT.UP:
			handle_up()
		INPUT.RETURN:
			handle_return()
	if not is_x_position_in_boundary(): velocity.x = 0
	if is_above_ground():
		velocity.y = clampf(velocity.y,-INF, 0)
		
	push_velocity = lerp(push_velocity, Vector2.ZERO, 1 - exp(-10 * delta))
	move_and_slide()


func is_x_position_in_boundary() -> bool:
	var dir : int = velocity.x / abs(velocity.x) if velocity.x != 0 else 0
	return position.x + dir <= right_boundary_marker.position.x and position.x + dir >= left_boundary_marker.position.x


func is_above_ground() -> bool:
	return position.y > ground_position_marker.position.y
	


func get_claw_input_direction() -> Vector2:
	return Input.get_vector("claw_left", "claw_right", "claw_up", "claw_down")


func handle_idle() -> void:
	if get_claw_input_direction().x != 0:
		change_input(INPUT.FREE)


func handle_free() -> void:
	velocity.x = get_claw_input_direction().x * speed
	
	if Input.is_action_just_pressed("claw_trigger"):
		change_input(INPUT.DOWN)


func handle_down() -> void:
	if position.y >= ground_position_marker.position.y:
		claw_sprite.play('close')
		velocity += push_velocity
		change_input(INPUT.UP)


func handle_up() -> void:
	velocity.x = get_claw_input_direction().x * speed
	var v_speed : float = down_speed if get_claw_input_direction().y > 0 else up_speed
	velocity.y = get_claw_input_direction().y * v_speed
	
	velocity += push_velocity
	
	if position.y <= returned_position.y:
		if grabbed_item:
			change_input(INPUT.RETURN)
		else:
			change_input(INPUT.FREE)


func handle_return() -> void:
	return


func grab(item : Node2D) -> void:
	if not input == INPUT.DOWN: return
	if not item is Item: return
	
	grabbed_item = item
	grabbed_item.call_deferred("reparent", self)
	var update_position_function : Callable = func():
		grabbed_item.position = claw_grab_position_marker.position
	update_position_function.call_deferred()
	grabbed_item.is_grabbed = true
	velocity.y = 0
	claw_sprite.play('close')
	await claw_sprite.animation_finished
	change_input(INPUT.UP)


func drop() -> void:
	if grabbed_item:
		grabbed_item.reparent(get_tree().root.get_node("Game"))
		grabbed_item.is_grabbed = false
	grabbed_item = null


func return_claw() -> void:
	var position_tween : Tween = create_tween()
	var distance_to_returned_position : float = abs(returned_position.x - position.x)

	position_tween.tween_method(
		func(x): position.x = x,
			position.x,
			returned_position.x,
			distance_to_returned_position / speed
	)
	
	await position_tween.finished
	change_input(INPUT.IDLE)



func push(direction : Vector2, strength : int) -> void:
	push_velocity += direction.normalized() * strength
	drop()

func _input(event: InputEvent) -> void:
	if Input.get_vector("test_push_left", "test_push_right", "test_push_up", "test_push_down") != Vector2.ZERO:
		push(Input.get_vector("test_push_left", "test_push_right", "test_push_up", "test_push_down"), 500)
