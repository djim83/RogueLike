extends Area2D

@onready var anim := $AnimatedSprite2D

func _ready():
	add_to_group("Puerta")
	anim.play() 
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if not body.is_in_group("Jugador"):
		return

	print("Entrando por la puerta")

	var escena_actual := get_tree().current_scene.scene_file_path
	var siguiente_escena: Node

	if escena_actual.ends_with("nivelBoss.tscn"):
		siguiente_escena = load("res://Escenas/escenaFinal.tscn").instantiate()
	else:
		siguiente_escena = load("res://Escenas/Mejoras.tscn").instantiate()
		siguiente_escena.previous_scene_path = escena_actual

	get_tree().root.add_child(siguiente_escena)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = siguiente_escena
