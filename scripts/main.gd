extends Node2D
var selected_node = null
var edges = []
var enemy_count = 0
var enemy = []
var edge_pairs = {}
var edge_count = 0

func _ready():
	for node in $Nodes.get_children():
		print(node.get_child(0).name)
		node.get_child(0).connect("node_selected", Callable(self, "_on_node_selected"))
		
func _on_node_selected(node):
	if selected_node == null:
		print("Node: %s has been selected" % node.get_parent().name)
		selected_node = node
	else:
		if selected_node != node:
			if not edge_exists(selected_node, node):
				print("Adding edge between: %s and %s" % [selected_node.get_parent().name, node.get_parent().name])
				create_edge(selected_node, node)
			else:
				print("Edge already exists between %s and %s" % [selected_node.get_parent().name, node.get_parent().name])
		selected_node = null

func get_edge_key(a, b) -> String:
	var names = [a.get_parent().name, b.get_parent().name]
	names.sort()
	return "%s-%s" % names

func edge_exists(a, b) -> bool:
	return get_edge_key(a, b) in edge_pairs

func create_edge(a, b):
	var edge = preload("res://Scenes/Edge.tscn").instantiate()
	$Edges.add_child(edge)
	edge.initialize(a, b)
	edges.append(edge)
	
	# Register this edge preventing duplicates
	edge_pairs[get_edge_key(a, b)] = true
	edge_count += 1
	print("Edge created with strength:", edge.strength)
	
	check_crosses()

func check_crosses():
	# Reset cross counts
	for e1 in edges:
		e1.cross_count = 0
	
	# Calculate crossings
	for i in edges.size():
		for j in range(i + 1, edges.size()):
			if do_edges_cross(edges[i], edges[j]):
				edges[i].cross_count += 1
				edges[j].cross_count += 1
	
	# Update all edge strengths and visuals
	for edge in edges:
		edge.update_strength()
		edge.update_position()  # Update label position too

func do_edges_cross(e1, e2):
	var a1 = e1.from_node.global_position
	var b1 = e2.from_node.global_position
	var a2 = e1.to_node.global_position
	var b2 = e2.to_node.global_position
	return Geometry2D.segment_intersects_segment(a1, a2, b1, b2)
	
func start_wave():
	var enemy = preload("res://scenes/Enemy.tscn").instantiate()
	$Path2D.add_child(enemy)

func spawn_enemy():
	var enemy_scene = preload("res://scenes/Enemy.tscn")
	var enemy = enemy_scene.instantiate()
	
	enemy_count += 1
	
	# Add the enemy directly to Path2D, not to PathFollow2D
	$Path2D.get_child(0).add_child(enemy)

func _on_enemy_spawn_timer_timeout() -> void:
	#print("spawning enemy", enemy_count)
	#spawn_enemy()
	pass
