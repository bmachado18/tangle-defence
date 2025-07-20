extends Control



func _on_button_play_pressed() -> void:
	$button_click.play()
	get_tree().change_scene_to_file("res://scenes/game.tscn")



func _on_button_quit_pressed() -> void:
	$button_click.play()
	get_tree().quit()




func _on_button_info_pressed() -> void:
	$button_click.play()
	get_tree().change_scene_to_file("res://scenes/menu_scenes/info_scene.tscn")
