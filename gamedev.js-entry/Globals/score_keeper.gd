extends Timer


var possible_item_data : Array[ItemData] = [
	load("res://Objects/Items/Wind Up Mouse/wind_up_mouse.tres"),
	load("res://Objects/Items/Kick Robot/Kick Robot.tres"),
	load("res://Objects/Items/Flying Ball/Flying Ball.tres"),
	load("res://Objects/Items/Cymbal Monkey Bot/cymbal_monkey_bot.tres"),
	]


var target_item_data : ItemData


var round_time_limit : float = 20


var time_display : Label


var quest_completed_time : float = 3


func _ready() -> void:
	autostart = false
	stop()
	one_shot = true
	timeout.connect(on_round_time_timeout)


var drop_off_area : DropOffArea


func reset() -> void:
	possible_item_data = [
		load("res://Objects/Items/Wind Up Mouse/wind_up_mouse.tres"),
		load("res://Objects/Items/Kick Robot/Kick Robot.tres"),
		load("res://Objects/Items/Flying Ball/Flying Ball.tres"),
		load("res://Objects/Items/Cymbal Monkey Bot/cymbal_monkey_bot.tres"),
	]
	target_item_data = null


signal state_changed(new_state: STATE)

enum STATE{IDLE, QUEST_GIVING, QUEST_COMPLETED, PLAYING, GAME_WON, GAME_LOST}
var state : STATE = STATE.IDLE: set = change_state

func change_state(new_state : STATE) -> void:
	if new_state == STATE.PLAYING and state != STATE.QUEST_GIVING: return
	state = new_state
	match state:
		STATE.QUEST_COMPLETED:
			_on_quest_completed()
		STATE.QUEST_GIVING:
			new_target_item_data()
			print("New target item is " + target_item_data.name + '.')
			start(round_time_limit)
		STATE.PLAYING:
			pass
		STATE.GAME_LOST:
			stop()
			time_display.text = '0s'
	state_changed.emit(state)


func _on_quest_completed() -> void:
	time_display.text = '0s'
	stop()
	await get_tree().create_timer(quest_completed_time).timeout
	if possible_item_data.is_empty():
		state = STATE.GAME_WON
		return
	state = STATE.QUEST_GIVING


func _process(_delta: float) -> void:
	match state:
		STATE.PLAYING, STATE.QUEST_GIVING:
			time_display.text = str(ceil(time_left)) + 's'


func new_target_item_data() -> void:
	target_item_data = possible_item_data[randi_range(0, possible_item_data.size() - 1)]


func on_item_collected(item : Item) -> void:
	possible_item_data.erase(item.item_data)
	if not item.item_data == target_item_data: return
	state = STATE.QUEST_COMPLETED
	print("Right item collected.")


func on_round_time_timeout() -> void:
	if state == STATE.PLAYING or state == STATE.QUEST_GIVING:
		state = STATE.GAME_LOST
