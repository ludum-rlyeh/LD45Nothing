extends Control

var canvas
var viewport

var bg

var ressource = preload("res://assets/BG.jpg")


func _ready():
	viewport = $ViewportContainer/Viewport
	canvas = $Canvas
	
	randomize()
	canvas.connect("_new_boid_sig", self, "_on_new_boid")
	
	bg = ImageTexture.new()
	bg.create_from_image(ressource.get_data())
	
#	$ViewportContainer.material.set_shader_param("BGTexture", bg)
	
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_cancel") :
		get_tree().quit()

func _on_new_boid(var boid_type, var line2d, var points):
	call_deferred("add_boid", boid_type, line2d, points)
	

func add_boid(var boid_type, var line2d, var points):
#	var viewport = $Viewport
#	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
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
			boid = preload("res://scenes/especes/Triangle2.tscn").instance()
		"square":
			boid = preload("res://scenes/especes/Square.tscn").instance()
		"snake":
			boid = preload("res://scenes/especes/Serpentin.tscn").instance()
		
	if boid != null :
		boid.build(points, line2d.l_total)
		viewport.add_child(boid)
	
	line2d.queue_free()
