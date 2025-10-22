extends Area2D

@export var speed: float = 600.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):  # Si el enemigo está en el grupo
		body.queue_free()  # Destruye al enemigo (luego puedes poner vida)
		queue_free()  # Destruye la bala
