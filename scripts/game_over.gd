extends Control


func _ready():
	$Score.text = "Score: " + str(Global.score)

func _on_button_try_again_pressed() -> void:
	$button_click.play()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	

func _on_button_main_menu_pressed() -> void:
	$button_click.play()
	get_tree().change_scene_to_file("res://scenes/menu_scenes/UI.tscn")
