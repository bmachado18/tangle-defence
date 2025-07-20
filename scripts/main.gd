extends Node2D


var selected_node = null
var edges = []
var edge_pairs = {}
var edge_count = 0


# Wave system
enum WaveState {
	WAITING_TO_START,
	SPAWNING_ENEMIES,
	WAVE_COMPLETE,
	ALL_WAVES_COMPLETE
}

var wave_state = WaveState.WAITING_TO_START
var current_wave = 1
var wave_sizes = [1,2,3,4]
var current_wave_enemies_spawned = 0
var current_wave_enemy_target = 0

# Timing configuration
var time_between_enemies = 0.5
var time_between_waves = 3.0
var time_before_first_wave = 2.0

var wave_timer: Timer

var grid_size = 32

var is_placing_node := false




func _ready():
	setup_node_connections()
	setup_wave_system()
	
	
func setup_node_connections():
	for node in $Nodes.get_children():
		print(node.get_child(0).name)
		node.get_child(0).connect("node_selected", Callable(self, "_on_node_selected"))

func setup_wave_system():
	# configure and create a single timer for all wave operations
	wave_timer = Timer.new()
	add_child(wave_timer)
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	wave_timer.one_shot = true
	
	print("Starting wave system in %.1f seconds" % time_before_first_wave)
	
	wave_timer.wait_time = time_before_first_wave
	wave_timer.start()

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

func _on_edge_break():
	print("signal recieved")
	pass

func do_edges_cross(e1, e2):
	var a1 = e1.from_node.global_position
	var b1 = e2.from_node.global_position
	var a2 = e1.to_node.global_position
	var b2 = e2.to_node.global_position
	return Geometry2D.segment_intersects_segment(a1, a2, b1, b2)
	

func _on_wave_timer_timeout() -> void:
	print($Path2D.get_children())
	print("=== TIMER TIMEOUT DEBUG ===")
	print("Current state: ", wave_state)
	print("Current wave: ", current_wave) 
	print("Wave sizes remaining: ", wave_sizes)
	print("Timer is_stopped: ", wave_timer.is_stopped())
	print("==========================")
	
	match wave_state:
		WaveState.WAITING_TO_START:
			print("Starting wave...")
			start_current_wave()
		#
		WaveState.SPAWNING_ENEMIES:
			print("Spawning enemy...")
			spawn_next_enemy()
		
		WaveState.WAVE_COMPLETE:
			print("Wave complete, starting next...")
			start_next_wave()
		
		WaveState.ALL_WAVES_COMPLETE:
			print("ERROR: Timer fired when all waves should be complete!")
			return

func start_current_wave():
	if wave_sizes.size() == 0:
		print("ERROR: Trying to start wave but no waves left!")
		wave_state = WaveState.ALL_WAVES_COMPLETE
		return
		
	print(" ----- ** starting wave %d ** ----" % current_wave)
	
	# Get the current wave size and immediately remove it from the array
	var enemies_to_spawn = wave_sizes[0]
	wave_sizes.remove_at(0)
	
	print("Enemies to spawn %d" % enemies_to_spawn)
	print("Remaining waves after this: ", wave_sizes)
	
	# Store this wave's enemy count for spawning
	current_wave_enemies_spawned = 0
	current_wave_enemy_target = enemies_to_spawn
	wave_state = WaveState.SPAWNING_ENEMIES
	
	print("spawning next enemy")
	spawn_next_enemy()

	
	
func spawn_next_enemy():
	if current_wave_enemies_spawned < current_wave_enemy_target:
		# Init the enemy
		var enemy = preload("res://scenes/Enemy.tscn").instantiate()
		enemy.progress = 0
		
		# add enemy to the 2D path
		$Path2D.add_child(enemy)
		
		current_wave_enemies_spawned += 1
		
		if current_wave_enemies_spawned < current_wave_enemy_target:
			# schedule the next enemy
			wave_timer.wait_time = time_between_enemies
			wave_timer.start()
		else:
			complete_current_wave()

func complete_current_wave():
	print("--- *** wave %d complete *** ---" % current_wave)
	print("Remaining waves: ", wave_sizes)
	
	wave_state = WaveState.WAVE_COMPLETE
	
	if wave_sizes.size() > 0:
		print("Next wave is in %.1f seconds..." % time_between_waves)
		wave_timer.wait_time = time_between_waves
		wave_timer.start()
	else:
		print("ALL WAVES COMPLETE WOOOO")
		wave_state = WaveState.ALL_WAVES_COMPLETE
		wave_timer.stop()


		remove_child(wave_timer)
		wave_timer.queue_free()
		

func start_next_wave():
	print("C")
	print("starting the next wave")
	current_wave += 1
	
	print(wave_sizes)
	
	wave_state = WaveState.WAITING_TO_START
	start_current_wave()

func _on_texture_button_toggled(toggled_on: bool) -> void:
	is_placing_node = toggled_on
	print("Node placement mode:", is_placing_node)

func _unhandled_input(event):
	if is_placing_node and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_pos = get_global_mouse_position()
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
