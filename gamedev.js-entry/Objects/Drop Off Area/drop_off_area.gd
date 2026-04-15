extends Area2D
class_name DropOffArea


var collected_item_data : Array[ItemData]


func _ready() -> void:
	body_entered.connect(collect)


func collect(item : Node2D) -> void:
	if not item is Item: return
	
	collected_item_data.append(item.item_data)
	item.queue_free()
	print(str(item.item_data.name), ' collected!')
