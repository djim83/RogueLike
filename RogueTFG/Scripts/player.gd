extends CharacterBody2D

var move_dir: Vector2
@export var velocidad := 600.0  # Mejor un valor en pixeles/segundo

@onready var tilemap: TileMap = $"../TileMap"
@onready var camera: Camera2D = $Camera2D

@warning_ignore("unused_parameter")

func _physics_process(delta: float) -> void:
	move_dir = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = move_dir * velocidad
	move_and_slide()

func _ready():
	var tile_pos = tilemap.player_spawn_tile
	var world_pos = tilemap.map_to_local(tile_pos)
	global_position = world_pos
	
	var used_rect = tilemap.get_used_rect()
	var cell_size = tilemap.get_tileset().tile_size

	camera.limit_left = int(used_rect.position.x * cell_size.x)
	camera.limit_top = int(used_rect.position.y * cell_size.y)
	camera.limit_right = int((used_rect.position.x + used_rect.size.x) * cell_size.x)
	camera.limit_bottom = int((used_rect.position.y + used_rect.size.y) * cell_size.y)
	
	
