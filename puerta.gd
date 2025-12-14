extends Area2D

@onready var anim := $AnimatedSprite2D

var usada := false
var entradas_validas := 0
var evaluando := false

func _ready():
	add_to_group("Puerta")
	anim.play()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if usada:
		print("Usadaaaaa")
		return

	# Ignorar enemigos y balas
	if body.is_in_group("Enemigos") or body.is_in_group("BalasEnemigas"):
		print("Choca con enemigo o bala")
		return

	if body.is_in_group("Proyectiles"):
		print("Choca con bala")
		return

	# Entrada válida (jugador)
	print("Choca con jugador")
	entradas_validas += 1

	if evaluando:
		return

	evaluando = true
	call_deferred("_evaluar_entrada")

func _on_body_exited(body):
	if not body.is_in_group("Jugador"):
		return

	entradas_validas = max(entradas_validas - 1, 0)

func _evaluar_entrada():
	# Esperamos un frame para que se registren todas las colisiones
	await get_tree().process_frame
	evaluando = false

	# SOLO si hay exactamente una entrada válida
	if entradas_validas == 1:
		print("Entrada limpia. Cambiando escena")
		usada = true
		monitoring = false
		_cambiar_escena()
	else:
		print("Entrada múltiple. Ojooooo")

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
