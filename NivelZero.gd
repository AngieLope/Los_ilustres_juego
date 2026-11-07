extends Node

@onready var muro_collision = $StaticBody2D/CollisionShape2D13 # Nodo del muro 
@onready var puerta_sprite = $Puerta # Nodo de la puerta 
@onready var puerta_area = $Puerta/Area2D  # Detector de paso del jugador en la puerta
@onready var puerta_collision = $Puerta/Area2D/Collision_puerta # Detector de colisión de la puerta 

func _ready():
	var stream = load("res://sonido/Nivel-1.ogg")
	$SonidoFondo.stream = stream
	$SonidoFondo.stream.loop = true  # Esto funciona solo si es AudioStreamOggVorbis
	$SonidoFondo.play()
	# Nodo del enemigo
	var enemigo = $Enemigo_banano 
	# Nodo del jugador
	var jugador = $Jacinto
	
	if enemigo:
		enemigo.connect("enemigo_muerto", Callable(self, "_on_enemigo_muerto"))
	
	# Conectar señal de la puerta para detectar cuando el jugador la cruza
	puerta_area.connect("body_entered", Callable(self, "_on_player_crossed_door"))		

func _on_enemigo_muerto():
	var muro = $Wall  # Nodo del muro
	muro.queue_free()  # Esto eliminará el muro
	
	if muro_collision:
		muro_collision.disabled = true  # Desactiva la colisión del muro
		
	if puerta_sprite:
		$Puerta.play("Abierta")  # Animación de puerta abierta
		
func _on_player_crossed_door(body):
	if body.name == "Jacinto":  
		print("El jugador ha cruzado la puerta, cerrándola...")
		
		if puerta_sprite:
			$Puerta.play("Cerrada")
		
		# Esperar un segundo antes de cambiar de escena, sin pausar el árbol
		await get_tree().create_timer(3.0)
		
		# Cambiar al menú del juego
		get_tree().change_scene_to_file("res://transicion_memoria.tscn")

		
		
