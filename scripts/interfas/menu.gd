extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_option_pressed() -> void:
	get_tree().change_scene_to_file("res://opciones.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
