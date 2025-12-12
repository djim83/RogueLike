extends Node2D

var spawn_position: Vector2
@export var life: int = 0
@export var explosion_scene: PackedScene
@onready var sonido_barril: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: Sprite2D = $Sprite2D

var is_dead = false

func _ready() -> void:
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS

func recibir_daño(amount: int = 1) -> void:
	if is_dead:
		return  # <<< evita dobles ejecuciones

	life -= amount

	if life > 0:
		return

	# --- Marcar como muerto inmediatamente ---
	is_dead = true

	# --- Reproducir sonido independiente ---
	_play_barrel_sound()

	# --- Crear explosión ---
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_parent().add_child(explosion)

		if explosion is GPUParticles2D:
			explosion.emitting = true
			var lifetime = explosion.lifetime
			await get_tree().create_timer(lifetime).timeout
			explosion.queue_free()

	queue_free()


func _play_barrel_sound():
	var snd := AudioStreamPlayer2D.new()
	snd.stream = sonido_barril.stream
	snd.global_position = global_position
	snd.volume_db = sonido_barril.volume_db
	snd.pitch_scale = sonido_barril.pitch_scale

	get_tree().current_scene.add_child(snd)
	snd.play()

	snd.finished.connect(func():
		snd.queue_free())
