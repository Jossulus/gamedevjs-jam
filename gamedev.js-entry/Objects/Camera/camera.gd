extends Camera2D

@export var decay: float = 5.0       # How quickly the shake fades
@export var max_offset: float = 20.0 # Maximum shake offset (pixels)
@export var max_roll: float = 5.0    # Maximum rotation (degrees)
@export var noise_speed: float = 30.0

var trauma: float = 0.0
var trauma_power: float = 2.0

var noise := FastNoiseLite.new()
var noise_y := 0.0

func _ready():
	Globals.cam = self
	noise.seed = randi()
	noise.frequency = 0.1

func _process(delta):
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount: float):
	trauma = clamp(trauma + amount, 0.0, 1.0)

func shake():
	var amount = pow(trauma, trauma_power)

	noise_y += noise_speed * get_process_delta_time()

	var offset_x = max_offset * amount * noise.get_noise_2d(0, noise_y)
	var offset_y = max_offset * amount * noise.get_noise_2d(100, noise_y)
	var rot = deg_to_rad(max_roll * amount * noise.get_noise_2d(200, noise_y))

	offset = Vector2(offset_x, offset_y)
	rotation = rot
