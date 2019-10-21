extends Node2D

var deformation_coefs = []
var normals = []

var samples = [
	"res://assets/sounds/shamisenD.ogg",
	"res://assets/sounds/shamisenBm.ogg",
	"res://assets/sounds/shamisenAm.ogg",
	"res://assets/sounds/shamisenG.ogg",
	"res://assets/sounds/shamisenEm.ogg"
]

var SPEED = 0.5
var OLD_POINT
var TIME = 0

var size


var scale_factor = Vector2(1.0, 1.0)
var TIME_SCALE_ANIMATION = 2.0

var _time_pulse_audio : float
var _scale_pulse_audio_init : Vector2
var _scale_pulse_audio_final : Vector2
var SCALE_PULSE_AUDIO_OFFSET = Vector2(1.0,1.0)
var TIME_PULSE_AUDIO_SCALE = 1.0/12.0

var _pulse_shape_bary
var _shape_sound

func _ready():
	randomize()
	self.add_to_group("boids")
	
	#	$Shape.connect("die_sig", self, "_on_die")
	$Audio.connect("finished", self, "_restart_audio")
	
	_time_pulse_audio = $Audio.stream.get_length() * TIME_PULSE_AUDIO_SCALE
	_pulse_sound()
	
func _pulse_sound():
	$PulseTween.interpolate_method(self, "_scale_pulse_shape", _scale_pulse_audio_init, _scale_pulse_audio_final, _time_pulse_audio, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$PulseTween.interpolate_property(_shape_sound, "modulate", Color.white, Color(255, 255, 255, 0), _time_pulse_audio, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$PulseTween.start()
	$Audio.play()
	
func _scale_pulse_shape(scale):
	_shape_sound.set_scale(scale)
	
func _restart_audio():
	$PulseTween.stop_all()
	_pulse_sound()

func build(var points, var material):
	
	_shape_sound = $Shape/PulseShape
	_scale_pulse_audio_init = _shape_sound.scale
	_scale_pulse_audio_final = _scale_pulse_audio_init + SCALE_PULSE_AUDIO_OFFSET
	
	var rect = Utils.getBBox(points)
	size = rect.size
	
	self.position = rect.position
	OLD_POINT = self.position - Vector2(randf() * pow(-1,randi()%2),randf() * pow(-1,randi()%2)).normalized()
	
	var n_points = PoolVector2Array()
	var i = 0
	for point in points:
		var pt = point - self.position
		n_points.append(pt)
#		deformation_coefs.append(rand_range(-1,1))
#		normal.append(Utils.process_normal_3_points(i, points))
		
	$Shape.set_points(n_points)
	
	_build_sound()	
	
	_build_pulse_shape()
	
	_init_animation()
	
	$Shape.set_material(material.duplicate())
	
func _init_animation():
	scale_factor = Vector2(1,1) + Vector2(rand_range(-0.2,0.2), rand_range(-0.2,0.2))
	$Tween.interpolate_method(self, "set_scale", Vector2(1,1), scale_factor, TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.connect("tween_completed", self, "scale_animation")
	$Tween.start()
	
func _build_pulse_shape():
	var pts = $Shape.points
	var box = Utils.getBBox(pts)
	var center = box.size/2.0
	
	pts = Utils.apply_translation(pts, - center)
	_shape_sound.set_points(pts)
	
	_shape_sound.position += center
	
func _build_sound():
	# set random sound 
	var id = round((size.x * size.y) / 50000)
	if id >= samples.size() :
		id = samples.size() - 1
	$Audio.stream = load(samples[id])
	
func scale_animation( object, key):
	if scale_factor != Vector2(1,1):
		$Tween.interpolate_method(self, "set_scale", scale_factor, Vector2(1.0,1.0), TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		scale_factor = Vector2(1,1)
	else:
		scale_factor = Vector2(1,1) + Vector2(rand_range(-0.2,0.2), rand_range(-0.2,0.2))
		$Tween.interpolate_method(self, "set_scale", Vector2(1,1), scale_factor, TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
func _process(delta):
	mouvement_6(delta)
	Utils.out_of_viewport(self)

func mouvement_6(delta) :
	var direction = (self.position - OLD_POINT).normalized()
	
	if TIME > PI/(2.0 * (randf()+0.2)):
		
		var new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
		while (abs(new_direction.angle_to(direction)) > 2.0) :
			new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
		direction = new_direction
		TIME = 0.0
	
	OLD_POINT = self.position
	self.set_position(self.position + direction * SPEED)
	TIME += delta



