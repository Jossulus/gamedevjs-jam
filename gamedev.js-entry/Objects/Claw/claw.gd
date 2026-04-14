extends CharacterBody2D
class_name Claw


@export var claw_sprite : AnimatedSprite2D


var returned_position : Vector2


enum INPUT{IDLE, FREE, DOWN, UP, RETURN}
var input : INPUT = INPUT.IDLE


@export var speed : int = 200

@export var down_speed : int = 500

@export var up_speed : int = -300


func _ready() -> void:
	returned_position = position


func change_input(new_input : INPUT) -> void:
	input = new_input
	match input:
		INPUT.IDLE:
			claw_sprite.play("open")
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
	
	move_and_slide()



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
	return


func handle_up() -> void:
	velocity.x = get_claw_input_direction() * speed
	
	if position.y <= returned_position.y:
		change_input(INPUT.RETURN)
		print("Return")


func handle_return() -> void:
	return


func grab(item : Item) -> void:
	if not item is Item: return
	
	velocity.y = 0
	claw_sprite.play('close')
	await claw_sprite.animation_finished
	change_input(INPUT.UP)


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
