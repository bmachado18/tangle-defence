extends Node2D

@export var speed = 100
var strength = 3.0

func _process(delta):
	# Access the parent PathFollow2D node

	if get_parent() is PathFollow2D:
		get_parent().offset += speed * delta
