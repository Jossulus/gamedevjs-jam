extends CharacterBody2D
class_name Bullet


@export var speed : int = 500

@export var strength : int = 300


func shoot(direction : Vector2) -> void:
	velocity = speed * direction
	rotation = direction.angle() + PI/2


func _physics_process(_delta: float) -> void:
	move_and_slide()


func hit(area : Area2D) -> void:
	if not area.name == 'ClawArea': return
	area.get_parent().push(velocity.normalized(), strength)
	queue_free()
