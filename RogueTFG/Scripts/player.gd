extends CharacterBody2D

var move_dir: Vector2
var velocidad := PlayerStats.velocidad

@export var bullet_scene: PackedScene
var fire_rate: float = PlayerStats.velocidad_disparo

var time_since_last_shot: float = 0.0

@onready var tilemap: TileMap = $"../TileMap"
@onready var camera: Camera2D = $Camera2D
@onready var hud := $"../Hud"

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
@onready var sonido_muerte: AudioStreamPlayer2D = $SonidoMuerte


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
	actualizar_corazones()
	
	arma_base_scene = bullet_scene
	arma_base_fire_rate = fire_rate

	if PlayerStats.has_secondary_weapon and PlayerStats.secondary_weapon_scene:
		arma_secundaria = PlayerStats.secondary_weapon_scene.instantiate()
		tiene_secundaria = true
		add_child(arma_secundaria)

		print("Secundaria restaurada:", arma_secundaria.nombre)

	
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
	
	anim_player.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


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
		mira_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	else:
		if arma_secundaria:
			mira_sprite.texture = arma_secundaria.sprite
			mira_sprite.scale = Vector2(4, 4)
			mira_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS



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
			fire_rate = arma_secundaria.fire_rate
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
	PlayerStats.vida = life
	actualizar_corazones()
	print("Vida: ", life)

	if life <= 0:
		game_over()
		set_physics_process(false)
		hide()
		if sonido_muerte:
			sonido_muerte.play()

	tiempo_invulnerable = invulnerable_time


func shoot():
	if current_ammo <= 0:
		return
	current_ammo -= 1
	PlayerStats.municion_pistola = current_ammo
	
	# --- Sonido del disparo ---
	if arma_actual == 0:
		# Arma principal — pistola
		if sonido_pistola:
			sonido_pistola.play()
	else:
		# Arma secundaria — sonido definido por el arma
		if arma_secundaria and arma_secundaria.sonido_disparo:
			var s := AudioStreamPlayer.new()
			s.stream = arma_secundaria.sonido_disparo
			add_child(s)
			s.play()

			s.finished.connect(func():
				await get_tree().process_frame
				s.queue_free()
			)

	# --- Instanciar bala ---
	var bala = bullet_scene.instantiate()

	var muzzle := canon.global_position
	var dir := Vector2.RIGHT.rotated(canon.global_rotation).normalized()

	bala.global_position = muzzle + dir * 20.0
	bala.direction = dir
	bala.rotation = dir.angle()

	get_parent().add_child(bala)


func sumar_municion(amount: int):
	current_ammo += amount
	PlayerStats.municion_pistola = current_ammo
	
func sumar_vida(amount: int):
	life += amount
	PlayerStats.vida = life
	actualizar_corazones()
	

func game_over():
	game_over_panel.visible = true
	#get_tree().paused = true  # pausa el juego


func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://menu_principal.tscn")
	print("Volviendo al menú principal...")


func _on_salir_pressed():
	get_tree().quit()
	print("Cerrar")


func recoger_secundaria(arma_packed: PackedScene) -> void:
	if not arma_packed:
		return

	# Eliminar la antigua
	if arma_secundaria and arma_secundaria.is_inside_tree():
		arma_secundaria.queue_free()

	# Instanciar nueva arma secundaria
	arma_secundaria = arma_packed.instantiate()
	tiene_secundaria = true
	add_child(arma_secundaria)
	
	PlayerStats.secondary_weapon_scene = arma_packed
	PlayerStats.has_secondary_weapon = true

	print("Secundaria recogida:", arma_secundaria.nombre)

	# Si el jugador está usando la secundaria ahora mismo
	# hay que actualizar inmediatamente bullet_scene y fire_rate
	if arma_actual == 1:
		bullet_scene = arma_secundaria.bullet_scene
		fire_rate = arma_secundaria.fire_rate



func actualizar_corazones():
	var contenedor: HBoxContainer = hud.get_node("ColorRect/Vida")

	for c in contenedor.get_children():
		c.queue_free()

	var tex = preload("res://Sprites/Varios/vida.png")
	
	for i in range(life):
		var heart := TextureRect.new()
		heart.texture = tex
		heart.custom_minimum_size = Vector2(32, 32)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		heart.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		contenedor.add_child(heart)
