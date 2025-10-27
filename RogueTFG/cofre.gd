extends Area2D

@export var numero_balas: int = 25  # cuánto aumenta al recoger

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if !body.is_in_group("Enemigos"):
		if body.has_method("sumar_municion"):
			body.sumar_municion(numero_balas)
		queue_free()  # desaparece al tocar al jugador
