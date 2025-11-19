extends TileMap

@export var map_width := 288
@export var map_height := 162

@export var floor_tiles := [0]  # IDs de los suelos
@export var wall_tiles := [9]      # Tile genérico de pared
@export var tile_source_id := 0
@export var id_fondo: int
@export var shadow_tile_id := 15  # Tile negro semitransparente para sombra

@export var target_coverage := 0.6

@export var enemy_scene: PackedScene
@export var enemy_scenes: Array[PackedScene]
@export var barril_scene: PackedScene
@export var total_enemy_groups := 4
@export var group_size_range := Vector2i(2, 3)  # Entre 2 y 3 enemigos por grupo

@export var arma_scene: PackedScene

# Número de elementos en pantalla
var rng = RandomNumberGenerator.new()
@export var armas = rng.randi_range(1, 3)
@export var barriles = rng.randi_range(8, 12)
@export var enemigos_min: int = 15
@export var enemigos_max: int = 25
var enemigos: int = 0

@export var player: Node2D

@export var torch_scene: PackedScene
@export var num_torches: int = 12


@onready var game_over_panel: Panel = $GameOverLayer/Panel


var player_spawn_tile := Vector2i(0, 0)  # Aquí se guardará el tile válido

func _ready():
	rng.randomize()
	generate_random_walk_with_coverage()
	update_wall_tiles()
	
	@warning_ignore("unused_variable")
	poner_armas(armas)
	poner_barriles(barriles)
	enemigos = randi_range(enemigos_min, enemigos_max)
	poner_enemigos(enemigos)
	poner_antorchas(12)


func generate_random_walk_with_coverage():
	var total_tiles = (map_width - 2) * (map_height - 2)
	var target_floor_tiles = int(total_tiles * target_coverage)
	var floor_tiles_count = 0
	var visited := {}
	var first_floor_found := false

	# Inicializar todo como pared genérica
	for x in range(map_width):
		for y in range(map_height):
			set_cell(0, Vector2i(x, y), wall_tiles[0], Vector2.ZERO, tile_source_id)

	@warning_ignore("integer_division", "shadowed_variable_base_class")
	var position = Vector2i(map_width / 2, map_height / 2)
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	while floor_tiles_count < target_floor_tiles:
		for dx in range(-1, 5):
			for dy in range(-1, 5):
				var pos = position + Vector2i(dx, dy)
				if pos.x >= 1 and pos.x < map_width - 1 and pos.y >= 1 and pos.y < map_height - 1:
					if not visited.has(pos):
						# Pintar suelo
						var floor_id = floor_tiles[rng.randi_range(0, floor_tiles.size() - 1)]
						set_cell(0, pos, floor_id, Vector2.ZERO, tile_source_id)
						visited[pos] = true
						floor_tiles_count += 1

						# Guardar primera posición de suelo
						if not first_floor_found:
							player_spawn_tile = pos
							first_floor_found = true

						# Revisar vecinos para bordes/esquinas
						for nx in range(-1, 2):
							for ny in range(-1, 2):
								var npos = pos + Vector2i(nx, ny)
								if npos.x >= 0 and npos.x < map_width and npos.y >= 0 and npos.y < map_height:
									if not visited.has(npos):
										var top = visited.has(npos + Vector2i(0, -1))
										var bottom = visited.has(npos + Vector2i(0, 1))
										var left = visited.has(npos + Vector2i(-1, 0))
										var right = visited.has(npos + Vector2i(1, 0))

										var wall_id = wall_tiles[0]  # default
										# Asignar ID según vecinos (ejemplo)
										if not top and not left and bottom and right:
											wall_id = 15  # esquina superior izquierda
										elif not top and not right and bottom and left:
											wall_id = 15  # esquina superior derecha
										elif not bottom and not left and top and right:
											wall_id = 15  # esquina inferior izquierda
										elif not bottom and not right and top and left:
											wall_id = 15  # esquina inferior derecha
										elif not top:
											wall_id = 15  # borde superior
										elif not bottom:
											wall_id = 15  # borde inferior
										elif not left:
											wall_id = 15  # borde izquierdo
										elif not right:
											wall_id = 15  # borde derecho

										set_cell(0, npos, wall_id, Vector2.ZERO, tile_source_id)

		# Moverse a la siguiente posición
		var dir = directions[rng.randi_range(0, directions.size() - 1)]
		position += dir
		position.x = clamp(position.x, 1, map_width - 2)
		position.y = clamp(position.y, 1, map_height - 2)

		

