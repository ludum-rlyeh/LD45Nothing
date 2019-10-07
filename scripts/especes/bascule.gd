extends Line2D

var samples = [
	"res://assets/sounds/bell01.wav",
	"res://assets/sounds/bell02.wav"
]

var MIN_ANGLE = 90
var MAX_ANGLE = 120

var origin = Vector2.ZERO
var length
var cumulate_angle = 0
var total_angle
var SPEED_ANGLE = 60

var init_vec_line

var THICK = 5

var flip = false

var direction = 1

var ORIGINS 

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var sample = samples[randi() % samples.size()]
	$Audio.stream = AudioStreamRandomPitch.new()
	$Audio.stream.set_audio_stream(load(sample))
	$Audio.play()
	
func _process(delta):
	move(delta)
	
	if !flip:
		var t = init_vec_line
		$Particles2D.set_position(t)
	else:
		$Particles2D.set_position(Vector2(0,0))
		

func build(shape):
	var offset = shape[0]
	var pts2 = []
	for pt in shape:
		pts2.append(pt - offset)
	self.set_points(pts2)
	
	ORIGINS = [pts2[0], pts2[-1]]
	
	init_vec_line = ORIGINS[1] - ORIGINS[0]
	total_angle = new_angle()
	
func move(delta):
	var angleInDeg = direction * SPEED_ANGLE * delta
#
	if ((direction == -1 && cumulate_angle + angleInDeg < total_angle) || (direction == 1 && cumulate_angle + angleInDeg > total_angle)):
		direction = random_direction()
		total_angle = direction * new_angle()
		flip = !flip
		cumulate_angle = 0
		$Audio.play()
	else:
		cumulate_angle += angleInDeg

	var angleInRad = deg2rad(angleInDeg)
	var T
	var pos = position
	if(!flip):
		T = -pos
	else:
		var trans = init_vec_line.rotated(get_transform().get_rotation()) + position
		T = -trans
#
	translate(T)

	var transform = get_transform().rotated(angleInRad)
	set_transform(transform)

	translate(-T)
		
func random_angle_between(minVal, maxVal):
	return rand_range(minVal , maxVal)
	
func new_angle():
	return random_angle_between(MIN_ANGLE, MAX_ANGLE)
	
func random_direction():
	var n = randi() % 2
	if n == 1:
		return -1
	return 1
