extends Area2D

@export var speed: float = 100.0
@export var lifetime: float = 0.3
var direction: Vector2 = Vector2.ZERO

@export var sprite_texture: Texture2D  
@export var sprite_scale: Vector2 = Vector2.ONE

@onready var sprite := $Sprite2D       

func _ready():
	# Asignar sprite si viene desde la bala
	if sprite_texture:
		sprite.texture = sprite_texture
		sprite.scale = sprite_scale

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta
