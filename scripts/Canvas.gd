extends Node2D

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("draw"):
		var pencil = preload("res://scenes/Pencil.tscn").instance()
		add_child(pencil)