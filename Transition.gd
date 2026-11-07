extends Control

@onready var negro = $ColorRect

func _ready():
	negro.modulate.a = 0.0
	hide()

func fade_out(tiempo=1.0) -> void:
	show()
	var tween = create_tween()
	tween.tween_property(negro, "modulate:a", 1.0, tiempo)
	await tween.finished

func fade_in(tiempo=1.0) -> void:
	var tween = create_tween()
	tween.tween_property(negro, "modulate:a", 0.0, tiempo)
	await tween.finished
	hide()

func cambiar_escena_con_fade(ruta_escena: String, duracion_fade=1.0) -> void:
	await fade_out(duracion_fade)
	get_tree().change_scene_to_file(ruta_escena)
	await fade_in(duracion_fade)
