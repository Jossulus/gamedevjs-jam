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
@export var munch_cut_time : float = 0.5

@onready var sfx_player : AudioStreamPlayer2D = $SFXPlayer

var original_x : float


enum STATE{SNAPPING, RETRACTING, WAITING}
var state : STATE = STATE.WAITING

var cooldown : float = 1


func _ready() -> void:
	bite_strength = max_bite_strength
	gravity_enabled = false
	$AnimatedSprite2D.flip_h = flip_sprite
	is_grabable = false
	original_x = position.x
	detection_area.area_entered.connect(snap)


func change_state(new_state : STATE) -> void:
	state = new_state


func _process(_delta: float) -> void:
	
	var input_dir : int = int(Input.get_axis("claw_left", "claw_right"))
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
	if bite_strength <= 0 and Globals.claw.is_snapped_by_crocodile:
		Globals.claw.is_snapped_by_crocodile = false
		next_expected_bite_freeing_direction = 0
		bite_strength = max_bite_strength
		retract()


func regenerate_bite_strength() -> void:
	bite_strength = clampf(bite_strength + bite_strength_regen_per_s, 0, max_bite_strength)
	


func snap(area : Area2D) -> void:
	if not state == STATE.WAITING: return
	if area != Globals.claw.get_node('ClawArea'): return
	change_state(STATE.SNAPPING)
	$AnimatedSprite2D.play("bite")
	var pos_tween : Tween = create_tween()
	pos_tween.tween_property(self, 'position', Vector2(Globals.claw.position.x, position.y), snap_time)
	await pos_tween.finished
	if position.distance_to(Globals.claw.position) <= snap_radius:
		Globals.claw.is_snapped_by_crocodile = true
		sfx_player.play()
		Globals.apply_cam_shake(20)
		await get_tree().create_timer(munch_cut_time).timeout
		sfx_player.stop()
	else:
		retract()


func retract():
	change_state(STATE.RETRACTING)
	var pos_tween : Tween = create_tween()
	pos_tween.tween_property(self, 'position', Vector2(original_x, position.y), retract_time)
	await pos_tween.finished
	$AnimatedSprite2D.play("open")
	await get_tree().create_timer(cooldown).timeout
	change_state(STATE.WAITING)
