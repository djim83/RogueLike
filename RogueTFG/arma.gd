extends Node2D
class_name Arma

@export var nombre: String = "Arma Base"
@export var sprite: Texture2D            
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.3
@export var fire_sound: AudioStream = null
@export var bullet_scale: Vector2 = Vector2.ONE  
@export var sonido_disparo: AudioStream

var tiempo_disparo := 0.0

func _process(delta: float) -> void:
	tiempo_disparo += delta

func puede_disparar() -> bool:
	return tiempo_disparo >= fire_rate

func disparar(origen: Vector2, dir: Vector2, parent: Node):
	if not puede_disparar():
		return
	tiempo_disparo = 0.0

	var bala = bullet_scene.instantiate()
	bala.global_position = origen
	bala.direction = dir

	# Se aplica escala si la bala la soporta
	if bala.has_variable("sprite_scale"):
		bala.sprite_scale = bullet_scale
	
	parent.add_child(bala)
