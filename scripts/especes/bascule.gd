extends Line2D

var samples = [
	"res://assets/sounds/bell01.wav",
	"res://assets/sounds/bell02.wav"
]

var pitches = [
	2.0, # perfect octave
	1.77, # minor seventh
	1.5, # perfect fifth
	1.33, # perfect four
	1.2,  # minor third
	1.0, # same note
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

var VIEWPORT_SIZE

var flip = false

var direction = 1

var ORIGINS 
var OFFSET

var INIT_POINTS
var DELAYED 

var _time_pulse_audio : float
var _scale_pulse_audio_init : Vector2
var _scale_pulse_audio_final : Vector2
var SCALE_PULSE_AUDIO_OFFSET = Vector2(1.0,1.0)
var TIME_PULSE_AUDIO_SCALE = 1.0/2.0

var _pulse_shape_bary
var _shape_sound

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var sample = samples[randi() % samples.size()]
	$Audio.stream = load(sample)
	
	_time_pulse_audio = $Audio.stream.get_length() * TIME_PULSE_AUDIO_SCALE
	_pulse_sound()
	
func _pulse_sound():
	$PulseTween.interpolate_property(_shape_sound, "scale", _scale_pulse_audio_init, _scale_pulse_audio_final, _time_pulse_audio, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$PulseTween.interpolate_property(_shape_sound, "modulate", Color.white, Color(255, 255, 255, 0), _time_pulse_audio, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$PulseTween.start()
	$Audio.play()
	
func _process(delta):
	move(delta)

func build(shape, material):
	
	_shape_sound = $PulseShape
	_scale_pulse_audio_init = _shape_sound.scale
	_scale_pulse_audio_final = _scale_pulse_audio_init + SCALE_PULSE_AUDIO_OFFSET
	
	var offset = shape[0]
	OFFSET = offset
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
		
	VIEWPORT_SIZE = Utils.Viewport_dimensions()
	
	set_material(material.duplicate())
	
	_build_sound()
	
	_build_pulse_shape()
	
func _build_pulse_shape():
	var circle = Utils.create_circle(5, 20)
	_shape_sound.set_points(circle)
	
func _build_sound():
	# set audio
	var id = round(get_size(points) / 250)
	if id >= pitches.size() :
		id = pitches.size() - 1
	$Audio.pitch_scale = pitches[id]
	$Audio.play()
	
func move(delta):
	var angleInDeg = direction * SPEED_ANGLE * delta
	var total_angleRad = deg2rad(total_angle)
	var angleInRad = deg2rad(angleInDeg)
	
	if ((direction == -1 && cumulate_angle + angleInDeg < (1.5 * total_angle)) || (direction == 1 && cumulate_angle + angleInDeg > (1.5*total_angle))):
		direction = random_direction()
		total_angle = direction * new_angle()
		flip = !flip
		cumulate_angle = 0
		$PulseTween.stop_all()
		_pulse_sound()
		if !flip:
			$Particles2D.set_position(Vector2(0,0))
			var index = int(get_point_count()/6.0)
			if index >= get_point_count() || index < 0:
				index = 0
			_shape_sound.position = get_point_position(index)
		else:
			var t = init_vec_line
			$Particles2D.set_position(t)
			var index = get_point_count()-get_point_count()/8.0
			if index >= get_point_count() || index < 0:
				index = get_point_count()-1
			_shape_sound.position = get_point_position(index)
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
	
	var transformed = get_transform()[2]
	var new_base = transformed + OFFSET
	if (new_base[0] < -VIEWPORT_SIZE[0]/3.0) :
		translate(Vector2(VIEWPORT_SIZE[0] * (1.0+1.0/3.0),0.0))
	if (new_base[0] > VIEWPORT_SIZE[0] * (1.0+1.0/3.0)) :
		translate(Vector2(-1.0*VIEWPORT_SIZE[0] * (1.0+1.0/3.0),0.0))
	if (new_base[1] < -VIEWPORT_SIZE[1]/3.0) :
		translate(Vector2(0.0,VIEWPORT_SIZE[1] * (1.0+1.0/3.0)))
	if (new_base[1] > VIEWPORT_SIZE[1] * (1.0+1.0/3.0)) :
		translate(Vector2(0.0,-1.0*VIEWPORT_SIZE[1] * (1.0+1.0/3.0)))
			
		
func random_angle_between(minVal, maxVal):
	return rand_range(minVal , maxVal)
	
func new_angle():
	return random_angle_between(MIN_ANGLE, MAX_ANGLE)
	
func random_direction():
	var n = randi() % 2
	if n == 1:
		return -1
	return 1

func get_size(var points) :
	var size = 0
	for i in range(0, points.size() - 1):
		var vect = points[i+1] - points[i]
		size += vect.length()
	return size
