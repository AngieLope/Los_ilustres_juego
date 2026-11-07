extends Control

# Lista de frases del diálogo, ordenadas por turno
var dialogo_conversacion = [
	"¿Dónde estoy? Este lugar se siente impregnado de dolor.",
	"Alto ahí",
	"¿Quién eres y qué haces aquí, entre los ecos de los olvidados?",
	"No lo sé del todo solo sé que este sitio me llama. Algo aquí duele.",
	"Has pisado tierra sagrada y maldita. Aquí yacen los que desafiaron el orden.",
	"No yacen. Se retuercen en la memoria. Claman justicia.",
	"¿Justicia? Fueron traidores. Desataron el caos y exigieron lo que nunca les fue dado.",
	"Querían vivir con dignidad. ¿Eso es traición?",
	"Desobedecer es romper el equilibrio. Nosotros cumplimos órdenes. Tú no lo entenderías.",
	"Sí lo entiendo. Cumplir órdenes no justifica la sangre que se derramó.",
	"Entonces ¿has venido a juzgarnos?",
	"He venido a recordar. Y a enfrentar lo que tantos prefirieron dejar en el olvido.",
	"¡Suerte con eso!"
]
# Lista paralela que indica quién dice cada frase ("personaje" o "enemigo")
var hablante_conversacion = [
	"personaje",
	"enemigo",
	"enemigo",
	"personaje",
	"enemigo",
	"personaje",
	"enemigo",
	"personaje",
	"enemigo",
	"personaje",
	"enemigo",
	"personaje",
	"enemigo"
]

var indice_dialogo = 0 # Índice actual del diálogo
var velocidad_texto = 0.09 # Velocidad con la que se muestran las letras del texto (delay entre caracteres)
var escribiendo = false
var cayendo = true
var caminando = false
var caminando_post_dialogo = false
var humo_activado = false
var altura_suelo = 560.0
var velocidad_caida = 300.0
var x_maximo_camara = 2700.0
var dialogo_activado = false

@onready var personaje = $Personaje
@onready var enemigo = $Enemigo
@onready var camera2d = $Personaje/Camera2D
@onready var animation_player = $Personaje/AnimationPlayer
@onready var fondo = $Sprite2D/AnimatedSprite2D
@onready var humo = $Humo/AnimatedSprite2D
@onready var mensaje = $TextureRect2/mensaje
@onready var mensaje_enemigo = $Enemigo/TextureRect3/mensaje1
@onready var texture_rect_personaje = $TextureRect2
@onready var texture_rect_enemigo = $Enemigo/TextureRect3
@onready var flecha_anim = $TextureRect2/flecha/AnimatedSprite2D
@onready var flecha_rect = $TextureRect2/flecha/AnimatedSprite2D
@onready var puerta = $Puerta/AnimatedPuerta

func _ready():
	var stream = load("res://sonido/viento.mp3")
	$Sonido.stream = stream
	$Sonido.stream.loop = true  # Esto funciona solo si es AudioStreamOggVorbis
	$Sonido.play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # El mouse es visible
	camera2d.make_current() # La cámara del personaje se activa
	
	# Oculta los elementos que no deben verse al inicio
	texture_rect_personaje.visible = false
	texture_rect_enemigo.visible = false
	flecha_rect.visible = false
	humo.visible = false
	puerta.visible = false
	
	# Posición inicial del personaje (empieza cayendo desde arriba)
	personaje.position.y = -300 
	animation_player.play("cae") # Animación de caída

