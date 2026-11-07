extends CharacterBody2D

@onready var health_barra = $anim/TextureProgressBar
var health : int  = 3
var velocidad : int = 275
var salto : int = 670
var gravedad : int = 850
var is_die = false
var hitplayer = false
var cont_jump:int = 0
var max_jump:int = 2

	
# La colisión esté siempre desactivada al iniciar
func _ready():
	$sword/sword_collider.disabled = true  # Desactiva colisión de la espada por defecto
	
# Procesa la física del jugador
func _physics_process(delta):
	velocity.y += gravedad * delta
	
	if !hitplayer:  # Solo procesar movimiento si el jugador no ha sido golpeado
		if Input.is_action_pressed("Derecha"):
			$sword.position.x = 30
			velocity.x = velocidad
			$anim.flip_h = false
		elif Input.is_action_pressed("Izquierda"):
			$sword.position.x = -100
			velocity.x = -velocidad
			$anim.flip_h = true
		else: 
			velocity.x = 0

		# Salto
		if is_on_floor():
			cont_jump = 0
			if Input.is_action_just_pressed("Saltar"):
				$jump.play()
				cont_jump += 1
				velocity.y = -salto	
		else:
			if Input.is_action_just_pressed("Saltar") and max_jump > cont_jump:
				$jump.play()
				cont_jump += 1
				velocity.y = -salto
			if Input.is_action_just_released("Saltar"):
				velocity.y += 5000 * delta

		animaciones()
	move_and_slide()

# Procesar entrada de ataque
func _input(event):
	if Input.is_action_just_pressed("atacar") and !hitplayer:
		$atack.play()
		set_physics_process(false)  # Detener la física durante el ataque
		$anim.play("Sword")
		$sword/sword_collider.disabled = false  # Activar colisión de la espada
		await $anim.animation_finished
		$sword/sword_collider.disabled = true  # Desactivar colisión de la espada
		set_physics_process(true)  # Reanudar la física después del ataque

# Controlar las animaciones del jugador
func animaciones():
	if is_on_floor():
		if velocity.x != 0:
			$anim.play("Walk")
		else:
			$anim.play("Idle")
	else:
		if velocity.y < 0:
			$anim.play("Jump")
		else:
			$anim.play("Fall")

# Golpe recibido por el jugador
func hit():
	hitplayer = true
	velocity = Vector2.ZERO  # Detener al jugador al ser golpeado
	if !$anim.flip_h:
		velocity = Vector2(-100, -200)
	else:
		velocity = Vector2(100, -200)
		
	$anim.play("hit")
	await $anim.animation_finished
	velocity = Vector2.ZERO
	hitplayer = false  # Permitir que el jugador se recupere

# Manejo de la muerte del jugador
func die():
	if not is_die:
		health -= 1  # Reducir la salud
		print("Salud restante: ", health)
		health_barra.value = health  # Actualizar la barra de salud

		if health > 0:
			set_physics_process(false)  # Detener el procesamiento físico del jugador
			$daño_jacinto.play()
			$anim.play("Daño")
			await $anim.animation_finished
			set_physics_process(true)  # Detener el procesamiento físico del jugador
			
		elif health <= 0:
			health_barra.value = health  # Asegurarse de que la barra muestre la salud correcta
			print("El jugador ha muerto.")
			is_die = true
			set_physics_process(false)  # Detener el procesamiento físico del jugador
			$anim.play("Die")  # Reproducir animación de muerte
			await $anim.animation_finished
			await get_tree().create_timer(1.0).timeout  # Esperar 1 segundo antes de reiniciar la escena
			get_tree().reload_current_scene()

# Cuando la espada toca un enemigo
func _on_sword_body_entered(body):
	if body.is_in_group("enemie"):
		body.dead()  # Llamar a la función de muerte del enemigo

# Cuando el jugador toca un enemigo
func _on_body_entered(body):
	if body.is_in_group("enemie") and not is_die:
		die()  # El jugador recibe daño y puede morir


