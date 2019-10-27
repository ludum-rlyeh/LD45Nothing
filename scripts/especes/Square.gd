extends Node2D

var samples = [
	"res://assets/sounds/kotoD.ogg",
	"res://assets/sounds/kotoBm.ogg",
	"res://assets/sounds/kotoAm.ogg",
	"res://assets/sounds/kotoG.ogg",
	"res://assets/sounds/kotoEm.ogg"
]


var SPEED = 0.5
var OLD_POINT
var TIME = 0

var size

var scale_factor = Vector2(1.0, 1.0)
var TIME_SCALE_ANIMATION = 1.0

var ROTATION

var _time_pulse_audio : float
var _scale_pulse_audio_init : Vector2
var _scale_pulse_audio_final : Vector2
var SCALE_PULSE_AUDIO_OFFSET = Vector2(1.0,1.0)
var TIME_PULSE_AUDIO_SCALE = 1.0/12.0
var _pulse_shape_bary
var _shape_sound


func _ready():
	randomize()
	self.add_to_group("square")
	
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

func build(var points, var rect, var material):
	
	_shape_sound = $Shape/PulseShape
	_scale_pulse_audio_init = _shape_sound.scale
	_scale_pulse_audio_final = _scale_pulse_audio_init + SCALE_PULSE_AUDIO_OFFSET
	
	self.size = rect.size
	
#	self.position = rect.position
	self.position = rect.position + rect.size / 2.0 
	OLD_POINT = self.position - Vector2(randf() * pow(-1,randi()%2),randf() * pow(-1,randi()%2)).normalized()
	
	var n_points = PoolVector2Array()
	for point in points:
		n_points.append(point - self.position)
	
	$Shape.set_points(n_points)
	
	ROTATION = pow(-1,randi()%2) * PI/2.0 * randf()
	
	_init_animation()
	
	_build_pulse_shape()
	
	_build_sound()
	
	$Shape.set_material(material.duplicate())
	
func _init_animation():
	var random = rand_range(-0.2,0.2)
	scale_factor = Vector2(1,1) + Vector2(random, random)
	$Tween2.interpolate_method(self, "set_scale", Vector2(1,1), scale_factor, TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween2.connect("tween_completed", self, "scale_animation_square")
	$Tween2.start()
	
func _build_pulse_shape():
	var pts = $Shape.points
	_shape_sound.set_points(pts)
	
func _build_sound():
	# set random sound 
	var id = round((size.x * size.y) / 50000)
	if id >= samples.size() :
		id = samples.size() - 1
	$Audio.stream = load(samples[id])

func _process(delta):
	mouvement_6(delta)
	
	Utils.out_of_viewport(self)
	
func scale_animation_square( object, key):
	if scale_factor != Vector2(1,1):
		$Tween2.interpolate_method(self, "set_scale", scale_factor, Vector2(1.0,1.0), TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		scale_factor = Vector2(1,1)
	else:
		var random = rand_range(-0.2,0.2)
		scale_factor = Vector2(1,1) + Vector2(random, random)
		$Tween2.interpolate_method(self, "set_scale", Vector2(1,1), scale_factor, TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween2.start()

func mouvement_6(delta) :
	var direction = (self.position - OLD_POINT).normalized()
	
	if TIME > PI/(2.0 * (randf()+0.2)):
		
		var new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
		while (abs(new_direction.angle_to(direction)) > 2.0) :
			new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
		direction = new_direction
		TIME = 0.0
		ROTATION = pow(-1,randi()%2) * PI/2.0 * randf()
	
	OLD_POINT = self.position
	self.set_position(self.position + direction * SPEED)
	self.rotate(ROTATION*delta)
	TIME += delta

