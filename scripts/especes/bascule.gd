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
	
	
	var line = Line2D.new()
	line.set_points([Vector2(50,200), Vector2(200,200)])
	build(line.points)
	
func _process(delta):
	move(delta)
	
	if !flip:
		$Particles2D.set_position(global_position)
#	else:
#		$Particles2D.set_position(global_position+init_vec_line.rotated(get_transform().get_rotation()))
		

func build(shape):
	self.set_points(shape)
	
	init_vec_line = shape[shape.size()-1] - shape[0]
	length = init_vec_line.length()
	total_angle = new_angle()
#	var normal = Vector2(-1.0 * init_vec_line[1], init_vec_line[0]).normalized()
#	self.set_position(shape[0])
	
#	var points = [Vector2(0, 0), Vector2(0, 0) + normal * 10.0, init_vec_line + Vector2(0, 0), init_vec_line + Vector2(0, 0) - 10.0 * normal]
#	self.direction = points[points.size() - 1] - points[0]
	#var points = [shape[0], shape[0] + normal * 5.0, shape[-1] + normal * 5.0,shape[-1]]
	
	ORIGINS = [shape[0], shape[-1]]
	
	var pos = position
	translate(-pos)
	
	var angleInRad = deg2rad(20)
	var transform = get_transform().rotated(angleInRad)
	set_transform(transform)

	translate(pos)
	
	
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
		var trans = init_vec_line.rotated(get_transform().get_rotation())
		T = -pos -trans

	translate(T)

	var transform = get_transform().rotated(angleInRad)
	set_transform(transform)

	translate(-T)
	
	
	
#	var angleInDeg = direction * SPEED_ANGLE * delta
#
#	if ((direction == -1 && cumulate_angle + angleInDeg < total_angle) || (direction == 1 && cumulate_angle + angleInDeg > total_angle)):
#		direction = random_direction()
#		total_angle = direction * new_angle()
#		flip = !flip
#		cumulate_angle = 0
#		$Audio.play()
#	else:
#		cumulate_angle += angleInDeg
#
#	var glob_pos = global_position
#	var angleInRad = deg2rad(angleInDeg)
#	var T
#	if(!flip):
#		T = -glob_pos
#	else:
#		var trans = init_vec_line.rotated(get_transform().get_rotation())
#		T = -glob_pos -trans
#
#	translate(T)
#
#	var transform = get_global_transform().rotated(angleInRad)
#	set_transform(transform)
#
#	translate(-T)
	
		
func random_angle_between(minVal, maxVal):
	return rand_range(minVal , maxVal)
	
func new_angle():
	return random_angle_between(MIN_ANGLE, MAX_ANGLE)
	
func random_direction():
	var n = randi() % 2
	if n == 1:
		return -1
	return 1
