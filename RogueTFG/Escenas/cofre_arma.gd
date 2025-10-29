extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Jugador"):
		print("Jugador recogió el arma")
		var nueva_arma = preload("res://Escenas/arma_escopeta.tscn").instantiate()
		body.add_arma(nueva_arma)
		queue_free()
