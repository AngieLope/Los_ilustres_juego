extends Node2D

@onready var video_player = $intro

func _ready():
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	get_tree().change_scene_to_file("res://fondonegro.tscn")
