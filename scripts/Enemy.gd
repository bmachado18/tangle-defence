extends PathFollow2D

@export var speed = 100
var strength = 3.0

func _process(delta):
	h_offset += speed * delta
