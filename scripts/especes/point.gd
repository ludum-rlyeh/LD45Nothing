extends Sprite

signal die_sig

var MAX_VELOCITY
var velocity

var separation_dist = 80

var size = Vector2(100,100) # x: height and y: width

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
	self.velocity = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
	
# warning-ignore:unused_argument
func build(var points) :
	OLD_POINT = self.position - Vector2(randf() * pow(-1,randi()%2),randf() * pow(-1,randi()%2)).normalized()
	MAX_VELOCITY = rand_range(50.0, 80.0)
	
	set_material(get_material().duplicate())
	
	var offset_time = rand_range(-1.0, 1.0)
	get_material().set_shader_param("u_time_offset", offset_time)

func _process(delta) :
	
	var attraction_vec2 = Vector2(0.0, 0.0)
	var orientation_vec2 = Vector2(0.0, 0.0) 
	var separation_vec2 = Vector2(0.0, 0.0)
	
	var boids = $AttractionArea.get_overlapping_areas()
	var nb_boids = boids.size()
	if nb_boids > 1 :
		
		for boid in boids :
			var p_boid = boid.get_parent()
			if p_boid != self :
				var b_pos = p_boid.position
				var dist = b_pos.distance_to(self.position)
				# Attraction
				attraction_vec2 = attraction_vec2 + b_pos
				
				# Orientation
				orientation_vec2 = orientation_vec2 + p_boid.velocity
				
				# separation
				if dist <= separation_dist :
					separation_vec2 = separation_vec2 - (b_pos - self.position)
					
		orientation_vec2 /= (nb_boids-1)
		orientation_vec2 = (orientation_vec2 - self.velocity) / 8.0
			
		attraction_vec2 /= (nb_boids-1) 
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

