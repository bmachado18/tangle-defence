extends Control


func _on_button_main_menu_pressed() -> void:
	$button_click.play()
	get_tree().change_scene_to_file("res://scenes/menu_scenes/UI.tscn")


func _on_button_next_round_pressed() -> void:
	$button_click.play()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
