extends Area2D

func _ready():
	add_to_group("Puerta")

func _on_body_entered(body):
	if body.is_in_group("Jugador"):
		print("Vamos a la fase siguiente")
		
		# 1. Guardar la escena actual como "anterior"
		var mejoras_scene = load("res://Escenas/Mejoras.tscn").instantiate()
		mejoras_scene.previous_scene_path = get_tree().current_scene.scene_file_path

		# 2. Cambiar de escena manualmente
		get_tree().root.add_child(mejoras_scene)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = mejoras_scene
