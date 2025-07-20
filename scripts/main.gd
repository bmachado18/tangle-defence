extends Node2D



var playerHealth = 10
var playerMoney = 100

var ropeCost = 5
var towerCost = 10

var enemyRefund = 5


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
var wave_sizes = [1, 3, 5, 7, 15]
var current_wave_enemies_spawned = 0
var current_wave_enemy_target = 0

# Timing configuration
var time_between_enemies = 0.5
var time_between_waves = 3.0
var time_before_first_wave = 2.0
var active_enemies := 0

var wave_timer: Timer

var grid_size = 32

var is_placing_node := false


func _ready():
	$Music.play()
	
	setup_node_connections()
	setup_wave_system()
	Global.score = 0 
	
	$Panel/HealthLabel.text = str(playerHealth)
	$Panel/MoneyLabel.text = str(playerMoney)
	
	$Panel/TowerPriceLabel.text = str(towerCost)
	$Panel/EdgePriceLabel.text = str(ropeCost)
	
	
func setup_node_connections():
	for node in $Nodes.get_children():
		node.get_child(0).connect("node_selected", Callable(self, "_on_node_selected"))

func setup_wave_system():
	# configure and create a single timer for all wave operations
	wave_timer = Timer.new()
	add_child(wave_timer)
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	wave_timer.one_shot = true
		
	wave_timer.wait_time = time_before_first_wave
	wave_timer.start()

func _on_node_selected(node):
	if not is_placing_node:
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
	if playerMoney < ropeCost:
		print("player does not have enough money to place rope")
		return
	
	
	$edgeCreateAudio.play()
	playerMoney -= ropeCost
	update_money_label()
	
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
	

func _on_wave_timer_timeout() -> void:	
	match wave_state:
		WaveState.WAITING_TO_START:
			start_current_wave()
		#
		WaveState.SPAWNING_ENEMIES:
			spawn_next_enemy()
		
		WaveState.WAVE_COMPLETE:
			start_next_wave()
		
		WaveState.ALL_WAVES_COMPLETE:
			#_go_to_next_round()
			return

func start_current_wave():
	$wavespawn.play()
	if wave_sizes.size() == 0:
		wave_state = WaveState.ALL_WAVES_COMPLETE
		return
			
	# Get the current wave size and immediately remove it from the array
	var enemies_to_spawn = wave_sizes[0]
	wave_sizes.remove_at(0)
	
	# Store this wave's enemy count for spawning
	current_wave_enemies_spawned = 0
	current_wave_enemy_target = enemies_to_spawn
	wave_state = WaveState.SPAWNING_ENEMIES
	
	spawn_next_enemy()

	
	
func spawn_next_enemy():
	if current_wave_enemies_spawned < current_wave_enemy_target:
		# Init the enemy
		
		var enemy = preload("res://scenes/Enemy.tscn").instantiate()
		enemy.progress = 0
		
		# add enemy to the 2D path
		$Path2D.add_child(enemy)
		
		active_enemies += 1
		
		enemy.enemy_despawn.connect(_on_enemy_despawn)
		enemy.edge_destroyed.connect(_on_edge_destroyed)
		enemy.enemy_death.connect(_on_enemy_death)


		
		current_wave_enemies_spawned += 1
		
		if current_wave_enemies_spawned < current_wave_enemy_target:
			# schedule the next enemy
			wave_timer.wait_time = time_between_enemies
			wave_timer.start()
		else:
			complete_current_wave()

func complete_current_wave():
	
	wave_state = WaveState.WAVE_COMPLETE
	
	if wave_sizes.size() > 0:
		#print("Next wave is in %.1f seconds..." % time_between_waves)
		wave_timer.wait_time = time_between_waves
		wave_timer.start()
	else:
		wave_state = WaveState.ALL_WAVES_COMPLETE
		wave_timer.stop()


		remove_child(wave_timer)
		wave_timer.queue_free()
		
		
		

func start_next_wave():
	current_wave += 1
	
	wave_state = WaveState.WAITING_TO_START
	start_current_wave()

func _on_texture_button_toggled(toggled_on: bool) -> void:
	is_placing_node = toggled_on
	$Grid.visible = is_placing_node
	print("Node placement mode:", is_placing_node)
	$Panel/TextureButton.button_pressed = is_placing_node

func _unhandled_input(event):
	if is_placing_node and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_pos = $Camera2D.get_global_mouse_position()
		get_viewport().set_input_as_handled()
		var grid_pos = Vector2(
			floor(click_pos.x / grid_size) * grid_size + grid_size / 2,
			floor(click_pos.y / grid_size) * grid_size + grid_size / 2
		)
		place_node(grid_pos)
		get_viewport().set_input_as_handled()
		
func place_node(pos: Vector2):
	if playerMoney < towerCost:
		print("player does not have enough money")
		return
	
	var new_node = preload("res://scenes/node.tscn").instantiate()
	new_node.position = pos
	
	playerMoney -= towerCost
	update_money_label()
	
	$Nodes.add_child(new_node)
	new_node.get_child(0).connect("node_selected", Callable(self, "_on_node_selected"))
	
	#reset the button
	is_placing_node = false

	$Panel/TextureButton.button_pressed = is_placing_node
	$Grid.visible = is_placing_node
	$Panel/TextureButton.button_pressed = false

func _on_enemy_despawn(enemy):
	playerHealth -= enemy.strength # decrease health based on the strength level on the enemy
	
	if playerHealth < 0:
		call_deferred("_go_to_game_over")
	
	update_health_label()

	enemy.queue_free()
	
	
	active_enemies -= 1
	check_if_round_complete()

func check_if_round_complete():
	if wave_state == WaveState.ALL_WAVES_COMPLETE and active_enemies <= 0:
		print("All enemies and waves complete — loading next round screen")
		call_deferred("_go_to_next_round")



func _go_to_game_over():
	
	get_tree().change_scene_to_file("res://scenes/menu_scenes/GameOver.tscn")
	
func _go_to_next_round():
	get_tree().change_scene_to_file("res://scenes/menu_scenes/player_win.tscn")
	
func update_health_label():
	$Panel/HealthLabel.text = str(playerHealth)

func update_money_label():
	$Panel/MoneyLabel.text = str(playerMoney)

func _on_enemy_death(enemy):
	print("Enemy killed by edge — refunding money")
	playerMoney += enemyRefund
	
	update_money_label()
	
	Global.score += 1
	active_enemies -= 1
	check_if_round_complete()

func _on_edge_destroyed(edge):
	if edge in edges:
		edges.erase(edge)
		var key = get_edge_key(edge.from_node, edge.to_node)
		edge_pairs.erase(key)
		edge_count -= 1
		print("Edge removed from lists:", key)
		
#func _on_edge_break():
#	pass
func _draw():
	# Get the visible area of the current node (usually the screen size)
	var rect = get_viewport().get_visible_rect()
	var view_size = rect.size
	
	# Draw vertical lines
	for x in range(0, int(view_size.x), grid_size):
		draw_line(Vector2(x, 0), Vector2(x, view_size.y), Color(0.2, 0.2, 0.2, 0.4))
	
	# Draw horizontal lines  
	for y in range(0, int(view_size.y), grid_size):
		draw_line(Vector2(0, y), Vector2(view_size.x, y), Color(0.2, 0.2, 0.2, 0.4))
