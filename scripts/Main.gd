extends Control

var canvas
var viewport

var bg

var ressource = preload("res://assets/BG.jpg")


#var viewport_text0
#var viewport_text1
#var viewport_text2

func _ready():
	viewport = $ViewportContainer/Viewport
	canvas = $Canvas
	
	randomize()
	canvas.connect("_new_boid_sig", self, "_on_new_boid")
	
	bg = ImageTexture.new()
	bg.create_from_image(ressource.get_data())
	
	$ViewportContainer.material.set_shader_param("BGTexture", bg)
#	$ViewportContainer.material.set_shader_param("ViewportTexture", render_text)

#	viewport_text2 = viewport.get_texture();
#	viewport_text0 = ImageTexture.new()
#	viewport_text0.create_from_image(viewport.get_texture().get_data())
#	viewport_text1 = ImageTexture.new()
#	viewport_text1.create_from_image(viewport.get_texture().get_data())
	
	

func _on_new_boid(var boid_type, var line2d, var points):
	call_deferred("add_boid", boid_type, line2d, points)
	
#
#func _process(delta):
#	$ViewportContainer.material.set_shader_param("ViewportTexture0", viewport_text0)
#	$ViewportContainer.material.set_shader_param("ViewportTexture1", viewport_text1)
#	$ViewportContainer.material.set_shader_param("ViewportTexture2", viewport_text2)
#
#	viewport_text0.set_data(viewport_text1.get_data())
#	viewport_text1.set_data(viewport_text2.get_data())
	

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
			boid = preload("res://scenes/especes/Triangle.tscn").instance()
		"square":
			boid = preload("res://scenes/especes/Square.tscn").instance()
		"snake":
			boid = preload("res://scenes/especes/Serpentin.tscn").instance()
		
	if boid != null :
		boid.build(points)
		viewport.add_child(boid)
	
	line2d.queue_free()
