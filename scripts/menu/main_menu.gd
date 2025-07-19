extends Control



func _on_button_play_pressed() -> void:
	$button_click.play()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_button_options_pressed() -> void:
	$button_click.play()
	pass # Replace with function body.


func _on_button_quit_pressed() -> void:
	$button_click.play()
	get_tree().quit()
