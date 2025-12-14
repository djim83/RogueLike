extends Area2D

@export var arma_scene: PackedScene
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	body_entered.connect(_on_body_entered)
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
	if body.is_in_group("Jugador") and arma_scene:
		body.recoger_secundaria(arma_scene)
		queue_free()
