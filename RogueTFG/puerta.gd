extends Area2D

func _ready():
	add_to_group("puerta")

func _on_body_entered(body):
	if body.is_in_group("Jugador"): # asegúrate de meter al jugador en grupo "player"
		get_tree().change_scene_to_file("res://nivel2.tscn")
