extends Node2D

var from_node
var to_node
var cross_count = 0
var strength = 0.0


const MAX_STRENGTH = 10.0
const K = 0.5
const C = 0.3

func initialize(a, b):
	from_node = a
	to_node = b
	update_strength()
	draw_edge()

func update_strength():
	var dist = from_node.global_position.distance_to(to_node.global_position)
	strength = MAX_STRENGTH / ((1 + K * dist) * (1 + C * cross_count))

func draw_edge():
	print("Drawing edge from", from_node.name, "to", to_node.name)
	$Line2D.points = [from_node.global_position, to_node.global_position]
