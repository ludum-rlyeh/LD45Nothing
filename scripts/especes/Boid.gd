extends Node2D

var deformation_coefs = []
var normals = []

var samples = [
	"res://assets/sounds/shamisenD.ogg",
	"res://assets/sounds/shamisenDontKnow.ogg",
	"res://assets/sounds/shamisenEm.ogg",
	"res://assets/sounds/shamisenG.ogg"
]

var SPEED = 0.5
var OLD_POINT
var TIME = 0

var size


var scale_factor = Vector2(1.0, 1.0)
var TIME_SCALE_ANIMATION = 2.0

func _ready():
	randomize()
	self.add_to_group("boids")
	
	# set ramdom sound
	var sample = samples[randi() % samples.size()]
	$Audio.stream = load(sample)
	

func build(var points, l_total):
	
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
	
	
	scale_factor = Vector2(1,1) + Vector2(rand_range(-0.2,0.2), rand_range(-0.2,0.2))
	$Tween.interpolate_method(self, "set_scale", Vector2(1,1), scale_factor, TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.connect("tween_completed", self, "scale_animation")
	$Tween.start()
	
	$Shape.get_material().set_shader_param("l_total", l_total)
	
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



