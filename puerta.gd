extends Area2D

@onready var anim := $AnimatedSprite2D

var usada := false
var entradas_validas := 0
var evaluando := false

func _ready():
	add_to_group("Puerta")
	anim.play()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if usada:
		return

	if body is CharacterBody2D:
		usada = true
		monitoring = false
		call_deferred("_cambiar_escena")
		print("Entrada válida del jugador")



func _cambiar_escena():
	var escena_actual := get_tree().current_scene.scene_file_path

	if escena_actual.ends_with("nivelBoss.tscn"):
		get_tree().change_scene_to_file("res://Escenas/escenaFinal.tscn")
	else:
		var mejoras_scene: Node = load("res://Escenas/Mejoras.tscn").instantiate()
		mejoras_scene.previous_scene_path = escena_actual

		get_tree().root.add_child(mejoras_scene)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = mejoras_scene
