extends Node2D

@export var lifetime := 0.2
@export var thickness := 4
@export var color := Color(1, 0, 0) # rojo
@export var damage := 1

@onready var line := $Line2D
@onready var hitbox := $Area2D
@onready var colshape := $Area2D/CollisionShape2D

var _start_pos: Vector2
var _end_pos: Vector2
var _configured := false

func configure(start_pos: Vector2, end_pos: Vector2):
	# Guardamos parámetros para aplicarlos cuando el nodo esté listo
	_start_pos = start_pos
	_end_pos = end_pos
	_configured = true

	# Si _ready ya ocurrió, configuramos inmediatamente
	if is_inside_tree():
		_apply_configuration()

func _ready():
	line.width = thickness
	line.default_color = color

	# Si configure() fue llamado antes de _ready(), aplicar ahora:
	if _configured:
		_apply_configuration()

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _apply_configuration():
	global_position = Vector2.ZERO

	if line:
		line.points = [_start_pos, _end_pos]

	if hitbox and colshape and colshape.shape:
		var shape := colshape.shape as RectangleShape2D
		shape.size.x = _start_pos.distance_to(_end_pos)
		shape.size.y = thickness * 2

		hitbox.rotation = (_end_pos - _start_pos).angle()
		hitbox.position = (_start_pos + _end_pos) * 0.5


func _on_Area2D_body_entered(body):
	if body.has_method("recibir_daño"):
		body.recibir_daño(damage)
