extends CharacterBody2D
class_name Claw


@export var claw_sprite : AnimatedSprite2D

@export var ground_position_marker : Marker2D


@export var left_boundary_marker : Marker2D
@export var right_boundary_marker : Marker2D


@export var claw_grab_position_marker : Marker2D


var returned_position : Vector2


var grabbed_item : Item = null


enum INPUT{IDLE, FREE, DOWN, UP, RETURN}
var input : INPUT = INPUT.IDLE


@export var speed : int = 200

@export var down_speed : int = 500

@export var up_speed : int = -300


func _ready() -> void:
	assert(is_x_position_in_boundary(), "Claw not inside boundaries.")
	assert(ground_position_marker, "Claw does not know where the ground is, because no ground_position_marker is assigned.")
	returned_position = position


func change_input(new_input : INPUT) -> void:
	input = new_input
	match input:
		INPUT.IDLE:
			drop()
		INPUT.DOWN:
			velocity.x = 0
			velocity.y = down_speed
		INPUT.UP:
			velocity.y = up_speed
		INPUT.RETURN:
			velocity = Vector2.ZERO
			return_claw()


func _physics_process(_delta: float) -> void:
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
	if is_x_position_in_boundary():
		move_and_slide()


func is_x_position_in_boundary() -> bool:
	var dir : int = velocity.x / abs(velocity.x) if velocity.x != 0 else 0
	return position.x + dir < right_boundary_marker.position.x and position.x + dir > left_boundary_marker.position.x


func get_claw_input_direction() -> float:
	return Input.get_axis("claw_left", "claw_right")


func handle_idle() -> void:
	if get_claw_input_direction() != 0:
		change_input(INPUT.FREE)


func handle_free() -> void:
	velocity.x = get_claw_input_direction() * speed
	
	if Input.is_action_just_pressed("claw_trigger"):
		change_input(INPUT.DOWN)


func handle_down() -> void:
	if position.y >= ground_position_marker.position.y:
		claw_sprite.play('close')
		change_input(INPUT.UP)


func handle_up() -> void:
	velocity.x = get_claw_input_direction() * speed
	
	if position.y <= returned_position.y:
		change_input(INPUT.RETURN)


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
	claw_sprite.play('open')


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
