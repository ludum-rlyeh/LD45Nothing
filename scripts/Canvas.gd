extends Node2D

signal _new_boid_sig # to emit with species and points

var THRESHOLD_NEIGHBOURING = 50

var PENCIL_SCENE = preload("res://scenes/Pencil.tscn")
var _pencil = PENCIL_SCENE.instance()

var pressed = false

func _ready():
	_pencil.connect("_new_shape_sig", self, "_on_new_shape") 
	add_child(_pencil)
	
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
#    if event is InputEventMouse:
#		if event.is_action_pressed("draw"):
			_pencil.start_painting()
			pressed = true
		if !event.pressed && pressed:
#		if Input.is_action_just_released("draw"):
			_pencil.stop_painting()
			pressed = false

func _on_new_shape():
	var points = Utils.remove_duplicates(_pencil.points)
	var shape = recognition(points)
	if shape.boid_type != "":
		emit_signal("_new_boid_sig", shape.boid_type, shape.points, _pencil.material)

func recognition(var points):
	var boid_type = "";
	if points.size() > 0 :
		if start_and_end_are_close(points, THRESHOLD_NEIGHBOURING) :
			if not_a_lot_of_points(points, 10) :
				boid_type = "point";
			elif has_edges(points, 3)  :
				boid_type = "triangle"
			elif has_edges(points, 4):
				boid_type = "square"
			else:
				boid_type = "circle";
		else:
			if in_box(points, 0.9) :
				boid_type = "line";
			else :
				boid_type = "snake";
		
	return {"boid_type" : boid_type, "points" : points}
		
	

func start_and_end_are_close(var points, var max_dist) :
	var start = points[0];
	var end = points[points.size() - 1]
	if start.distance_to(end) <= max_dist :
		return true
	
	return false

func not_a_lot_of_points(var points, var max_points):
	if points.size() <= max_points :
		return true
	return false

# distance from normal
func in_box(var points, var min_dot) :
	var begin = points[0]
	var end = points[points.size() - 1]
	var v = end - begin
	var v_norm = v.normalized()
	
	for point in points :
		if point != begin and point != end :
			var v2 = point - begin
			var dot = v_norm.dot(v2.normalized())
			if dot < min_dot :
				return false
	
	return true

func has_edges(var points, var n_edges) :
	var edges = Utils.splitByEdges(points, true)
	if edges.size() == n_edges :
		return true