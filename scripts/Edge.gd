extends Node2D

var from_node
var to_node
var cross_count = 0
var strength = 0
var health = 0

@onready var strength_label = $StrengthLabel
@onready var health_label = $HealthLabel

func _ready():
	add_to_group("Edges")
	
func initialize(node_a, node_b):
	from_node = node_a
	to_node = node_b
	
	$edge_create.play()
	
	update_position()
	update_strength()

func update_position():
	# Update the visual representation of the edge (line drawing)
	# This depends on how you're currently drawing your edges
	queue_redraw()
	
	# Position labels around midpoint
	var midpoint = (from_node.global_position + to_node.global_position) / 2
	if strength_label:
		strength_label.global_position = midpoint + Vector2(0, -10)
	if health_label:
		health_label.global_position = midpoint + Vector2(0, 10)

func update_strength():
	strength = max(1, 10 - cross_count * 3)
	if health == 0:
		health = strength

	update_labels()
			

func update_labels():
	if strength_label:
		strength_label.text = "S: %d" % strength
	if health_label:
		health_label.text = "H: %d" % health

		# Optional color coding
		if health >= 7:
			health_label.modulate = Color.GREEN
		elif health >= 4:
			health_label.modulate = Color.YELLOW
		else:
			health_label.modulate = Color.RED



func _draw():
	if from_node and to_node:
		var color = Color.WHITE
		# Optional: Change line color based on strength
		if strength >= 7:
			color = Color.GREEN
		elif strength >= 4:
			color = Color.YELLOW
		else:
			color = Color.RED
			
		draw_line(
			to_local(from_node.global_position), 
			to_local(to_node.global_position), 
			color, 
			2.0
		)
