extends Area2D

@export var speed: float = 600.0
@export var lifetime: float = 1  # segundos que vive la bala
var direction: Vector2 = Vector2.ZERO

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	# Cuando pase "lifetime" segundos, se autodestruye
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("Enemigos"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(1)
		queue_free()
	elif body is TileMap:
		queue_free()
