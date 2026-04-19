extends Node2D

const ITEM_ICONS: Dictionary = {
	"Kick Robot": {"path": "res://Objects/Items/Kick Robot/kickRobo32.png", "region": Rect2(0, 0, 32, 32)},
	"Wind Up Mouse": {"path": "res://Objects/Items/Wind Up Mouse/ratRobot.png", "region": Rect2(0, 0, 32, 32)},
	"Flying Ball": {"path": "res://Objects/Items/Flying Ball/flyingBall.png", "region": Rect2(0, 0, 32, 32)},
}

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var bubble_icon: Sprite2D = $BubbleIcon


func _ready() -> void:
	ScoreKeeper.state_changed.connect(_on_state_changed)
	_on_state_changed(ScoreKeeper.state)


func _on_state_changed(new_state: ScoreKeeper.STATE) -> void:
	match new_state:
		ScoreKeeper.STATE.QUEST_GIVING:
			sprite.play("talking")
			_update_bubble_icon()
			print("[Kid] Requesting: " + ScoreKeeper.target_item_data.name)
		ScoreKeeper.STATE.PLAYING:
			sprite.play("idle")
		_:
			sprite.play("idle")
			bubble_icon.visible = false


func _update_bubble_icon() -> void:
	var item_name: String = ScoreKeeper.target_item_data.name
	if not ITEM_ICONS.has(item_name):
		bubble_icon.visible = false
		return
	var info: Dictionary = ITEM_ICONS[item_name]
	var atlas := AtlasTexture.new()
	atlas.atlas = load(info["path"])
	atlas.region = info["region"]
	bubble_icon.texture = atlas
	bubble_icon.visible = true
