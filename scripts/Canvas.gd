extends Node2D

signal _new_boid_sig # to emit with species and points

var THRESHOLD_NEIGHBOURING = 50

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("draw"):
		var pencil = preload("res://scenes/Pencil.tscn").instance()
		pencil.connect("_new_shape_sig", self, "_on_new_shape") 
		add_child(pencil)

func _on_new_shape(var line2d):
	call_deferred("recognition", line2d)

func recognition(var line2d):
	var points = Utils.remove_duplicates(line2d.points)
	var boid_type = null;
	
	var shape = points
	
	if shape.size() > 0 :
		if start_and_end_are_close(shape, THRESHOLD_NEIGHBOURING) :
			if not_a_lot_of_points(shape, 10) :
				boid_type = "point";
			elif has_edges(shape, 3)  :
				boid_type = "triangle"
			elif has_edges(shape, 4):
				boid_type = "square"
			else:
				boid_type = "circle";
			
			emit_signal("_new_boid_sig", boid_type, line2d, shape)
			
		else:
#			if(shape.size() > 400):
#				line2d.call_deferred("queue_free")
#				return
			#	print(points.size())
			var shapes = Utils.split_in_subarrays(points, 15)
			for shape2 in shapes:
				if in_box(shape2, 0.9) :
					boid_type = "line";
				else :
					boid_type = "snake";
		
				emit_signal("_new_boid_sig", boid_type, line2d, shape2)
	

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


