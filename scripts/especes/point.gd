extends Polygon2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var RAND_SCALE = 1
var LOOP_MAX = 20
var LOOP_CURRENT = 0
var DIRECTION_X = 1.0
var DIRECTION_Y = 1.0
var SPEED = 2.0

var X_SIZE = 1024
var Y_SIZE = 1024

func out_of_bound() :
	if (self.position.x < 0 && DIRECTION_X < 0.0) || (self.position.x > X_SIZE && DIRECTION_X > 0.0) :
		DIRECTION_X *= -1
	if (self.position.y < 0 && DIRECTION_Y < 0.0) || (self.position.y > Y_SIZE && DIRECTION_Y > 0.0) :
		DIRECTION_Y *= -1

func mouvement_1() :
	out_of_bound()
	if LOOP_CURRENT > LOOP_MAX :
		LOOP_CURRENT = 0
		DIRECTION_X = randf() * RAND_SCALE * pow(-1,(randi() % 2))
		DIRECTION_Y = randf() * RAND_SCALE * pow(-1,(randi() % 2))

	self.move_local_x(DIRECTION_X)
	self.move_local_y(DIRECTION_Y)
	
	LOOP_CURRENT += 1
	
func mouvement_2() :
	out_of_bound()
	if LOOP_CURRENT > LOOP_MAX :
		LOOP_CURRENT = 0
		var dir_x = randf() *  pow(-1,(randi() % 2))
		var dir_y = randf() *  pow(-1,(randi() % 2))
		var speed = sqrt(pow(dir_x,2) + pow(dir_y,2))
		DIRECTION_X = dir_x * (SPEED/speed)
		DIRECTION_Y = dir_y * (SPEED/speed)
		
		

	self.move_local_x(DIRECTION_X)
	self.move_local_y(DIRECTION_Y)
	
	LOOP_CURRENT += 1
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	build()
	
	X_SIZE = get_viewport().size.x
	Y_SIZE = get_viewport().size.y
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func build() :
	print(len(self.polygon))
	
	var poly = [Vector2(0,0), Vector2(5,0), Vector2(2.5,5)]
	print(self.polygon)
	self.set_polygon(poly)
	print(self.polygon)
	
	pass

func _process(delta) :
	
	mouvement_1()
	#mouvement_2()
	
	
	