extends Node2D

func _ready():
	# Cargar la escena del personaje
	var personaje_scene = load("res://Escenas/Jugador.tscn")

	# Instanciar la escena
	var personaje_instance = personaje_scene.instantiate()

	# Opcional: ponerlo en una posición inicial
	personaje_instance.position = Vector2(100, 200)  # Cambia a donde quieras

	# Añadir el personaje a la escena principal
	add_child(personaje_instance)
