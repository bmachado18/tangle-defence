extends PathFollow2D

signal edge_collision
signal edge_death

var base_speed := 0.1
var current_speed := base_speed
var health = 5
var strength = 2

var attack_cooldown := 0.5
var time_since_last_attack := 0.0

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_since_last_attack += delta
	progress_ratio += delta * current_speed

	var touched := false
	for edge in get_tree().get_nodes_in_group("Edges"):
		if edge.health > 0 and is_touching_edge(edge):
			touched = true
			
			if time_since_last_attack >= attack_cooldown:
				apply_combat(edge)
				time_since_last_attack = 0.0
				break  # Optional: one edge per tick

	current_speed = 0 if touched else base_speed

func is_touching_edge(edge) -> bool:
	var a = edge.from_node.global_position
	var b = edge.to_node.global_position
	var pos = global_position

	var closest_point = Geometry2D.get_closest_point_to_segment(pos, a, b)
	var dist = pos.distance_to(closest_point)
	return dist < 10  # adjust threshold as needed
	
func apply_combat(edge):
	print("Combat triggered: enemy health =", health, ", edge health =", edge.health)
	$player_damage.play()
	var player_dmg = $player_damage
	player_dmg.stream = preload("res://assets/audio/hurt.wav")
	player_dmg.play()
	
	edge.health -= strength
	health -= edge.strength

	edge.update_labels()
	print("after combat: enemy health =", health, ", edge health =", edge.health)

	if edge.health <= 0:
		print("Edge destroyed")
		
		edge.queue_free()
		
		if is_instance_valid(edge):
			edge.queue_redraw()

	if health <= 0:
		print("Enemy destroyed")
		
		call_deferred("queue_free")


func _on_edge_collision() -> void:
	$edge_remove.play()
	print("Edge collision audio should be triggered")
	
	


func _on_edge_death() -> void:
	pass # Replace with function body.
