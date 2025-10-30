extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if !body.is_in_group("Enemigos"):
		print("Jugador recogió el arma")
		body.recoger_secundaria()  # llama al método que ya definimos en el Player
		queue_free()
