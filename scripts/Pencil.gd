extends Line2D

signal _new_shape_sig

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_released("draw"):
		$Timer.stop()
		emit_signal("_new_shape_sig", self)

func _on_Timer_timeout():
	var point = get_global_mouse_position()
	add_point(point)
	$Audio.position = point
	$Timer.start()
