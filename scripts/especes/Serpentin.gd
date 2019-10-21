extends Line2D

var pitches = [
	2.0, # perfect octave
	1.77, # minor seventh
	1.5, # perfect fifth
	1.33, # perfect four
	1.2,  # minor third
	1.0, # same note
]

var POINTS
var LOOP = 0
var TIME = 0
var DIRECTION = Vector2(randf() * pow(-1,randi()%2),randf() * pow(-1,randi()%2)).normalized()
var NUMBER_SLOOPS = 2
var DISTANCE = 1
var AMPLITUDE = 1.0

var DISTANCE_ATTRACTION = 50.0
var TIME_ATTRACTION = 0.0
var DISTANCE_EAT = 5.0

var VIEWPORT_SIZE

var PathFollower = preload("res://scripts/PathFollower.gd")
var _path_follower

var _time_pulse_audio : float
var _scale_pulse_audio_init : Vector2
var _scale_pulse_audio_final : Vector2
var SCALE_PULSE_AUDIO_OFFSET = Vector2(1.0,1.0)
var TIME_PULSE_AUDIO_SCALE = 1.0/12.0

var _pulse_shape_bary
var _shape_sound

func mouv():
	POINTS.append(POINTS[-1]+Vector2(15.0,0))
	POINTS.remove(0)
	self.set_points(POINTS)

func mouvement_1(delta) :
	var direction = (POINTS[-1] - POINTS[-2]).normalized()
	
	var new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
	while (abs(new_direction.angle_to(direction)) > 0.25) :
		new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()

	POINTS.remove(0)
	POINTS.append(POINTS[-1] + new_direction * 1)
	self.set_points(POINTS)

	
func mouvement_2(delta) :
	TIME += delta
	if TIME > PI :
		TIME = 0.0
		var new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
		while (abs(new_direction.angle_to(DIRECTION)) > 1.0) :
			new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
		
		DIRECTION = new_direction
	
	var new_offset = (Vector2(abs(cos(TIME)),abs(sin(TIME))).normalized() * (DIRECTION * sqrt(2))).normalized()

	POINTS.remove(0)
	POINTS.append(POINTS[-1] + new_offset * 1)
	self.set_points(POINTS)
	
	
func mouvement_3(delta, attraction) :
	TIME += delta
	
	var tmp
	if TIME > (PI) :
		TIME = 0.0
		var new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
		while (abs(new_direction.angle_to(DIRECTION)) > 1.0) :
			new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
			
		DIRECTION = new_direction
	
	if attraction.length() > 0.0 && TIME_ATTRACTION > 0.50:
		TIME_ATTRACTION = 0.0
		DIRECTION = attraction
	TIME_ATTRACTION += delta
	
	var tmp_direction = Vector2(0.0,0.0)
	if self.points[-1][0] < (-VIEWPORT_SIZE[0]/10.0) :
		tmp_direction[0] = 1.0
	elif self.points[-1][0] > (VIEWPORT_SIZE[0] * (1.0+1.0/10.0)) :
		tmp_direction[0] = -1.0
	
	if self.points[-1][1] < (-VIEWPORT_SIZE[1]/10.0) :
		tmp_direction[1] = 1.0
	elif self.points[-1][1] > (VIEWPORT_SIZE[1] * (1.0+1.0/10.0)) :
		tmp_direction[1] = -1.0
		
	if tmp_direction.length() > 0 :
		DIRECTION = tmp_direction.normalized()
	
	var new_offset = (Vector2(DIRECTION[1] * -1.0, DIRECTION[0]) * sin(TIME*NUMBER_SLOOPS) * AMPLITUDE + DIRECTION)
	
	var displacement = new_offset * DISTANCE/AMPLITUDE * 0.7
	
	return displacement
	
#	POINTS.remove(0)
#	POINTS.append(POINTS[-1] + (new_offset * DISTANCE/AMPLITUDE * 0.7))
#	self.set_points(POINTS)

func get_size(var points) :
	var size = 0
	for i in range(0, points.size() - 1):
		var vect = points[i+1] - points[i]
		size += vect.length()
	return size

func build(points, material) :
	self.set_points(points)
	_shape_sound = $PulseShape
	_scale_pulse_audio_init = _shape_sound.scale
	_scale_pulse_audio_final = _scale_pulse_audio_init + SCALE_PULSE_AUDIO_OFFSET
	
	_path_follower = PathFollower.new(self)
	
	$Particles2D.set_position(points[0])
	
	VIEWPORT_SIZE = Utils.Viewport_dimensions()
	
	_build_pulse_shape()
	_build_sound()
	
	set_material(material.duplicate())
	
func _build_pulse_shape():
	var circle = Utils.create_circle(5, 20)
	_shape_sound.set_points(circle)
	self.set_points(points)
	
func _build_sound():
	# set audio
	var id = round(get_size(points) / 250)
	if id >= pitches.size() :
		id = pitches.size() - 1
	$AudioNode/Audio.pitch_scale = pitches[id]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	$AudioNode/Audio.connect("finished", self, "_restart_audio")
	
	_time_pulse_audio = $AudioNode/Audio.stream.get_length() * TIME_PULSE_AUDIO_SCALE
	_pulse_sound()
	
func _pulse_sound():
	$PulseTween.interpolate_property(_shape_sound, "scale", _scale_pulse_audio_init, _scale_pulse_audio_final, _time_pulse_audio, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$PulseTween.interpolate_property(_shape_sound, "modulate", Color.white, Color(255, 255, 255, 0), _time_pulse_audio, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$PulseTween.start()
	$AudioNode/Audio.play()

func _restart_audio():
	$PulseTween.stop_all()
	_pulse_sound()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance_min_to_point = DISTANCE_ATTRACTION + 1.0
	var nearest_point 
	var points_node = $Area2D.get_overlapping_areas()
	var dist = DISTANCE_ATTRACTION + 1.0

	for pn in points_node :
		var p = pn.get_parent()
		dist = self.points[-1].distance_to(p.position)
		if dist < DISTANCE_EAT :
			p.die()
		if dist < DISTANCE_ATTRACTION :
			if dist < distance_min_to_point :
				distance_min_to_point = dist
				nearest_point = p
		
	
	var attraction = Vector2(0.0,0.0)
	if distance_min_to_point < DISTANCE_ATTRACTION :
		attraction = (nearest_point.position - self.points[-1]).normalized()
	
	#mouvement_2(delta)
	var displacement = mouvement_3(delta, attraction)
	_path_follower.move(displacement)

	$AudioNode.position = self.points[-1]
	$Area2D.position = self.points[-1]
	
	$Particles2D.set_position(points[0])
	
	var index = get_point_count()-get_point_count()/8.0
	if index >= get_point_count() || index < 0:
		index = get_point_count()-1
#	print(index)
#	print(get_point_count())
	_shape_sound.position = get_point_position(index)
