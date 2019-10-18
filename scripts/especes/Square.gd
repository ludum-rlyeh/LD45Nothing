extends Node2D

var samples = [
	"res://assets/sounds/kotoD.ogg",
	"res://assets/sounds/kotoDontKnow.ogg",
	"res://assets/sounds/kotoEm.ogg",
	"res://assets/sounds/kotoG.ogg"
]

var SPEED = 0.5
var OLD_POINT
var TIME = 0

var size

var scale_factor = Vector2(1.0, 1.0)
var TIME_SCALE_ANIMATION = 1.0

var ROTATION

func _ready():
	randomize()
	self.add_to_group("square")
	
	# set ramdom sound
	var sample = samples[randi() % samples.size()]
	$Audio.stream = load(sample)

func build(var points, l_total):
	
	var rect = Utils.getBBox(points)
	self.size = rect.size
	
#	self.position = rect.position
	self.position = rect.position + rect.size / 2.0 
	OLD_POINT = self.position - Vector2(randf() * pow(-1,randi()%2),randf() * pow(-1,randi()%2)).normalized()
	
	var n_points = PoolVector2Array()
	for point in points:
		n_points.append(point - self.position)
	
#	$Shape.set_polygon(n_points)
	$Shape.set_points(n_points)
	
	
	
	var random = rand_range(-0.2,0.2)
	scale_factor = Vector2(1,1) + Vector2(random, random)
	$Tween2.interpolate_method(self, "set_scale", Vector2(1,1), scale_factor, TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween2.connect("tween_completed", self, "scale_animation_square")
	$Tween2.start()
	
	ROTATION = pow(-1,randi()%2) * PI/2.0 * randf()
	
	$Shape.get_material().set_shader_param("l_total", l_total)

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

