extends Control

var canvas
var viewport

var Point = preload("res://scenes/especes/point.tscn")
var Bascule = preload("res://scenes/especes/bascule.tscn")
var Boid = preload("res://scenes/especes/Boid.tscn")
var Triangle = preload("res://scenes/especes/Triangle2.tscn")
var Square = preload("res://scenes/especes/Square.tscn")
var Serpentin = preload("res://scenes/especes/Serpentin.tscn")

func _ready():
	viewport = $ViewportContainer/Viewport
	canvas = $Canvas
	
	randomize()
	canvas.connect("_new_boid_sig", self, "_on_new_boid")
	
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_cancel") :
		get_tree().quit()

func _on_new_boid(var boid_type, var line2d, var points):
	call_deferred("add_boid", boid_type, line2d, points)
	

func add_boid(var boid_type, var line2d, var points):
	var boid = null
	
	match boid_type :
		"point":
			boid = Point.instance()
		"line":
			boid = Bascule.instance()
		"circle":
			boid = Boid.instance()
		"triangle":
			boid = Triangle.instance()
		"square":
			boid = Square.instance()
		"snake":
			boid = Serpentin.instance()
		
	if boid != null :
		boid.build(points, line2d.l_total)
		viewport.add_child(boid)
	
	line2d.queue_free()
