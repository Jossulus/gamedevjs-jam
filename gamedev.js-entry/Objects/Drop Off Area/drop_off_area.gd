extends Area2D
class_name DropOffArea


var collected_item_data : Array[ItemData]


signal collected(item : Item)


func _init() -> void:
	ScoreKeeper.drop_off_area = self
	collected.connect(ScoreKeeper.on_item_collected)


func _ready() -> void:
	body_entered.connect(collect)


func collect(item : Node2D) -> void:
	if not item is Item: return
	if item.item_data != ScoreKeeper.target_item_data:
		item.dropped_into_box = false
		item.velocity = Vector2(0, -500)
		return

	collected_item_data.append(item.item_data)
	collected.emit(item)
	item.queue_free()
