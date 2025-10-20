extends TileMap

@export var map_width := 144
@export var map_height := 81

@export var floor_tile_id := 0
@export var wall_tile_id := 1
@export var tile_source_id := 0

@export var target_coverage := 0.40  # Ejemplo: 25% del mapa será suelo

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	generate_random_walk_with_coverage()

func generate_random_walk_with_coverage():
	var total_tiles = (map_width - 2) * (map_height - 2)  # Quitamos bordes
	var target_floor_tiles = int(total_tiles * target_coverage)
	var floor_tiles = 0
	var visited := {}

	# Paso 1: Rellenar todo con muros
	for x in range(map_width):
		for y in range(map_height):
			set_cell(0, Vector2i(x, y), wall_tile_id, Vector2i.ZERO, tile_source_id)

	# Paso 2: Excavar desde el centro
	var position = Vector2i(map_width / 2, map_height / 2)
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	while floor_tiles < target_floor_tiles:
		# Solo cavar si aún no se visitó esta celda
		if not visited.has(position):
			set_cell(0, position, floor_tile_id, Vector2i.ZERO, tile_source_id)
			visited[position] = true
			floor_tiles += 1

		# Movimiento aleatorio
		var dir = directions[rng.randi_range(0, directions.size() - 1)]
		position += dir

		# Limita el movimiento al área interior del mapa (borde excluido)
		position.x = clamp(position.x, 1, map_width - 2)
		position.y = clamp(position.y, 1, map_height - 2)
