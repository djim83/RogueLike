extends Arma

@export var balas_por_rafaga: int = 3
@export var intervalo: float = 0.1  # tiempo entre balas de la ráfaga

func disparar(origen: Vector2, dir: Vector2, parent: Node):
	if not puede_disparar():
		return
	tiempo_disparo = 0.0
	
	for i in range(balas_por_rafaga):
		await get_tree().create_timer(intervalo).timeout
		var bala = bullet_scene.instantiate()
		bala.global_position = origen
		bala.direction = dir
		parent.add_child(bala)
