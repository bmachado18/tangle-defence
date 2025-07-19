extends Node2D

var from_node
var to_node
var cross_count = 0
var strength = 0

@onready var strength_label = $StrengthLabel  # Reference to the Label node

func initialize(node_a, node_b):
	from_node = node_a
	to_node = node_b
	update_position()
	update_strength()

func update_position():
	# Update the visual representation of the edge (line drawing)
	# This depends on how you're currently drawing your edges
	queue_redraw()
	
	# Position the label at the midpoint of the edge
	if strength_label:
		var midpoint = (from_node.global_position + to_node.global_position) / 2
		strength_label.global_position = midpoint - strength_label.size / 2

func update_strength():
	# Calculate strength based on cross_count (adjust formula as needed)
	strength = max(1, 10 - cross_count*3)  # Example: strength decreases with crossings
	
	# Update the label text
	if strength_label:
		strength_label.text = str(strength)
		
		# Optional: Color code the strength
		if strength >= 7:
			strength_label.modulate = Color.GREEN
		elif strength >= 4:
			strength_label.modulate = Color.YELLOW
		else:
			strength_label.modulate = Color.RED

func _draw():
	# Your existing edge drawing code here
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