func poner_enemigos(count: int):
	var spawned := 0
	var safety := count * 50  # evita bucles infinitos

	while spawned < count and safety > 0:
		safety -= 1
		var pos = Vector2i(rng.randi_range(1, map_width - 2), rng.randi_range(1, map_height - 2))

		# --- Validación de zona ---
		if is_floor(pos) and es_zona_libre(pos):
			var enemy_scene = enemy_scenes.pick_random()
			var enemy = enemy_scene.instantiate()
			var spawn_pos = map_to_local(pos)
			enemy.global_position = spawn_pos
			enemy.set_spawn(spawn_pos)
			add_child(enemy)
			spawned += 1
			enemy.player = player


func es_zona_libre(pos: Vector2i) -> bool:
	# Comprueba que hay suelo en el centro y espacio alrededor (sin muros)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var check_pos = pos + Vector2i(x, y)
			if not is_floor(check_pos):
				return false
	return true

			
func poner_barriles(count: int):
	var spawned := 0
	while spawned < count:
		var pos = Vector2i(rng.randi_range(1, map_width - 2), rng.randi_range(1, map_height - 2))
		if is_floor(pos):
			var barril = barril_scene.instantiate()
			barril.global_position = map_to_local(pos)
			add_child(barril)
			spawned += 1
			
func poner_armas(count: int):
	var spawned := 0
	while spawned < count:
		var pos = Vector2i(rng.randi_range(1, map_width - 2), rng.randi_range(1, map_height - 2))
		if is_floor(pos):
			var arma = arma_scene.instantiate()
			arma.global_position = map_to_local(pos)
			add_child(arma)
			spawned += 1

			
			
func is_floor(pos: Vector2i) -> bool:
	var id = get_cell_source_id(0, pos)
	return id in floor_tiles

func is_wall(pos: Vector2i) -> bool:
	var id = get_cell_source_id(0, pos)
	return id in wall_tiles



# -------------------------------
# Postprocesado para bordes y esquinas
# -------------------------------

func update_wall_tiles():
	for x in range(map_width):
		for y in range(map_height):
			var pos = Vector2i(x, y)
			if is_wall(pos):
				var wall_id = choose_wall_tile(pos)
				set_cell(0, pos, wall_id, Vector2.ZERO, tile_source_id)

func choose_wall_tile(pos: Vector2i) -> int:
	# Revisar vecinos cardinales
	var top = is_wall(pos + Vector2i(0, -1))
	var bottom = is_wall(pos + Vector2i(0, 1))
	var left = is_wall(pos + Vector2i(-1, 0))
	var right = is_wall(pos + Vector2i(1, 0))

	# Ejemplos: asigna según vecinos
	if not top and not left and bottom and right:
		return id_fondo  # Esquina superior izquierda
	elif not top and not right and bottom and left:
		return 11  # Esquina superior derecha
	elif not bottom and not left and top and right:
		return 12  # Esquina inferior izquierda
	elif not bottom and not right and top and left:
		return 13  # Esquina inferior derecha
	elif not top:
		return 14  # Borde superior
	elif not bottom:
		return 15  # Borde inferior
	elif not left:
		return 16  # Borde izquierdo
	elif not right:
		return 17  # Borde derecho
	else:
		return wall_tiles[0]  # Centro / genérico


func poner_antorchas(count: int) -> void:
	if torch_scene == null:
		return

	var spawned: int = 0
	var safety: int = count * 50  # evita bucles infinitos si hay pocos sitios válidos

	while spawned < count and safety > 0:
		safety -= 1

		var x: int = rng.randi_range(1, map_width - 2)
		var y: int = rng.randi_range(1, map_height - 2)
		var pos: Vector2i = Vector2i(x, y)
		var up: Vector2i = pos + Vector2i(0, -1)

		# Condición: suelo con algo encima que no sea suelo (es decir, pared u otro tile)
		if is_floor(pos) and not is_floor(up):
			var torch: Node2D = torch_scene.instantiate() as Node2D
			torch.global_position = map_to_local(pos)
			add_child(torch)
			spawned += 1
			print("Antorcha colocada:", spawned)

			# Animar antorcha
			var anim_sprite: AnimatedSprite2D = torch.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
			if anim_sprite and anim_sprite.sprite_frames:
				var anims: PackedStringArray = anim_sprite.sprite_frames.get_animation_names()
				if anims.size() > 0:
					anim_sprite.play(anims[0])  # Reproduce la primera animación disponible
