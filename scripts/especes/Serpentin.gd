extends Line2D

var samples = [
	"res://assets/sounds/shakuhachi01.ogg",
	"res://assets/sounds/shakuhachi02.ogg",
	"res://assets/sounds/shakuhachi03.ogg",
	"res://assets/sounds/shakuhachi04.ogg",
	"res://assets/sounds/shakuhachi05.ogg",
	"res://assets/sounds/shakuhachi06.ogg",
	"res://assets/sounds/shakuhachi07.ogg"
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
	
	var new_offset = (Vector2(DIRECTION[1] * -1.0, DIRECTION[0]) * sin(TIME*NUMBER_SLOOPS) * AMPLITUDE + DIRECTION)
	

	POINTS.remove(0)
	POINTS.append(POINTS[-1] + (new_offset * DISTANCE/AMPLITUDE * 0.7))
	self.set_points(POINTS)

func build(points) :
#	POINTS = points
	POINTS = []
	POINTS.append(points[0])
	var distance = 0.0
	var direction
	for i in range(0,points.size() - 1) :
		distance = points[i].distance_to(points[i+1])
		distance = int(distance)
		direction = (points[i+1] - points[i]).normalized() * DISTANCE
		for d in range(0,distance) :
			#POINTS.append(points[-1])
			POINTS.append(POINTS[-1] + direction)
		POINTS.append(points[i+1])
		
	self.set_points(POINTS)
#	OLD_POSITION = self.points[-1]

	$Particles2D.set_position(points[0])
	
	$AudioNode.position = self.points[-1]
	var sample = samples[randi()%samples.size()]
	$AudioNode/Audio.stream = load(sample)


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
#	var points = PoolVector2Array([Vector2(100.0,100.0), Vector2(130.0,100.0), Vector2(145.0,100.0), Vector2(160.0,100.0), Vector2(175.0,100.0), Vector2(190.0,100.0)])
#	var array = []
#	for i in range(0,200) :
#		array.append(Vector2(i*1.0,300.0))
#	points = PoolVector2Array(array)
#	self.set_points(points)
#
#	build(points)
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance_min_to_point = DISTANCE_ATTRACTION + 1.0
	var nearest_point 
	var points_node = get_tree().get_nodes_in_group("points")
	var dist = DISTANCE_ATTRACTION + 1.0

	for p in points_node :
		dist = self.points[-1].distance_to(p.position)
		if dist < DISTANCE_EAT :
			p.die()
		if dist < DISTANCE_ATTRACTION :
			if dist < distance_min_to_point :
				distance_min_to_point = dist
				nearest_point = p
		
	
	var attraction = Vector2(0.0,0.0)
	if distance_min_to_point < DISTANCE_ATTRACTION :
		attraction = (nearest_point.position - POINTS[-1]).normalized()
	
	#mouvement_2(delta)
	mouvement_3(delta, attraction)
	$AudioNode.position = self.points[-1]
	
	$Particles2D.set_position(points[0])

	#mouv()
