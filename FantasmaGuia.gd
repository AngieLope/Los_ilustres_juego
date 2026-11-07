extends Node2D

@export_multiline var dialogo = ""
@export var nombre_personaje = "Fantasma"
@export var tiempo_aparicion = 2.0
@export var tipo_control = ""

var activado = false

@onready var sprite = $AnimatedSprite2D
@onready var collision = $Area2D/CollisionShape2D

@onready var dialog_box = get_tree().current_scene.get_node("UI/DialogBox")
@onready var dialog_label = get_tree().current_scene.get_node("UI/DialogBox/DialogLabel")
@onready var name_label = get_tree().current_scene.get_node("UI/DialogBox/NameLabel")
@onready var control_label = get_tree().current_scene.get_node("UI/DialogBox/ControlLabel")


func _ready():
	sprite.modulate.a = 0
	collision.disabled = true

	await get_tree().create_timer(tiempo_aparicion).timeout

	var tween_in = create_tween()
	tween_in.tween_property(sprite, "modulate:a", 1.0, 1.0)

	await tween_in.finished

	collision.disabled = false


func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and !activado:
		activado = true

		dialog_label.text = ""
		control_label.text = ""

		# Mover cuadro al fantasma actual
		dialog_box.global_position = global_position + Vector2(-180, -250)

		dialog_box.visible = true
		name_label.text = nombre_personaje
		dialog_label.text = dialogo

		control_label.visible = true

		if tipo_control == "mover":
			control_label.text = ""

		elif tipo_control == "saltar":
			control_label.text = ""

		elif tipo_control == "atacar":
			control_label.text = ""

		await get_tree().create_timer(3.0).timeout

		# Ocultar diálogo
		dialog_box.visible = false
		dialog_label.text = ""
		control_label.text = ""

		# Desaparecer fantasma
		var tween_out = create_tween()

		tween_out.parallel().tween_property(
	sprite,
	"modulate:a",
	0.0,
	1.0
)

		tween_out.parallel().tween_property(
	self,
	"position:y",
	position.y - 20,
	1.0
)

		await tween_out.finished

		collision.disabled = true
