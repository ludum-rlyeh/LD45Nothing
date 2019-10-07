extends Node2D

var samples = [
	"res://assets/sounds/kotoD.ogg",
	"res://assets/sounds/kotoDontKnow.ogg",
	"res://assets/sounds/kotoEm.ogg",
	"res://assets/sounds/kotoG.ogg"
]

var MAX_VELOCITY = 20.0
var velocity = Vector2(0.0, 0.0)

var attraction_dist = 200
var orientation_dist = 180
var separation_dist = 100


var scale_factor = Vector2(1.0, 1.0)
var TIME_SCALE_ANIMATION = 1.0

func _ready():
	randomize()
	self.add_to_group("square")
	
	# set ramdom sound
	var sample = samples[randi() % samples.size()]
	$Audio.stream = load(sample)

func build(var points):
	
	var rect = Utils.getBBox(points)
	
	self.position = rect.position
	
	var n_points = PoolVector2Array()
	for point in points:
		n_points.append(point - self.position)
	
	$Shape.set_polygon(n_points)
	
	
	velocity = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0))
	
	var random = rand_range(-0.2,0.2)
	scale_factor = Vector2(1,1) + Vector2(random, random)
	$Tween2.interpolate_method(self, "set_scale", Vector2(1,1), scale_factor, TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween2.connect("tween_completed", self, "scale_animation_square")
	$Tween2.start()

func _process(delta):
	var boids = get_tree().get_nodes_in_group("square")
	
	if boids.size() > 1 :
		var attraction_vec2 = Vector2(0.0, 0.0)
		var orientation_vec2 = Vector2(0.0, 0.0) 
		var separation_vec2 = Vector2(0.0, 0.0)
	
		var n_attract = 0
		var n_orien = 0
		for boid in boids :
			if boid != self :
				var b_pos = boid.position
				var dist = b_pos.distance_to(self.position)
				# Attraction
				if dist <= attraction_dist :
					n_attract += 1
					attraction_vec2 = attraction_vec2 + b_pos
	
					# Orientation
					if dist <= orientation_dist :
						n_orien += 1
						orientation_vec2 = orientation_vec2 + boid.velocity
	
						# separation
						if dist <= separation_dist :
							separation_vec2 = separation_vec2 - (b_pos - self.position)
	
		if n_attract != 0 :
			attraction_vec2 /= n_attract 
			attraction_vec2 = (attraction_vec2 - self.position) / 100.0
	
		if n_orien != 0 :
			orientation_vec2 /= n_orien
			orientation_vec2 = (orientation_vec2 - self.velocity) / 8.0
		
		self.velocity += attraction_vec2 + orientation_vec2 + separation_vec2
		self.velocity = limit_velocity(self.velocity)
		
	
	
	self.position += self.velocity * delta
	Utils.out_of_viewport(self)
	
func scale_animation_square( object, key):
	print(scale_factor)
	if scale_factor != Vector2(1,1):
		$Tween2.interpolate_method(self, "set_scale", scale_factor, Vector2(1.0,1.0), TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		scale_factor = Vector2(1,1)
	else:
		var random = rand_range(-0.2,0.2)
		scale_factor = Vector2(1,1) + Vector2(random, random)
		$Tween2.interpolate_method(self, "set_scale", Vector2(1,1), scale_factor, TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween2.start()

func limit_velocity(var velocity) :
	if velocity.length() > MAX_VELOCITY :
		velocity = (velocity / velocity.length()) * MAX_VELOCITY 
	return velocity
