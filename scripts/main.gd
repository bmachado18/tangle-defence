extends Node2D
var selected_node = null
var edges = []


var current_wave = 1
var wave_sizes = [1,2,3,4]
var number_of_waves = len(wave_sizes) 	# number of waves


var enemy_batch = [] 		# array of enemies that we will be using
var enemy_count = 0
var enemy_max = 12

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

func _on_edge_break():
	print("signal recieved")
	pass

func do_edges_cross(e1, e2):
	var a1 = e1.from_node.global_position
	var b1 = e2.from_node.global_position
	var a2 = e1.to_node.global_position
	var b2 = e2.to_node.global_position
	return Geometry2D.segment_intersects_segment(a1, a2, b1, b2)
	
func start_wave():
	var enemy = preload("res://scenes/Enemy.tscn").instantiate()
	
	 
	
	$Path2D.add_child(enemy)


func prepare_wave_batch():
	# Clear any existing batch
	enemy_batch.clear()
	
	# Create individual enemy instances
	for i in range(enemy_max):
		var enemy = preload("res://scenes/Enemy.tscn").instantiate()
		enemy_batch.append(enemy)
	
	print("Prepared batch of %d enemies" % enemy_batch.size())
		
func prepare_enemy_batch(enemy):
	$Path2D.add_child(enemy)
	print("spawned enemy %s" % enemy_count)
	enemy_count += 1
	
func spawn_enemy_batch():
	# Spawn all enemies from the batch
	for enemy in enemy_batch:
		if enemy != null:
			# Set initial progress
			enemy.progress = 0
			# Add to Path2D
			$Path2D.add_child(enemy)
			enemy_count += 1
			print("Spawned enemy #%d" % enemy_count)
	
	# Clear the batch after spawning
	enemy_batch.clear()

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




# creates a batch of enemies after timer amount of seconds
# autostart is enabled
func _on_enemy_batch_creation_timer_timeout() -> void:
	# Stop the timer since it should only run once per wave
	$EnemyBatchCreationTimer.stop()
	
	# Clear any existing batch
	enemy_batch.clear()
	
	# Populate current batch of enemies
	for i in range(0, wave_sizes[current_wave - 1]):
		var enemy = preload("res://scenes/Enemy.tscn").instantiate()
		enemy_batch.append(enemy)
		
	print("Prepared %d enemies for wave %d" % [enemy_batch.size(), current_wave])
	
	# Start the spawning timer (make sure it's set to repeat in the editor)
	$EnemySpawnTimer.start()



func _on_enemy_spawn_timer_timeout() -> void:
	# Check if there are enemies left to spawn in the current batch
	if enemy_batch.size() > 0:
		# Spawn the next enemy from the batch
		var enemy = enemy_batch.pop_front()  # Remove first enemy from batch
		
		if enemy != null:
			# Set initial progress
			enemy.progress = 0
			# Add to Path2D
			$Path2D.add_child(enemy)
			print("Spawned enemy from batch, %d remaining" % enemy_batch.size())
		
		# If there are more enemies in the batch, keep the timer running
		if enemy_batch.size() > 0:
			# Timer will automatically repeat since it should be set to repeat
			pass
		else:
			# No more enemies in this batch, stop the spawn timer
			$EnemySpawnTimer.stop()
			print("Finished spawning wave %d" % current_wave)
			
			# Check if we need to prepare the next wave
			if current_wave < number_of_waves:
				current_wave += 1
				print("Wave %d completed. Next wave in %d seconds..." % [current_wave - 1, $WaveDelayTimer.wait_time])
				# Start the delay timer before the next wave
				$WaveDelayTimer.start()
			else:
				print("All waves completed!")
	else:
		# No enemies in batch, stop the timer
		$EnemySpawnTimer.stop()
		print("No enemies in batch to spawn")
	


func _on_wave_delay_timer_timeout() -> void:
	$WaveDelayTimer.stop()
	print("Starting wave %d" % current_wave)
	# After delay, start preparing the next batch
	$EnemyBatchCreationTimer.start()
