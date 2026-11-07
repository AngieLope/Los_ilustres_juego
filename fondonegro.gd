extends Control

@onready var pantalla_negra = $FondoNegro
@onready var voz_off = $VozOff
@onready var label_texto = $LabelTexto

var texto_a_mostrar = "Hubo un tiempo en que estas tierras olían a banano y sangre.\n\
Miles de manos trabajaron bajo el sol, para una empresa que no\n\
conocía el descanso ni la compasión.\n\
Un día, pidieron justicia. Respondieron con fuego.\n\
Aún sus gritos resuenan entre estas paredes oscuras…\n\
Pero nadie quiso escucharlos.\n\
Hasta hoy."

func _ready():
	# Pantalla negra empieza visible y opaca
	pantalla_negra.modulate.a = 1.0
	label_texto.text = ""

	# Reproducir audio y mostrar texto al mismo tiempo
	voz_off.play()
	$Texto.play()
	await mostrar_texto_mientras_suena()
	await voz_off.finished

	

func mostrar_texto_mientras_suena() -> void:
	var duracion_audio = voz_off.stream.get_length()
	var total_letras = texto_a_mostrar.length()
	var tiempo_por_letra = duracion_audio / total_letras
	
	for i in range(total_letras):
		label_texto.text += texto_a_mostrar[i]
		await get_tree().create_timer(tiempo_por_letra).timeout

	await Transition.cambiar_escena_con_fade("res://Nivel Zero.tscn", 1.5)
