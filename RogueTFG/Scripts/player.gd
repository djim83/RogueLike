extends CharacterBody2D

var move_dir: Vector2
var velocidad := PlayerStats.velocidad

@export var bullet_scene: PackedScene
var fire_rate: float = PlayerStats.velocidad_disparo

var time_since_last_shot: float = 0.0

@onready var tilemap: TileMap = $"../TileMap"
@onready var camera: Camera2D = $Camera2D

var max_ammo: int = PlayerStats.municion_pistola
var current_ammo: int
var life: int = PlayerStats.vida

@onready var mira_sprite: Sprite2D = $"MiraSprite"
@export var mira_distance: float = 50.0  # distancia desde el jugador
@onready var canon: Node2D = $Cañon  # Nodo que marca la salida de la bala

@onready var game_over_panel: Panel = $"../GameOverLayer/Panel"
@onready var btn_jugar: Button = $"../GameOverLayer/Panel/Jugar"
@onready var btn_salir: Button = $"../GameOverLayer/Panel/Salir"

@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D

@onready var sonido_pistola: AudioStreamPlayer2D = $AudioDisparoPistola
@onready var sonido_escopeta: AudioStreamPlayer2D = $AudioDisparoEscopeta



var armas: Array[Arma] = []
var arma_actual: int = 0
var arma_secundaria: Arma = null
var tiene_secundaria: bool = false

var arma_base_scene: PackedScene
var arma_base_fire_rate: float

var invulnerable_time: float = 0.5
var tiempo_invulnerable: float = 0.0


func _ready():
	current_ammo = max_ammo
	
	arma_base_scene = bullet_scene
	arma_base_fire_rate = fire_rate
	
	var tile_pos = tilemap.player_spawn_tile
	var world_pos = tilemap.map_to_local(tile_pos)
	global_position = world_pos

	var used_rect = tilemap.get_used_rect()
	var cell_size = tilemap.get_tileset().tile_size

	camera.limit_left = int(used_rect.position.x * cell_size.x)
	camera.limit_top = int(used_rect.position.y * cell_size.y)
	camera.limit_right = int((used_rect.position.x + used_rect.size.x) * cell_size.x)
	camera.limit_bottom = int((used_rect.position.y + used_rect.size.y) * cell_size.y)
	
	btn_jugar.pressed.connect(_on_jugar_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)
	
	# Añadimos el arma por defecto al iniciar
	var arma_base = preload("res://Escenas/arma_base.tscn").instantiate()
	add_child(arma_base)


func _physics_process(delta: float) -> void:
	move_dir = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = move_dir * velocidad
	time_since_last_shot += delta
	move_and_slide()

	# --- Animación del jugador ---
	if move_dir.length() > 0.1:
		if anim_player.animation != "Andar":
			anim_player.play("Andar")
	else:
		if anim_player.animation != "Quieto":
			anim_player.play("Quieto")

	if Input.is_action_pressed("disparo") and time_since_last_shot >= fire_rate:
		shoot()
		time_since_last_shot = 0.0	

	if tiempo_invulnerable > 0:
		tiempo_invulnerable -= delta
		
	anim_player.flip_h = mira_sprite.flip_h



func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	var angle = dir.angle()

	# --- Cambiar sprite del arma según el arma actual ---
	if arma_actual == 0:
		mira_sprite.texture = preload("res://Sprites/Armas/Pistola.png")
		mira_sprite.scale = Vector2(4, 4)
	else:
		mira_sprite.texture = preload("res://Sprites/Armas/Escopeta.png")
		mira_sprite.scale = Vector2(4, 4)

	# --- Controlar el flip según hacia dónde apunta el ratón ---
	# Si el ratón está a la izquierda del jugador, voltea el arma horizontalmente
	mira_sprite.flip_v = false
	mira_sprite.flip_h = (mouse_pos.x < global_position.x)

	# --- Calcular posición del arma ---
	# La anclamos al "PuntoArma", y extendemos hacia la dirección del ratón
	var offset = Vector2.RIGHT.rotated(angle) * mira_distance
	mira_sprite.global_position = global_position + offset

	# --- Rotación visual ---
	# Si está mirando a la derecha, apunta normalmente; si a la izquierda, añadimos 180° (PI radianes)
	mira_sprite.rotation = angle if not mira_sprite.flip_h else angle + PI

	# --- Cañón del arma ---
	canon.global_position = mira_sprite.global_position + Vector2.RIGHT.rotated(angle) * (mira_distance * 0.4)
	canon.rotation = angle

	# --- Cambio de arma ---
	if Input.is_action_just_pressed("cambio_arma") and tiene_secundaria:
		if arma_actual == 0:
			arma_actual = 1
			bullet_scene = arma_secundaria.bullet_scene
			fire_rate = 0.3
			print("Arma actual: Secundaria (Escopeta)")
		else:
			arma_actual = 0
			bullet_scene = arma_base_scene
			fire_rate = arma_base_fire_rate
			print("Arma actual: Principal")


func recibir_daño(amount: int = 1) -> void:
	if tiempo_invulnerable > 0:
		return  # Ignora daño mientras invulnerable

	life = max(life - amount, 0)
	print("Vida: ", life)

	if life <= 0:
		game_over()
		set_physics_process(false)
		hide()

	tiempo_invulnerable = invulnerable_time


func shoot():
	if current_ammo <= 0:
		return
	current_ammo -= 1
	
# --- Sonido del disparo ---
	if arma_actual == 0:
	# Arma principal (pistola)
		if sonido_pistola:
			sonido_pistola.play()
	else:
	# Arma secundaria (escopeta)
		if sonido_escopeta:
			sonido_escopeta.play()

	# Instancia la bala
	var bala = bullet_scene.instantiate()

	# Punto de salida del disparo (el cañón del arma)
	var muzzle := canon.global_position

	# Dirección según la rotación del cañón (NO del ratón)
	var dir := Vector2.RIGHT.rotated(canon.global_rotation).normalized()

	# Posición inicial de la bala, ligeramente delante del cañón
	bala.global_position = muzzle + dir * 10.0
	bala.direction = dir
	bala.rotation = dir.angle()

	# Añadir la bala al árbol de la escena
	get_parent().add_child(bala)


func sumar_municion(amount: int):
	current_ammo += amount
	

func game_over():
	game_over_panel.visible = true
	#get_tree().paused = true  # pausa el juego


func _on_jugar_pressed():
	get_tree().reload_current_scene()
	print("Jugar...")


func _on_salir_pressed():
	get_tree().quit()
	print("Cerrar")


func recoger_secundaria():
	if not tiene_secundaria:
		arma_secundaria = preload("res://Escenas/arma_escopeta.tscn").instantiate()
		#add_child(arma_secundaria)
		tiene_secundaria = true
		print("Secundaria recogida: Escopeta")
