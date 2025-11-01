extends Area2D

@export var speed: float = 1000.0
@export var lifetime: float = 0.75  # segundos que vive la bala
var direction: Vector2 = Vector2.ZERO

@export var fragment_scene: PackedScene  # referencia a la escena fragmento
@export var fragments_count: int = 6  # cuántos fragmentos se crean

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	# Cuando pase "lifetime" segundos, se autodestruye
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if !body.is_in_group("Jugador") or body.is_in_group("Barriles"):
		_spawn_fragments()
		if body.has_method("recibir_daño"):
			body.recibir_daño(1)
		queue_free()
	elif body is TileMap:
		_spawn_fragments()
		queue_free()

func _spawn_fragments():
	for i in range(fragments_count):
		var frag = fragment_scene.instantiate()
		frag.global_position = global_position
		var angle = randf_range(0, TAU)  # ángulo aleatorio
		frag.direction = Vector2(cos(angle), sin(angle))
		get_parent().add_child(frag)
