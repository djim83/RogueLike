extends CharacterBody2D

var move_dir: Vector2
@export var velocidad := 600.0

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.1

var time_since_last_shot: float = 0.0

@onready var tilemap: TileMap = $"../TileMap"
@onready var camera: Camera2D = $Camera2D

@export var max_ammo: int = 100
var current_ammo: int
@export var life: int = 10

@onready var mira_sprite: Sprite2D = $"MiraSprite"
@export var mira_distance: float = 40.0  # distancia desde el jugador
@onready var canon: Node2D = $Cañon  # Nodo que marca la salida de la bala

@onready var game_over_panel: Panel = $"../GameOverLayer/Panel"
@onready var btn_jugar: Button = $"../GameOverLayer/Panel/Jugar"
@onready var btn_salir: Button = $"../GameOverLayer/Panel/Salir"

@warning_ignore("unused_parameter")

func _physics_process(delta: float) -> void:
	move_dir = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = move_dir * velocidad
	time_since_last_shot += delta
	move_and_slide()
	if Input.is_action_pressed("disparo") and time_since_last_shot >= fire_rate:
		shoot()
		time_since_last_shot = 0.0	

func _ready():
	current_ammo = max_ammo
	
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
	
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()

	# Posicionar la mira
	mira_sprite.global_position = global_position + dir * mira_distance
	mira_sprite.rotation = dir.angle()

	# Hacer que el cañon esté en la punta del arma y gire hacia el ratón
	canon.global_position = global_position + dir * mira_distance  # o ajusta un offset
	canon.rotation = dir.angle()


	
func _on_body_entered(body):
	if body.is_in_group("Jugador"):
		recibir_daño()
		body.queue_free()
		

func recibir_daño(amount: int = 1) -> void:
	life -= amount
	if life < 0:
		game_over()
		set_physics_process(false) # Detiene _physics_process
		hide()   # Esto hace que el jugador desaparezca

func shoot():
	if current_ammo <= 0:
		return
	current_ammo -= 1

	var bala = bullet_scene.instantiate()
	var muzzle = canon.global_position  # ahora sale desde la pistola
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - muzzle).normalized()

	bala.global_position = muzzle
	bala.direction = dir

	get_parent().add_child(bala)

func sumar_municion(amount: int):
	current_ammo += amount
	
func game_over():
	game_over_panel.visible = true
	#get_tree().paused = true  # pausa el juego

func _on_jugar_pressed():
	get_tree().reload_current_scene()  # recarga la escena actual
	print("Jugar...")

func _on_salir_pressed():
	get_tree().quit()  # cierra el juego
	print("Cerrar")
