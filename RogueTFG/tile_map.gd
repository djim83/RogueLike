extends TileMap

@export var map_width := 288
@export var map_height := 162

@export var floor_tile_id := 0
@export var wall_tile_id := 1
@export var tile_source_id := 0

@export var target_coverage := 0.5

@export var enemy_scene: PackedScene
@export var total_enemy_groups := 4
@export var group_size_range := Vector2i(2, 3)  # Entre 2 y 3 enemigos por grupo

@export var player: Node2D



var rng = RandomNumberGenerator.new()
var player_spawn_tile := Vector2i(0, 0)  # Aquí se guardará el tile válido

func _ready():
	rng.randomize()
	generate_random_walk_with_coverage()
	var numero_enemigos = randi_range(10, 15)

	poner_enemigos(numero_enemigos)  


func generate_random_walk_with_coverage():
	var total_tiles = (map_width - 2) * (map_height - 2)
	var target_floor_tiles = int(total_tiles * target_coverage)
	var floor_tiles = 0
	var visited := {}
	var first_floor_found := false

	for x in range(map_width):
		for y in range(map_height):
			set_cell(0, Vector2i(x, y), wall_tile_id, Vector2.ZERO, tile_source_id)

	@warning_ignore("integer_division", "shadowed_variable_base_class")
	var position = Vector2i(map_width / 2, map_height / 2)
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	while floor_tiles < target_floor_tiles:
		for dx in range(-1, 4):
			for dy in range(-1, 4):
				var pos = position + Vector2i(dx, dy)
				if pos.x >= 1 and pos.x < map_width - 1 and pos.y >= 1 and pos.y < map_height - 1:
					if not visited.has(pos):
						set_cell(0, pos, floor_tile_id, Vector2.ZERO, tile_source_id)
						visited[pos] = true
						floor_tiles += 1

						# Guardar la primera posición de suelo válida
						if not first_floor_found:
							player_spawn_tile = pos
							first_floor_found = true

		var dir = directions[rng.randi_range(0, directions.size() - 1)]
		position += dir
		position.x = clamp(position.x, 1, map_width - 2)
		position.y = clamp(position.y, 1, map_height - 2)
		
func poner_enemigos(count: int):
	var spawned := 0
	while spawned < count:
		var pos = Vector2i(rng.randi_range(1, map_width - 2), rng.randi_range(1, map_height - 2))
		if is_floor(pos):
			var enemy = enemy_scene.instantiate()
			enemy.global_position = map_to_local(pos)
			enemy.set_spawn(map_to_local(pos))
			add_child(enemy)
			spawned += 1
			enemy.player = player


			
func is_floor(pos: Vector2i) -> bool:
	return get_cell_source_id(0, pos) == tile_source_id and get_cell_atlas_coords(0, pos) == Vector2i(floor_tile_id, 0)
