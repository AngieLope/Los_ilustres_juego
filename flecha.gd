extends Area2D

var direccion = Vector2.RIGHT
var velocidad = 400

func _process(delta):
	position += direccion * velocidad * delta

func _on_body_entered(body):
	if body.is_in_group("Jacinto"):
		body.recibir_danio(10)
		queue_free()

	if body.is_in_group("pared"):
		queue_free()
