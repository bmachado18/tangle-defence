extends Control

@export var grid_size := 32

func _ready():
	update_minimum_size()  # Forces draw when ready

func _draw():
	var size = get_size()
	for x in range(0, int(size.x), grid_size):
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.2, 0.2, 0.2, 0.4))
	for y in range(0, int(size.y), grid_size):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.2, 0.2, 0.2, 0.4))
