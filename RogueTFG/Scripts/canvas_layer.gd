extends CanvasLayer

# Referencias
@onready var player = get_node("../jugador")  
@onready var ammo_label = $ColorRect/Municion
@onready var vida_label = $ColorRect/Vida

func _process(delta):
	if player:
		ammo_label.text = "Balas: %d" % player.current_ammo
