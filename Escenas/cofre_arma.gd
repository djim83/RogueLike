extends Area2D

@export var arma_scene: PackedScene
@onready var sprite: Sprite2D = $Sprite2D
@onready var sonido_recoger: AudioStreamPlayer2D = $Sonido

var jugador: Node = null
var label: Label = null
var puede_recoger := false


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_actualizar_sprite()


func _actualizar_sprite():
	if arma_scene == null:
		return

	# Instanciamos el arma temporalmente para leer su sprite
	var arma_temp = arma_scene.instantiate()

	# PRIORIDAD 1: usar la propiedad exportada "sprite" del arma
	if arma_temp.has_method("get") and arma_temp.get("sprite") != null:
		sprite.texture = arma_temp.get("sprite")

	else:
		# PRIORIDAD 2: buscar un nodo Sprite2D dentro del arma
		var arma_sprite = arma_temp.get_node_or_null("Sprite2D")
		if arma_sprite:
			sprite.texture = arma_sprite.texture
			
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	sprite.scale = Vector2(4,4)

	arma_temp.queue_free()


func _on_body_entered(body):
	if not body.is_in_group("Jugador"):
		return

	jugador = body
	puede_recoger = true
	_mostrar_label()


func _on_body_exited(body):
	if body != jugador:
		return

	puede_recoger = false
	jugador = null
	_ocultar_label()


func _process(delta):
	if puede_recoger and Input.is_action_just_pressed("recoger"):
		_recoger()
		if sonido_recoger:
			sonido_recoger.play()


func _recoger():
	if not jugador or not arma_scene:
		return

	if jugador.has_method("recoger_secundaria"):
		jugador.recoger_secundaria(arma_scene)

	if sonido_recoger:
		sonido_recoger.play()

	_ocultar_label()
	queue_free()


func _mostrar_label():
	if label:
		return

	label = Label.new()
	label.text = "[F] Recoger"
	label.scale = Vector2(2.5, 2.5)
	label.modulate = Color(1, 1, 0)  # amarillo
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	get_tree().current_scene.add_child(label)
	label.global_position = global_position + Vector2(0, -40)


func _ocultar_label():
	if label and is_instance_valid(label):
		label.queue_free()
	label = null
