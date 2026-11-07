extends Control

@onready var titulo = $Titulo
@onready var subtitulo = $Subtitulo
@onready var tumba = $TumbaSprite
@onready var texto_final = $TextoFinal



func _ready():

	# Ocultar todo
	titulo.visible = false
	subtitulo.visible = false
	texto_final.visible = false

	# -------------------------
	# 1. APARECE LA TUMBA
	# -------------------------
	tumba.visible = true
	tumba.modulate.a = 0.0

	var tween = create_tween()

	tween.tween_property(
		tumba,
		"modulate:a",
		1.0,
		2.0
	)

	await tween.finished


	# -------------------------
	# 2. MEMORIA RECUPERADA
	# -------------------------
	titulo.visible = true
	subtitulo.visible = true

	await get_tree().create_timer(3.0).timeout


	# -------------------------
	# 3. SIGUIENTE MEMORIA
	# -------------------------
	texto_final.visible = true
	texto_final.text = "Siguiente memoria desbloqueada:\n1948 — El Bogotazo"

	await get_tree().create_timer(4.0).timeout


	# Cambiar escena
	get_tree().change_scene_to_file("res://menu.tscn")
