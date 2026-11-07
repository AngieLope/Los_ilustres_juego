extends Area2D

var direccion = Vector2.RIGHT
var velocidad = 200

func _process(delta):

	position += direccion * velocidad * delta

func _on_body_entered(body):

	if body.is_in_group("player"):
		body.die()
		queue_free()

	if body is StaticBody2D:
		queue_free()
