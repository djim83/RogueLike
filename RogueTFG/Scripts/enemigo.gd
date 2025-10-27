extends CharacterBody2D

var spawn_position: Vector2
@export var patrol_radius: float = 350.0
@export var speed: float = 200.0
@export var life: float = 3

var current_direction := Vector2.ZERO
var change_direction_timer := 0.0
@export var direction_interval := 1.0  # Cambia cada 1 segundo

@export var vision_range: float = 500.0
var player: Node2D = null  # Se asignará desde fuera

@export var bullet_scene: PackedScene
@export var municion_scene: PackedScene
@export var fire_rate: float = 1.5  # Disparo cada 1.5s aprox
var time_since_last_shot: float = 0.0

var drop_chance = 0.3  # 30% de probabilidad

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func set_spawn(pos: Vector2):
	spawn_position = pos
	global_position = pos
	current_direction = get_random_direction()

func _process(delta):
	if player and global_position.distance_to(player.global_position) <= vision_range:
		# --- Perseguir al jugador ---
		var dir_to_player = (player.global_position - global_position).normalized()
		velocity = dir_to_player * speed

		# --- Intentar disparar ---
		time_since_last_shot += delta
		if time_since_last_shot >= fire_rate:
			shoot_at_player()
			time_since_last_shot = 0.0

	else:
		# --- Patrullar dentro del radio ---
		if global_position.distance_to(spawn_position) >= patrol_radius:
			var dir_to_spawn = (spawn_position - global_position).normalized()
			velocity = dir_to_spawn * speed
		else:
			if randf() < 0.02:
				var angle = randf_range(0, TAU)
				current_direction = Vector2(cos(angle), sin(angle)).normalized()
			velocity = current_direction * speed

	move_and_slide()
	if life <= 0:
		queue_free()

func get_random_direction() -> Vector2:
	var angle = randf_range(0, TAU)
	return Vector2(cos(angle), sin(angle)).normalized()

func _on_body_entered(body):
	if body.is_in_group("Proyectiles"):
		recibir_daño()
	elif body is TileMap:
		queue_free()

func recibir_daño(amount: int = 1) -> void:
	life -= amount
	if life <= 0:
		# --- Intento de soltar munición ---
		if municion_scene and randf() < drop_chance:
			var pickup = municion_scene.instantiate()
			pickup.global_position = global_position
			get_parent().add_child(pickup)

		queue_free()
	
func shoot_at_player():
	if not player: 
		return
	var bullet = bullet_scene.instantiate()
	var dir = (player.global_position - global_position).normalized()
	bullet.global_position = global_position
	bullet.direction = dir
	get_parent().add_child(bullet)
	
