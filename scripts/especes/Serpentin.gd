extends Line2D

var POINTS
var LOOP = 0

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
#	print(new_direction.angle_to(direction))
	POINTS.append(POINTS[-1] + new_direction * 1)
	self.set_points(POINTS)
	
#	print(POINTS)
	

func build(points) :
	POINTS = points
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
	var points = PoolVector2Array([Vector2(100.0,100.0), Vector2(130.0,100.0), Vector2(145.0,100.0), Vector2(160.0,100.0), Vector2(175.0,100.0), Vector2(190.0,100.0)])
	var array = []
	for i in range(0,200) :
		array.append(Vector2(i*1.0,300.0))
	points = PoolVector2Array(array)
	self.set_points(points)
	
	build(points)
	
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mouvement_1(delta)
	#mouv()
	pass
