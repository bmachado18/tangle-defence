extends Node2D

var selected_node = null
var edges = []

func _ready():
	
	#var node_A = get_node('Nodes/Node_A')
	#node_A.selected_node.connect(_on_node_selected)
	for node in $Nodes.get_children():
		print(node.get_child(0).name)
		node.get_child(0).connect("node_selected", Callable(self, "_on_node_selected"))
		
func _on_node_selected(node):
	if selected_node == null:
		print("node has been selected")
		selected_node = node
	else:
		if selected_node != node:
			create_edge(selected_node, node)
		selected_node = null
		
func create_edge(a, b):

	var edge = preload("res://Scenes/Edge.tscn").instantiate()
	$Edges.add_child(edge)
	edge.initialize(a, b)
	edges.append(edge)
	check_crosses()

func check_crosses():
	for e1 in edges:
		e1.cross_count = 0
	for i in edges.size():
		for j in range(i + 1, edges.size()):
			if do_edges_cross(edges[i], edges[j]):
				edges[i].cross_count += 1
				edges[j].cross_count += 1
	for edge in edges:
		edge.update_strength()

func do_edges_cross(e1, e2):
	var a1 = e1.from_node.global_position
	var b1 = e2.from_node.global_position
	var a2 = e1.to_node.global_position
	var b2 = e2.to_node.global_position
	return Geometry2D.segment_intersects_segment(a1, a2, b1, b2)
