extends Node2D

var spawn_position: Vector2


var current_direction := Vector2.ZERO

var player: Node2D = null  # Se asignará desde fuera



func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func set_spawn(pos: Vector2):
	spawn_position = pos
	global_position = pos
