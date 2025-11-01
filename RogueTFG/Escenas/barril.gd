extends Node2D

var spawn_position: Vector2
@export var life:int = 0
@export var explosion_scene: PackedScene

var current_direction := Vector2.ZERO

var player: Node2D = null  # Se asignará desde fuera



func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func set_spawn(pos: Vector2):
	spawn_position = pos
	global_position = pos
	
func recibir_daño(amount: int = 1) -> void:
	life -= amount
	if life <= 0:
		# --- Intento de soltar munición ---
		if explosion_scene:
			var explosion = explosion_scene.instantiate()
			explosion.global_position = global_position
			get_parent().add_child(explosion)

		queue_free()
