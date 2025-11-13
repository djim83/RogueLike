extends Area2D

func _ready():
	add_to_group("Puerta")

func _on_body_entered(body):
	if body.is_in_group("Jugador"):
		print("Vamos a la fase siguiente")
		get_tree().change_scene_to_file("res://Escenas/Mejoras.tscn")
