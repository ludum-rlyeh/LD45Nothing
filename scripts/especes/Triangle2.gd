extends Node2D

var samples = [
	"res://assets/sounds/guitarD.ogg",
	"res://assets/sounds/guitarDontKnow.ogg",
	"res://assets/sounds/guitarEm.ogg",
	"res://assets/sounds/guitarG.ogg"
]

var SPEED = 0.5
var OLD_POINT
var TIME = 0

var size

var scale_factor = Vector2(1.0, 1.0)
var TIME_SCALE_ANIMATION = 1.0

var CURR_ANGLE 
var NORMAL
var ROTATION = 0
var BASE

func _ready():
	randomize()
	self.add_to_group("triangle")
	
	# set ramdom sound
	var sample = samples[randi() % samples.size()]
	$Audio.stream = load(sample)
	
#	build([Vector2(100,100), Vector2(150,150), Vector2(200,200), Vector2(150,200), Vector2(100,200), Vector2(100,150), Vector2(100,100)], 300.0)

func build(var points, l_total):
	
	var rect = Utils.getBBox(points)
	self.size = rect.size
	
	self.position = rect.position
	
	var edges = Utils.splitByEdges(points,true)
	
	var indice_edge_min = 0
	
#	var min_length = (edges[0][0]-edges[0][1]).length()
#	var min_edge = edges[0]
#	
#	print(edges)
#	for i in range(0,edges.size()) :
#		var e = edges[i]
#		print("edge ", e)
#		if (e[0]-e[1]).length() < min_length :
#			min_length = (e[0]-e[1]).length()
#			min_edge = e
#			indice_edge_min = i
	
	var base = edges[0][1] - edges[0][0]
#	var base = min_edge[1] - min_edge[0]
	BASE = base/2.0 + edges[0][0]
	self.position = BASE
	
	
	NORMAL = -Vector2(-base[1], base[0])
	var bary = Utils.get_barycenter_from_edges(edges)
	if (bary-BASE).normalized().dot(NORMAL) < 0:
		NORMAL = -NORMAL
	
	#other NORMAL
#	var dist_max = 0.0
#	var vertex_far = edges[1][0]
#	for e in edges :
#		if self.position.distance_to(e[0]) > dist_max :
#			vertex_far = e[0]
#			dist_max = self.position.distance_to(e[0])
#		if self.position.distance_to(e[1]) > dist_max :
#			vertex_far = e[1]
#			dist_max = self.position.distance_to(e[1])
#	NORMAL = (vertex_far - self.position)
			
			
#	if indice_edge_min == 0 :
#		if base.angle_to(edges[1][1] - edges[1][0]) < 0.0 :
#			NORMAL *= -1.0
#	else :
#		if base.angle_to(edges[0][1] - edges[0][0]) < 0.0 :
#			NORMAL *= -1.0		
	
	var n_points = PoolVector2Array()
	for point in points:
		n_points.append(point - self.position)
	
	$Shape.set_points(n_points)
	
#	var rot = Vector2.RIGHT.angle_to(-NORMAL)
	
	scale_factor = Vector2(1,1) + Vector2(rand_range(-0.2,0.2), 0.0)
	$Tween2.interpolate_method(self, "set_scale", Vector2(1,1), scale_factor, TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween2.connect("tween_completed", self, "scale_animation_triangle")
	$Tween2.start()
	
	ROTATION = randf() * PI / 4.0
	
	$Particles2D.set_position(-NORMAL.normalized()*10)
	
	$Shape.get_material().set_shader_param("l_total", l_total)

func _process(delta):
	#mouvement_6(delta)
	
	self.position += NORMAL.normalized()
	TIME += delta
	
	if TIME > PI :
		if TIME < (PI * 1.3) :
			self.rotate(ROTATION*delta)
			NORMAL = NORMAL.rotated(ROTATION*delta)
		else : 
			TIME = 0
			ROTATION = randf() * PI / 4.0 * pow(-1,randi()%2)
	
	Utils.out_of_viewport(self)

	
func scale_animation_triangle( object, key):
	if scale_factor != Vector2(1,1):
		$Tween2.interpolate_method(self, "set_scale", scale_factor, Vector2(1.0,1.0), TIME_SCALE_ANIMATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		scale_factor = Vector2(1,1)
	else:
		scale_factor = Vector2(1,1) + Vector2(rand_range(-0.2,0.2), 0.0)
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
	
	OLD_POINT = self.position
	self.set_position(self.position + direction * SPEED)
	TIME += delta
