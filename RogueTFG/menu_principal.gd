extends Control

func _ready():
	$Botonera/BtnIniciar.pressed.connect(_on_iniciar_pressed)
	$Botonera/BtnTutorial.pressed.connect(_on_tutorial_pressed)
	$Botonera/BtnSalir.pressed.connect(_on_salir_pressed)

func _on_iniciar_pressed():
	get_tree().change_scene_to_file("res://Escenas/tile_map.tscn")  # Ajusta la ruta

func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://Escenas/Tutorial.tscn")

func _on_salir_pressed():
	get_tree().quit()
