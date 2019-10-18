extends Line2D

signal _new_shape_sig

var l_total = 0.0

func start_painting():
	$Audio.play()
	$Timer.start()
	l_total = 0.0
		
func stop_painting():
	$Audio.stop()
	$Timer.stop()
	emit_signal("_new_shape_sig")
	clear_points()

func _on_Timer_timeout():
	var point = get_global_mouse_position()
	add_point(point)
	var nb_points = get_point_count()
	if(nb_points > 1):
		l_total += get_point_position(nb_points-2).distance_to(get_point_position(nb_points-1))
	get_material().set_shader_param("l_total", l_total)
	$Audio.position = point
	$Timer.start()
