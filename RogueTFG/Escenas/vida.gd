extends Area2D

@export var numero_vida: int = 1
@onready var Sprite2d: Sprite2D = $Sprite2D
@onready var sonido_pickup: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	Sprite2d.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS


func _on_body_entered(body):
	if !body.is_in_group("Enemigos"):
		if body.has_method("sumar_municion"):
			body.sumar_vida(numero_vida)

		if sonido_pickup:
			sonido_pickup.play()

		# Texto flotante
		_spawn_floating_text("+%s" % numero_vida)

		# Esperar a que termine el sonido antes de borrar el nodo
		await get_tree().create_timer(0.1).timeout
		queue_free()


func _spawn_floating_text(text: String):
	var label := Label.new()
	label.text = text
	label.scale = Vector2(4, 4)
	label.modulate = Color(1, 1, 0)  # amarillo

	# Situarlo justo encima del cofre
	label.global_position = global_position + Vector2(0, -20)

	get_tree().current_scene.add_child(label)

	# Animación sencilla: subir y desaparecer
	var tween = get_tree().create_tween()
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -40), 0.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)

	tween.finished.connect(func():
		label.queue_free()
	)
