extends Timer


var possible_item_data : Array[ItemData] = [
	load("res://Objects/Items/Wind Up Mouse/wind_up_mouse.tres"),
	load("res://Objects/Items/Kick Robot/Kick Robot.tres"),
	load("res://Objects/Items/Flying Ball/Flying Ball.tres"),
	load("res://Objects/Items/Cymbal Monkey Bot/cymbal_monkey_bot.tres"),
	]

# Kept intact so endless mode can refill the pool after each delivery.
var _starting_pool : Array[ItemData] = []


var target_item_data : ItemData


var round_time_limit : float = 35


var time_display : Label
var score_display : Label


var quest_completed_time : float = 3


# Endless-mode tuning
var score : int = 0
var endless_deliveries : int = 0
var endless_bonus_start : float = 6.0
var endless_bonus_shrink : float = 0.5
var endless_bonus_min : float = 2.0


signal spawn_next_item(data: ItemData)


func _ready() -> void:
	autostart = false
	stop()
	one_shot = true
	timeout.connect(on_round_time_timeout)
	_starting_pool = possible_item_data.duplicate()


var drop_off_area : DropOffArea:
	set(new):
		assert(not drop_off_area, "There is already a drop off area.")
		drop_off_area = new


signal state_changed(new_state: STATE)

enum STATE{IDLE, QUEST_GIVING, QUEST_COMPLETED, PLAYING, GAME_WON, GAME_LOST}
var state : STATE = STATE.IDLE: set = change_state

func change_state(new_state : STATE) -> void:
	# Allow PLAYING from any active gameplay state (not just QUEST_GIVING)
	if new_state == STATE.PLAYING and state != STATE.QUEST_GIVING: return
	state = new_state
	match state:
		STATE.QUEST_COMPLETED:
			_on_quest_completed()
		STATE.QUEST_GIVING:
			new_target_item_data()
			print("New target item is " + target_item_data.name + '.')
			# Start the timer immediately — don't wait for claw input
			if is_stopped():
				# First round or timer expired: start the countdown now
				start(round_time_limit)
			print("Time remaining: " + str(snapped(time_left, 0.1)) + "s")
			# Emit QUEST_GIVING first so the kid shows the toy request
			state_changed.emit(state)
			# Then transition to PLAYING so the timer display updates
			state = STATE.PLAYING
			state_changed.emit(state)
			return  # Skip the emit below since we already emitted
		STATE.PLAYING:
			# Timer is already running from QUEST_GIVING — nothing to do
			pass
		STATE.GAME_LOST:
			stop()
			if time_display:
				time_display.text = '0s'
	state_changed.emit(state)


func _on_quest_completed() -> void:
	if Globals.endless_mode:
		endless_deliveries += 1
		var time_remaining := time_left
		var delivery_points : int = 100 + int(time_remaining * 10)
		score += delivery_points
		if score_display:
			score_display.text = "SCORE " + str(score)
		print("Endless delivery #%d  +%d  total=%d" % [endless_deliveries, delivery_points, score])

		# Add bonus time to the running timer instead of resetting
		var bonus : float = max(endless_bonus_min, endless_bonus_start - endless_bonus_shrink * (endless_deliveries - 1))
		var new_time : float = time_left + bonus
		stop()
		start(new_time)
		print("Bonus +%.1fs → %.1fs remaining" % [bonus, new_time])

		possible_item_data = _starting_pool.duplicate()
		# Respawn the same toy type that was just delivered
		var delivered_item := target_item_data
		await get_tree().create_timer(quest_completed_time).timeout
		spawn_next_item.emit(delivered_item)
		state = STATE.QUEST_GIVING
		return

	await get_tree().create_timer(quest_completed_time).timeout
	if possible_item_data.is_empty():
		state = STATE.GAME_WON
		return
	state = STATE.QUEST_GIVING


func _process(_delta: float) -> void:
	match state:
		STATE.PLAYING:
			if time_display:
				time_display.text = str(snapped(time_left, 0.1)) + 's'
		STATE.QUEST_COMPLETED:
			# Keep updating timer display even during delivery transition
			if time_display:
				time_display.text = str(snapped(time_left, 0.1)) + 's'


func new_target_item_data() -> void:
	target_item_data = _random_item_data()


func _random_item_data() -> ItemData:
	return possible_item_data[randi_range(0, possible_item_data.size() - 1)]


func on_item_collected(item : Item) -> void:
	if not Globals.endless_mode:
		possible_item_data.erase(item.item_data)
	if not item.item_data == target_item_data: return
	state = STATE.QUEST_COMPLETED
	print("Right item collected.")


func on_round_time_timeout() -> void:
	if state == STATE.PLAYING or state == STATE.QUEST_COMPLETED or state == STATE.QUEST_GIVING:
		state = STATE.GAME_LOST


func reset_for_new_game() -> void:
	score = 0
	endless_deliveries = 0
	round_time_limit = round_time_limit
	possible_item_data = _starting_pool.duplicate()
