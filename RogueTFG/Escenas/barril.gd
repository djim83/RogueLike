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
		if explosion_scene:
			queue_free()
			var explosion = explosion_scene.instantiate()
			explosion.global_position = global_position
			get_parent().add_child(explosion)

			# Activar emisión de partículas
			if explosion is GPUParticles2D:
				explosion.emitting = true
				# Destruir la explosión después de su lifetime
				var lifetime = explosion.lifetime
				await get_tree().create_timer(lifetime).timeout
				explosion.queue_free()

		queue_free()
