extends Item
class_name Canon


@onready var bullet_scene : PackedScene = preload("uid://db3s4pnf7748w")
@onready var sfx_player : AudioStreamPlayer2D = $SFXPlayer


@export var num_bullets : int = 5
@export var spread : float = 80

@export var claw_height_threshold : int = -80


func shoot(direction : Vector2) -> void:
	if is_grabbed: return
	var new_bullet : Bullet = bullet_scene.instantiate()
	new_bullet.shoot(direction)
	new_bullet.position = position
	Globals.level_node.add_child(new_bullet)


func _process(_delta: float) -> void:
	if is_grabbed: return
	aim()


func _input(_event: InputEvent) -> void:
	if is_grabbed: return
	if is_in_drop_off: return
	if Input.is_action_just_pressed("push_ability"):
		shoot_spread()



func aim() -> void:
	$Muzzle.rotation = position.direction_to(Globals.claw.position).angle() + PI/2


func _physics_process(_delta: float) -> void:
	if !is_grabbed:
		apply_gravity()
	move_and_slide()

func shoot_spread() -> void:
	if is_grabbed: return
	if is_in_drop_off: return
	if Globals.claw.position.y < claw_height_threshold: return
	sfx_player.play()
	
	var base_direction = position.direction_to(Globals.claw.position)
	var base_angle = base_direction.angle()
	
	# Convert spread to radians
	var spread_radians = deg_to_rad(spread)
	
	# If only 1 bullet, just shoot straight
	if num_bullets == 1:
		shoot(base_direction)
		return
	
	for i in range(num_bullets):
		var t = float(i) / (num_bullets - 1)  # 0 → 1
		var angle_offset = lerp(-spread_radians / 2, spread_radians / 2, t)
		
		var new_direction = Vector2.RIGHT.rotated(base_angle + angle_offset)
		shoot(new_direction)
