extends CharacterBody2D

var spawn_position: Vector2
@export var patrol_radius: float = 350.0
@export var speed: float = 200.0
@export var life: float = 3

var current_direction := Vector2.ZERO
var change_direction_timer := 0.0
@export var direction_interval := 1.0  # Cambia cada 1 segundo
@export var tipo_disparo: int
@export var vision_range: float = 500.0
var player: Node2D = null 

@export var bullet_scene: PackedScene
@export var municion_scene: PackedScene
@export var vida_scene: PackedScene
@export var fire_rate: float = 1.5  # Disparo cada 1.5s aprox
var time_since_last_shot: float = 0.0

@export var puerta_scene: PackedScene

@onready var anim = $Sprite2D

@export var laser_scene: PackedScene

@onready var sonido_muerte: AudioStreamPlayer2D = $SonidoMuerte
@export var bullet_texture: Texture2D
@export var bullet_scale: Vector2 = Vector2(2, 2) 


var drop_chance = 0.4  # 40% de probabilidad

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func set_spawn(pos: Vector2):
	spawn_position = pos
	global_position = pos
	current_direction = get_random_direction()

func _process(delta):
	if player and global_position.distance_to(player.global_position) <= vision_range:
		# --- Perseguir al jugador ---
		var dir_to_player = (player.global_position - global_position).normalized()
		velocity = dir_to_player * speed
		anim.flip_h = player.global_position.x < global_position.x

		anim.play("Andar")

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
		_play_death_sound()

		var parent = get_parent()
		var is_last := false

		# Comprobar si es el último enemigo 
		if parent:
			var enemies_left = get_tree().get_nodes_in_group("Enemigos")
			if enemies_left.size() == 1: # solo queda él mismo
				is_last = true

		# Si NO es el último enemigo, puede soltar objetos 
		if not is_last and randf() < drop_chance:
			var r = randf()
			if r < 0.8:
				if municion_scene:
					var pick = municion_scene.instantiate()
					pick.global_position = global_position
					parent.add_child(pick)
			else:
				if vida_scene:
					var pick = vida_scene.instantiate()
					pick.global_position = global_position
					parent.add_child(pick)

		# Si ES el último, generar la puerta
		if is_last and puerta_scene:
			var puerta = puerta_scene.instantiate()
			puerta.global_position = global_position
			parent.add_child(puerta)

		queue_free()


	
func shoot_at_player():
	if not player: 
		return

	var dir = (player.global_position - global_position).normalized()

	match tipo_disparo:
		0:
			# Disparo normal (una sola bala hacia el jugador)
			_spawn_bullet(dir)

		1:
			# Escopeta (varias balas en cono)
			var spread = 15 # grados de apertura
			var balas = 5
			for i in range(balas):
				var angle = deg_to_rad(-spread/2 + (spread/(balas-1)) * i)
				var rotated_dir = dir.rotated(angle)
				_spawn_bullet(rotated_dir)

		2:
			# Triple disparo (una recta + dos abiertas)
			_spawn_bullet(dir)
			_spawn_bullet(dir.rotated(deg_to_rad(10)))
			_spawn_bullet(dir.rotated(deg_to_rad(-10)))

		3:
			# Disparo circular (todas direcciones alrededor del enemigo)
			var balas = 12
			for i in range(balas):
				var angle = (TAU / balas) * i
				var rotated_dir = Vector2.RIGHT.rotated(angle)
				_spawn_bullet(rotated_dir, 0.5, 3)
				
		4:
			_shoot_laser()

		_:
			# fallback al disparo normal
			_spawn_bullet(dir)


func _spawn_bullet(dir: Vector2, speed_multiplier: float = 1.0, lifeTime_multiplier: float = 1.0) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = dir

	# Asignar sprite según el enemigo 
	if bullet_texture:
		bullet.sprite_texture = bullet_texture

	# Asignar escala de bala según enemigo 
	bullet.sprite_scale = bullet_scale

	# Ajustar velocidad
	var current_speed = bullet.get("speed")
	if current_speed != null:
		bullet.speed = current_speed * speed_multiplier

	var current_life = bullet.get("lifetime")
	if current_life != null:
		bullet.lifetime = current_life * lifeTime_multiplier

	get_parent().add_child(bullet)


func _shoot_laser():
	if not player:
		return

	var laser := laser_scene.instantiate()

	var start := global_position
	var end := player.global_position

	laser.configure(start, end)

	get_parent().add_child(laser)

func _play_death_sound():
	if not sonido_muerte or not sonido_muerte.stream:
		return

	var s = AudioStreamPlayer2D.new()
	s.stream = sonido_muerte.stream
	s.global_position = global_position
	s.volume_db = sonido_muerte.volume_db
	s.pitch_scale = sonido_muerte.pitch_scale

	get_tree().current_scene.add_child(s)
	s.play()

	s.finished.connect(func():
		s.queue_free()
	)
