extends Control

func _ready():
	get_tree().paused = false

# boton jugar cambia a la escena intro
func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://intro.tscn")

# lógica para iniciar el juego por tecla o boton:
func _input(event):
	if event.is_action_pressed("start_game"):
		# lógica para iniciar el juego:
		get_tree().change_scene_to_file("res://intro.tscn")
