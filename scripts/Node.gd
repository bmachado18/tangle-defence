extends Area2D

signal node_selected(node)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Clicked")
		node_selected.emit("node_selected", self)
		
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	print("added")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
