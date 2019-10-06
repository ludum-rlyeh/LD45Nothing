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

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal die_sig

var RAND_SCALE = 1
var LOOP_MAX = 100
var LOOP_CURRENT = 0
var DIRECTION_X
var DIRECTION_Y
var DIRECTIONS
var SPEED_MAX = 5.0
var BRAKE_RATIO = 2.0
var BRAKE = SPEED_MAX / BRAKE_RATIO
var ACCELERATE = (SPEED_MAX - BRAKE) / LOOP_MAX
var SPEED = SPEED_MAX - BRAKE
var ANGLE_SMOOTH = 0.0

var TARGET
var BEGIN = Vector2(0.0, 0.0)
var DISTANCE_MIN = 50.0
var DISTANCE_TARGET = 15.0
var SPEEDS = Vector2(0.0,0.0)
var DISTANCE_MAX = 20.0
var SPEED_INTERPOLATION = 20.0

var OLD_POSITIONS = []

var POINTS = []

var OLD_POINT
var TIME = 0



var X_SIZE = 1024
var Y_SIZE = 1024

func out_of_bound() :
	if (self.position.x < 0 && DIRECTIONS[0] < 0.0) || (self.position.x > X_SIZE && DIRECTIONS[0] > 0.0) :
		DIRECTIONS[0] *= -1
	if (self.position.y < 0 && DIRECTIONS[1] < 0.0) || (self.position.y > Y_SIZE && DIRECTIONS[1] > 0.0) :
		DIRECTIONS[1] *= -1
		

func mouvement_1() :
	out_of_bound()
	if LOOP_CURRENT > LOOP_MAX :
		LOOP_CURRENT = 0
		var dir_x = randf() * RAND_SCALE * pow(-1,(randi() % 2))
		var dir_y = randf() * RAND_SCALE * pow(-1,(randi() % 2))
		DIRECTIONS = Vector2(dir_x,dir_y)

	self.move_local_x(DIRECTIONS[0])
	self.move_local_y(DIRECTIONS[1])
	
	LOOP_CURRENT += 1
	
func mouvement_2() :
	out_of_bound()
	if LOOP_CURRENT > LOOP_MAX :
		LOOP_CURRENT = 0
		var dir_x = randf() *  pow(-1,(randi() % 2))
		var dir_y = randf() *  pow(-1,(randi() % 2))
		var speed = sqrt(pow(dir_x,2) + pow(dir_y,2))
		DIRECTIONS[0] = dir_x * (SPEED/speed)
		DIRECTIONS[1] = dir_y * (SPEED/speed)
		
		

	self.move_local_x(DIRECTIONS[0])
	self.move_local_y(DIRECTIONS[1])
	
	LOOP_CURRENT += 1
	
	
func draw_directions_smooth() :
	var dir_x = randf() *  pow(-1,(randi() % 2))
	var dir_y = randf() *  pow(-1,(randi() % 2))
		
	while(Vector2(dir_x,dir_y).dot(Vector2(DIRECTIONS[0],DIRECTIONS[1])) < ANGLE_SMOOTH) :
		dir_x = randf() *  pow(-1,(randi() % 2))
		dir_y = randf() *  pow(-1,(randi() % 2))

	return Vector2(dir_x, dir_y).normalized()


func mouvement_3() :
	out_of_bound()
	if SPEED <= (SPEED_MAX - ACCELERATE) :
		SPEED += ACCELERATE
	
	DIRECTIONS = DIRECTIONS.normalized() * SPEED
	
	if LOOP_CURRENT > LOOP_MAX :
		LOOP_CURRENT = 0
		SPEED = SPEED - BRAKE 
		var dirs = draw_directions_smooth()
	
		DIRECTIONS = dirs * SPEED 
		
		

	self.move_local_x(DIRECTIONS[0])
	self.move_local_y(DIRECTIONS[1])
	
	LOOP_CURRENT += 1
	
	
func out_of_bound_target() :
	if ((TARGET[0] + DIRECTIONS[0]) < 0) :
		TARGET[0] = 0
	if ((TARGET[0] + DIRECTIONS[0]) > X_SIZE) :
		TARGET[0] = X_SIZE
	
	if ((TARGET[1] + DIRECTIONS[0]) < 0) :
		TARGET[1] = 0
	if ((TARGET[1] + DIRECTIONS[1]) > Y_SIZE) :
		TARGET[1] = Y_SIZE
	
	
func mouvement_4(delta):
	
	var dir_x = randf() *  pow(-1,(randi() % 2))
	var dir_y = randf() *  pow(-1,(randi() % 2))
	var dirs = Vector2(dir_x,dir_y).normalized() * DISTANCE_TARGET
		
	TARGET += dirs
	out_of_bound_target()
	
	self.position = self.position.linear_interpolate(TARGET, delta*SPEED_MAX)


func mouvement_5(delta):
	DIRECTIONS = Vector2(randf() * pow(-1,randi()%2), randf() * pow(-1,randi()%2))
	TARGET += DIRECTIONS.normalized() * DISTANCE_TARGET
	
	self.position = self.position.linear_interpolate(TARGET, delta * 0.5)
	
	pass
	
func mouvement_6(delta) :
	var direction = (self.position - OLD_POINT).normalized()
	print(direction)
	
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
	DIRECTION_X = randf() * pow(-1,randi()%2)
	DIRECTION_Y = randf() * pow(-1,randi()%2)
	DIRECTIONS = Vector2(DIRECTION_X,DIRECTION_Y).normalized()
#	X_SIZE = get_viewport().size.x
#	Y_SIZE = get_viewport().size.y
	
	var sample = samples[randi() % samples.size()]
	$Audio.stream = load(sample)
	
	set_process(false)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func build(var points) :
#	var poly = [Vector2(0,0), Vector2(5,0), Vector2(2.5,5)]
	
#	POINTS = poly
	OLD_POINT = self.position - Vector2(randf() * pow(-1,randi()%2),randf() * pow(-1,randi()%2)).normalized()
	TARGET = self.position

#	self.set_polygon(POINTS)




	

func _process(delta) :
#	mouvement_1()
#	mouvement_2()
#	mouvement_3()
#	mouvement_4(delta)
	#mouvement_5(delta)
	#mouvement_5(delta)
	mouvement_6(delta)
	if Utils.out_of_viewport(self) == 1 :
		TARGET = self.position
	pass

func die():
	set_process(false)
	emit_signal("die_sig")
