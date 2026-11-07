extends CharacterBody2D

@export var bullet: PackedScene
@onready var vida_barra =$TextureProgress  # Asegúrate de que esta ruta sea correcta
var velocidad: int = 50
var salud: int = 3  # Salud inicial del enemigo
# Enumeración para los estados
enum State { IDLE, WALKING, ATTACKING, DEAD }
var current_state = State.WALKING  # El enemigo comienza caminando
# Variable para controlar si el enemigo ha sido golpeado
var is_dead = false
var can_be_hit = true  # Variable para controlar si el enemigo puede recibir un golpe
signal enemigo_muerto #Señal del enemigo muerto


func _ready():
		$Hurbox/Hurbox_collider.disabled = true
		$golper_timer.stop()
		$AnimatedSprite2D.play("caminar")
		velocity.x = -velocidad
		
func _physics_process(_delta: float):
		match current_state:
			State.WALKING:
				caminar()
			State.ATTACKING:
				atacar()
			State.DEAD:
				dead()  # No hacer nada si está muerto

		# Solo moverse si el estado actual es "WALKING"
		if current_state == State.WALKING:
			move_and_slide()

	# Función para la lógica de caminar
func caminar():
		if not is_dead:
			if $detect_izq.is_colliding():
				$ataque.play()
				$AnimatedSprite2D.flip_h = true
				set_physics_process(false)
				$AnimatedSprite2D.play("ataque")  # Iniciar ataque izquierdo
				disparar()
				$Hurbox/Hurbox_collider.disabled = false
				await $AnimatedSprite2D.animation_finished
				$Hurbox/Hurbox_collider.disabled = true
				set_physics_process(true)
				$AnimatedSprite2D.play("caminar")
								
			elif $detect_der.is_colliding():
				$ataque.play()
				$AnimatedSprite2D.flip_h = false
				set_physics_process(false)
				$AnimatedSprite2D.play("ataque")  # Iniciar ataque derecho.
				disparar()
				$Hurbox/Hurbox_collider.disabled = false
				$Hurbox.scale.x *= -1
				await $AnimatedSprite2D.animation_finished
				$Hurbox/Hurbox_collider.disabled = true
				set_physics_process(true)
				$AnimatedSprite2D.play("caminar")
		# Cambiar la dirección al chocar con una pared
		if is_on_wall():
			if !$AnimatedSprite2D.flip_h:  # Mirando a la izquierda
				velocity.x = -velocidad
			else:  # Mirando a la derecha
				velocity.x = velocidad

		# Controlar el giro de la animación según la dirección
		if velocity.x < 0:
			$AnimatedSprite2D.flip_h = true
		elif velocity.x > 0:
			$AnimatedSprite2D.flip_h = false
			
# disparar flecha
func disparar():

	if bullet == null:
		return

	var flecha = bullet.instantiate()

	get_parent().add_child(flecha)

	# Posición de salida
	if has_node("DisparoPos"):
		flecha.global_position = $DisparoPos.global_position

	else:
		flecha.global_position = global_position

	# Dirección + flip
	if $AnimatedSprite2D.flip_h:

		flecha.direccion = Vector2.LEFT

		flecha.scale.x = -1

	else:

		flecha.direccion = Vector2.RIGHT

		flecha.scale.x = 1

	# Función para iniciar el ataque
func iniciar_ataque(ataque: String):
		
		current_state = State.ATTACKING
		$AnimatedSprite2D.play()  # Reproduce la animación de ataque

	# Función para la lógica de ataque
func atacar():
		# Esperar a que termine la animación de ataque
		if $AnimatedSprite2D.animation_finished:
			# Volver al estado de caminar si no está muerto
			if not is_dead:
				current_state = State.WALKING
				$AnimatedSprite2D.play("caminar")

	# Función para la lógica de muerte
func dead():
		# Solo reducir salud y reproducir animación de recibir golpe si el enemigo no está muerto
		if not is_dead:
			salud -= 1  # Reducir salud
			print("Salud restante enemigo: ", salud)  # Mostrar salud restante

			# Actualizar la barra de vida
			vida_barra.value = salud  # Actualizar el valor de la barra

			# Si la salud es mayor que 0, reproducir animación de recibir golpe
			if salud > 0:
				$daño.play()
				$AnimatedSprite2D.play("recibir_golpe")
				await $AnimatedSprite2D.animation_finished
				$AnimatedSprite2D.play("caminar")
			# Si la salud es menor o igual a 0, ejecutar lógica de muerte
			elif salud <= 0:
				vida_barra.value = salud  # Actualizar el valor de la barra
				print("El enemigo ha muerto.")  # Mensaje de depuración
				is_dead = true  # Marcar al enemigo como muerto
				set_physics_process(false)  # Detener el procesamiento físico del enemigo
				$muerte.play()  # Sonido de muerte 
				$AnimatedSprite2D.play("dead")  # Reproducir animación de muerte
				await $AnimatedSprite2D.animation_finished
				emit_signal("enemigo_muerto")
				queue_free()  # Eliminar el enemigo del juego después de la animación
				

# Función para cuando el enemigo recibe un golpe
func _on_body_entered(body):
		if body.is_in_group("player") and not is_dead:  # Solo si el enemigo no está muerto
			body.hit()  # Golpear al jugador
# Función para que el enemigo pueda recibir un nuevo un golpe			
func _on_golper_timer_timeout():
		can_be_hit = true  # El enemigo puede ser golpeado nuevamente

func _on_hurbox_body_entered(body):
	if body.is_in_group("player"):
		body.die()

