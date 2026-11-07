extends CharacterBody2D

@export var bullet: PackedScene

var velocidad: int = 50
func _ready():
	$AnimatedSprite2D.play("caminar")
	velocity.x = -velocidad
	
func _process(delta):
	pass

func _physics_process(delta):
	if is_on_wall():
		if !$AnimatedSprite2D.flip_h: #esta mirando a la izquierda
			velocity.x = -velocidad
		else: #esta mirando a la derecha
			velocity.x = velocidad
	
	
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	
	move_and_slide()
func dead():
	set_physics_process(false)
	$AnimatedSprite2D.play("dead")	
	await ($AnimatedSprite2D.animation_finished)
	queue_free()
	
func _on_body_entered(body):
	if body.is_in_group("Jacinto"):
		body.hit()



