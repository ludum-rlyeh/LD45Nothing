extends Node2D

var MIN_ANGLE = 20
var MAX_ANGLE = 250

var origin : Vector2
var vec_line : Vector2
var length
var cumulate_angle = 0
var total_angle
var SPEED_ANGLE = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	build([50,0])

	pass # Replace with function body.
	
func _process(delta):
	move(delta)

func build(shape):
	origin = shape[0]
	vec_line = shape[1] - origin
	length = vec_line.length()
	total_angle = new_angle()
	
	var points = [origin + Vector2(0, 10), origin - Vector2(0, 10), origin + vec_line + Vector2(0, -10), origin + vec_line + Vector2(0, 10)]
#	self.set_polygon(points)
	
func move(delta):
	var angle = total_angle * delta
	self.rotate(min(angle, abs(total_angle - cumulate_angle)))
	cumulate_angle += angle
	
	
	if (cumulate_angle > total_angle):
		cumulate_angle = 0
		total_angle = new_angle()
		
func random_angle_between(minVal, maxVal):
	rand_range(minVal , maxVal)
	
func new_angle():
	return random_angle_between(MIN_ANGLE, MAX_ANGLE)
