extends Area2D
class_name DropOffArea


var collected_item_data : Array[ItemData]


signal collected(item : Item)


func _init() -> void:
	ScoreKeeper.drop_off_area = self
	collected.connect(ScoreKeeper.on_item_collected)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(item : Node2D) -> void:
	if not item is Item: return
	item.is_in_drop_off = true
	collect(item)


func _on_body_exited(item : Node2D) -> void:
	if not item is Item: return
	item.is_in_drop_off = false


func collect(item : Item) -> void:
	if item.item_data != ScoreKeeper.target_item_data:
		item.dropped_into_box = false
		_eject_wrong_item(item)
		return

	collected_item_data.append(item.item_data)
	collected.emit(item)
	item.queue_free()


func _eject_wrong_item(item : Item) -> void:
	var sideways : float = -400 if item.position.x > position.x else 400
	item.velocity = Vector2(sideways, -500)
	if Globals.left_ground_marker and Globals.right_ground_marker:
		var safe_x : float = randf_range(
			Globals.left_ground_marker.position.x + 30,
			Globals.right_ground_marker.position.x - 30
		)
		item.position.x = safe_x
		item.position.y = Globals.right_ground_marker.position.y - 80
