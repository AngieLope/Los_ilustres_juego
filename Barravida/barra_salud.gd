extends CanvasLayer

@export var Player_node: NodePath  # Exportar el NodePath del jugador
@onready var Player: Node = get_node(Player_node)  # Usar onready para obtener el nodo del jugador
@onready var progress_bar = $TextureProgressBar

func _ready():
	# Aquí puedes hacer alguna inicialización adicional si es necesario
	pass

func _process(delta):
	if Player and progress_bar:  # Asegúrate de que Player y la barra de progreso no sean null
		progress_bar.value = Player.health  # Actualiza el valor de la barra de vida
