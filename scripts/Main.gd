extends Node2D

var ABuffer = ViewportTexture.new()

func _ready():
	randomize()
	$Canvas.connect("_new_boid_sig", self, "_on_new_boid")
	
	var viewport = get_viewport()
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER

func _on_new_boid(var boid_type, var line2d):
	call_deferred("add_boid", boid_type, line2d)
	

func add_boid(var boid_type, var line2d):
	
	var boid = null
	print_debug(boid_type)
	
	match boid_type :
		"point":
			boid = preload("res://scenes/especes/point.tscn").instance()
		"line":
			boid = preload("res://scenes/especes/bascule.tscn").instance()
		"circle":
			boid = preload("res://scenes/especes/Boid.tscn").instance()
		"triangle":
			boid = preload("res://scenes/especes/Triangle.tscn").instance()
		"square":
			boid = preload("res://scenes/especes/Square.tscn").instance()
		"snake":
			boid = preload("res://scenes/especes/Serpentin.tscn").instance()
		
	if boid != null :
		boid.build(line2d.points)
		add_child(boid)
	
	line2d.queue_free()
