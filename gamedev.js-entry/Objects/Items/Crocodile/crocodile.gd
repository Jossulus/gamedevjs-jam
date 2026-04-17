extends Item
class_name Crocodile


@export var flip_sprite : bool = false


@export var snap_time : float = 0.1
@export var retract_time : float = 0.5

@export var snap_radius : float = 10


var bite_strength : float

@export var max_bite_strength : float = 20

@export var bite_strength_regen_per_s : float = 1

var next_expected_bite_freeing_direction : int = 0


@export var detection_area : Area2D


var original_x : float


func _ready() -> void:
	bite_strength = max_bite_strength
	gravity_enabled = false
	$AnimatedSprite2D.flip_h = flip_sprite
	is_grabable = false
	original_x = position.x
	detection_area.area_entered.connect(snap)


func _process(_delta: float) -> void:
	#print(bite_strength)
	
	var input_dir : int = int(Input.get_axis("claw_left", "claw_right"))
	#print('input: ', str(input_dir))
	if Globals.claw.is_snapped_by_crocodile and input_dir != 0:
		if next_expected_bite_freeing_direction == 0:
			next_expected_bite_freeing_direction = -input_dir
			bite_strength -= 1
			Globals.apply_cam_shake(0.1)
		elif next_expected_bite_freeing_direction == input_dir:
			var bite_strength_reduction : float = max_bite_strength - bite_strength
			bite_strength -= bite_strength_reduction
			Globals.apply_cam_shake(bite_strength_reduction/10)
			next_expected_bite_freeing_direction = -input_dir
	if bite_strength <= 0:
		Globals.claw.is_snapped_by_crocodile = false
		next_expected_bite_freeing_direction = 0
		bite_strength = max_bite_strength
		retract()


func regenerate_bite_strength() -> void:
	bite_strength = clampf(bite_strength + bite_strength_regen_per_s, 0, max_bite_strength)
	


func snap(area : Area2D) -> void:
	if not $CooldownTimer.is_stopped(): return
	if area != Globals.claw.get_node('ClawArea'): return
	$AnimatedSprite2D.play("bite")
	var pos_tween : Tween = create_tween()
	pos_tween.tween_property(self, 'position', Vector2(Globals.claw.position.x, position.y), snap_time)
	await pos_tween.finished
	if position.distance_to(Globals.claw.position) <= snap_radius:
		Globals.claw.is_snapped_by_crocodile = true
		Globals.apply_cam_shake(20)
	else:
		retract()


func retract():
	var pos_tween : Tween = create_tween()
	pos_tween.tween_property(self, 'position', Vector2(original_x, position.y), retract_time)
	await pos_tween.finished
	$AnimatedSprite2D.play("open")
	$CooldownTimer.start()
