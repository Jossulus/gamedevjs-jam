extends AnimatedSprite2D

func _ready() -> void:
	centered = true
	visible = false

func _process(_delta: float) -> void:
	if not Globals.claw: return
	visible = Globals.claw.is_snapped_by_crocodile
