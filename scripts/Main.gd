extends Node2D

func _ready():
	randomize()
	$Canvas.connect("_new_boid_sig", self, "_on_new_boid")

func _on_new_boid(var boid_type, var line2d):
	call_deferred("add_boid", boid_type, line2d)
	

func add_boid(var boid_type, var line2d):
	if boid_type == "point" :
		var point = preload("res://scenes/especes/point.tscn").instance()
		point.build(line2d.points)
		add_child(point)
	
	line2d.queue_free()
