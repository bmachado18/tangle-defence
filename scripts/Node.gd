extends Area2D

signal node_selected(node)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		
		emit_signal("node_selected", self)
		
