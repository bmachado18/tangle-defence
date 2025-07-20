extends Node2D
var selected_node = null
var edges = []
var enemy_count = 0
var edge_pairs = {}
var edge_count = 0

var grid_size = 32

var is_placing_node := false



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
	var enemy = preload("res://scenes/Enemy.tscn").instantiate()
	# Start at beginning up path
	enemy.progress = 0
	
 	#add directly to path2d
	$Path2D.add_child(enemy)

	enemy_count += 1
	
	# Add the enemy directly to Path2D, not to PathFollow2D
	#$Path2D.get_child(0).add_child(enemy)
	print("Spawned enemy #", enemy_count)

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()


func _on_texture_button_toggled(toggled_on: bool) -> void:
	is_placing_node = toggled_on
	print("Node placement mode:", is_placing_node)

func _unhandled_input(event):
	if is_placing_node and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_pos = get_global_mouse_position()
		var grid_size = 32  # Or whatever your tile size is
		var grid_pos = Vector2(
			floor(click_pos.x / grid_size) * grid_size,
			floor(click_pos.y / grid_size) * grid_size
		)
		place_node(grid_pos)
		
func place_node(pos: Vector2):
	var new_node = preload("res://scenes/node.tscn").instantiate()
	new_node.position = pos
	$Nodes.add_child(new_node)
	print("Placed node at:", pos)
	new_node.get_child(0).connect("node_selected", Callable(self, "_on_node_selected"))

	is_placing_node = false
	$Panel/TextureButton.button_pressed = false

func _draw():
	var view_size = get_viewport_rect().size
	for x in range(0, int(view_size.x), grid_size):
		draw_line(Vector2(x, 0), Vector2(x, view_size.y), Color(0.2, 0.2, 0.2, 0.4))
	for y in range(0, int(view_size.y), grid_size):
		draw_line(Vector2(0, y), Vector2(view_size.x, y), Color(0.2, 0.2, 0.2, 0.4))
