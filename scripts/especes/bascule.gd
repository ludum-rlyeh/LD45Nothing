extends Line2D

var samples = [
	"res://assets/sounds/bell01.wav",
	"res://assets/sounds/bell02.wav"
]

var pitches = [
	1.0, # same note
	1.2,  # minor third
	1.33, # perfect four
	1.5, # perfect fifth
	1.77, # minor seventh
	2.0 # perfect octave
]

var MIN_ANGLE = 90
var MAX_ANGLE = 120

var origin = Vector2.ZERO
var length
var cumulate_angle = 0
var cumulate_angleRad = 0
var total_angle
var SPEED_ANGLE = 60

var init_vec_line

var THICK = 5

var flip = false

var direction = 1

var ORIGINS 

var INIT_POINTS
var DELAYED 

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var sample = samples[randi() % samples.size()]
	$Audio.stream = load(sample)
	$Audio.pitch_scale = pitches[randi() % pitches.size()]
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
	INIT_POINTS = self.points
	DELAYED = []
	for i in range(0,self.points.size()) :
		DELAYED.append(0)
	
func move(delta):
	var angleInDeg = direction * SPEED_ANGLE * delta
	var total_angleRad = deg2rad(total_angle)
	var angleInRad = deg2rad(angleInDeg)
	
	
	
#
	if ((direction == -1 && cumulate_angle + angleInDeg < (1.5 * total_angle)) || (direction == 1 && cumulate_angle + angleInDeg > (1.5*total_angle))):
		direction = random_direction()
		total_angle = direction * new_angle()
		flip = !flip
		cumulate_angle = 0
		$Audio.play()
		self.points = INIT_POINTS
		
	else:
		cumulate_angle += angleInDeg
		cumulate_angleRad = deg2rad(cumulate_angle)

	#var angleInRad = deg2rad(angleInDeg)
	if abs(cumulate_angleRad) < abs(total_angleRad) :
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
	
		var curr_step = abs(angleInRad/total_angleRad)
		var curr_step_point
	
		if !flip :
			for i in range(1,self.points.size()-1) :
				curr_step_point = self.points[i].length() / self.points[-1].length()
				if curr_step_point > curr_step :
					self.points[i] = self.points[i].rotated(-0.7*angleInRad*(1.0-curr_step_point))
		else :
			for i in range(1,self.points.size()-1) :
				curr_step_point = self.points[i].length() / self.points[-1].length()
				if curr_step_point > curr_step :
					self.points[i] = self.points[i].rotated(0.7*angleInRad*(1.0 - curr_step_point))
					
		translate(-T)
	else :
		var curr_step = (angleInRad/total_angleRad)
		var curr_step_point
		if !flip :
			for i in range(1,self.points.size()-1) :
				curr_step_point = self.points[i].length() / self.points[-1].length()
				if curr_step_point > curr_step :
					self.points[i] = self.points[i].rotated(+0.7*angleInRad*(1.0-curr_step_point)*2.0)
		else :
			for i in range(1,self.points.size()-1) :
				curr_step_point = self.points[i].length() / self.points[-1].length()
				if curr_step_point > curr_step :
					self.points[i] = self.points[i].rotated(-0.7*angleInRad*(1.0 - curr_step_point)*2.0)
	
	
	
	
			
		
func random_angle_between(minVal, maxVal):
	return rand_range(minVal , maxVal)
	
func new_angle():
	return random_angle_between(MIN_ANGLE, MAX_ANGLE)
	
func random_direction():
	var n = randi() % 2
	if n == 1:
		return -1
	return 1