func _physics_process(delta):
	if cayendo:
		# Movimiento vertical hacia abajo
		personaje.position.y += velocidad_caida * delta
		if personaje.position.y >= altura_suelo:
			personaje.position.y = altura_suelo
			cayendo = false
			animation_player.play("caer")
			$Caida.play()
			# Efecto de humo al aterrizar
			if not humo_activado:
				humo.visible = true
				humo.play("humo")
				humo_activado = true

			await get_tree().create_timer(1.0).timeout
			humo.visible = false
			animation_player.play("camina")
			start_walking()
			
	# Movimiento horizontal constante
	elif caminando and not dialogo_activado and not caminando_post_dialogo:
		var velocidad = 115.0
		personaje.position.x += velocidad * delta
		
		# Fondo animado
		if fondo.animation != "camina":
			fondo.play("camina")
			
		# Acompaña el mensaje del personaje al moverse
		texture_rect_personaje.position.x = personaje.position.x

		# Activar diálogo si se acerca al enemigo
		if personaje.position.distance_to(enemigo.position) <= 19.0:
			dialogo_activado = true
			iniciar_dialogo_conversacion()

	elif caminando_post_dialogo:
		var velocidad = 120.0
		personaje.position.x += velocidad * delta

		if fondo.animation != "camina":
			fondo.play("camina")

		texture_rect_personaje.position.x = personaje.position.x

		# Detener cuando llega o pasa la posición límite
		if animation_player.position.x >= x_maximo_camara:
			animation_player.position.x = x_maximo_camara
			caminando_post_dialogo = false
			detener_personaje()

func start_walking():
	# Activa movimiento inicial
	caminando = true
	texture_rect_personaje.visible = true
	flecha_rect.visible = false
	mostrar_siguiente_dialogo()

func detener_personaje():
	# Detiene al personaje
	caminando = false
	caminando_post_dialogo = false
	animation_player.play("idle")
	texture_rect_personaje.visible = false
	flecha_rect.visible = false
	# Reinicia cámara
	var global_cam_pos = camera2d.global_position
	remove_child(camera2d)
	add_child(camera2d)
	camera2d.global_position = global_cam_pos
	camera2d.enabled = true

func iniciar_dialogo_conversacion():
	dialogo_activado = true
	mostrar_siguiente_dialogo()

func mostrar_siguiente_dialogo():
	# Recorre todos los diálogos
	while indice_dialogo < dialogo_conversacion.size():
		var texto = dialogo_conversacion[indice_dialogo]
		var hablante = hablante_conversacion[indice_dialogo]
		indice_dialogo += 1
		# Mostrar texto de acuerdo al hablante
		if hablante == "personaje":
			texture_rect_personaje.visible = true
			texture_rect_enemigo.visible = false
			await escribir_texto_personaje(texto)
		elif hablante == "enemigo":
			texture_rect_personaje.visible = false
			texture_rect_enemigo.visible = true
			await escribir_texto_enemigo(texto)
		else:
			texture_rect_personaje.visible = true
			texture_rect_enemigo.visible = false
			await escribir_texto_personaje(texto)
			
		# Pausas especiales después del primer mensaje
		if indice_dialogo == 1:
			await get_tree().create_timer(2.0).timeout
			texture_rect_personaje.visible = false
			texture_rect_enemigo.visible = false
			await get_tree().create_timer(1.0).timeout
			detener_personaje()
		else:
			await get_tree().create_timer(2.5).timeout

	finalizar_dialogo()

func escribir_texto_personaje(texto: String) -> void:
	$Texto.play()
	escribiendo = true
	mensaje.text = texto
	mensaje.visible_characters = 0
	for i in range(texto.length()):
		mensaje.visible_characters = i + 1
		await get_tree().create_timer(velocidad_texto).timeout
	escribiendo = false

func escribir_texto_enemigo(texto: String) -> void:
	$Texto.play()
	escribiendo = true
	mensaje_enemigo.text = texto
	mensaje_enemigo.visible_characters = 0
	for i in range(texto.length()):
		mensaje_enemigo.visible_characters = i + 1
		await get_tree().create_timer(velocidad_texto).timeout
	escribiendo = false

func continuar_caminata():
	caminando_post_dialogo = true
	caminando = false
	animation_player.play("camina")
	fondo.play("camina")

func finalizar_dialogo():
	puerta.visible = true
	texture_rect_personaje.visible = false
	texture_rect_enemigo.visible = false
	enemigo.visible = false
	dialogo_activado = false
	continuar_caminata()
	# Transición al nuevo nivel
	await get_tree().create_timer(9.5).timeout
	animation_player.play("salta")
	await animation_player.animation_finished
	personaje.visible = false
	puerta.visible = false
	get_tree().change_scene_to_file("res://Nivel Zero.tscn")
