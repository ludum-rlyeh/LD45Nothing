extends Sprite

var samples = [
	"res://assets/sounds/drum01.ogg",
	"res://assets/sounds/drum02.ogg",
	"res://assets/sounds/drum03.ogg",
	"res://assets/sounds/drum04.ogg",
	"res://assets/sounds/drum05.ogg",
	"res://assets/sounds/drum06.ogg",
	"res://assets/sounds/drum07.ogg"
]

signal die_sig

var MAX_VELOCITY
var velocity = Vector2(0.0, 0.0)

var attraction_dist = 200
var orientation_dist = 180
var separation_dist = 50

var OLD_POINT
var TIME = 0

	
func mouvement_6(delta) :
	var direction = (self.position - OLD_POINT).normalized()
	
	if TIME > PI/(4.0 * (randf()+0.2)):
		
		var new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
		while (abs(new_direction.angle_to(direction)) > 2.0) :
			new_direction = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2)).normalized()
		direction = new_direction
		TIME = 0.0
	
	OLD_POINT = self.position
	self.set_position(self.position + direction * 1)
	TIME += delta
	
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	self.add_to_group("points")
	
	var sample = samples[randi() % samples.size()]
	$Audio.stream = load(sample)	
	

# warning-ignore:unused_argument
func build(var points) :
	OLD_POINT = self.position - Vector2(randf() * pow(-1,randi()%2),randf() * pow(-1,randi()%2)).normalized()
	MAX_VELOCITY = rand_range(50.0, 80.0)
	

func _process(delta) :
	var boids = get_tree().get_nodes_in_group("points")
	
	var attraction_vec2 = Vector2(0.0, 0.0)
	var orientation_vec2 = Vector2(0.0, 0.0) 
	var separation_vec2 = Vector2(0.0, 0.0)
	var n_attract = 0
	if boids.size() > 1 :
		
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
		
		if n_orien != 0 :
			orientation_vec2 /= n_orien
			orientation_vec2 = (orientation_vec2 - self.velocity) / 8.0
	
	
	if n_attract != 0 :
		attraction_vec2 /= n_attract 
		attraction_vec2 = (attraction_vec2 - self.position) / 100.0
		
		self.velocity += attraction_vec2 + orientation_vec2 + separation_vec2
		self.velocity = limit_velocity(self.velocity)
		
		OLD_POINT = self.position
		self.position += self.velocity * delta
	else : # no other points in neigborhood
		mouvement_6(delta)
			
	Utils.out_of_viewport(self)
	

func die():
	set_process(false)
	emit_signal("die_sig")

func limit_velocity(var velocity) :
	if velocity.length() > MAX_VELOCITY :
		velocity = (velocity / velocity.length()) * MAX_VELOCITY 
	return velocity
