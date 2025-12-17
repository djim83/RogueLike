extends CanvasLayer

@onready var player = get_node("../jugador")  
@onready var ammo_label = $ColorRect/Municion
@onready var vida_label = $ColorRect/Vida
@onready var nivel_label = $ColorRect/Nivel

func _ready():
	_actualizar_nombre_nivel()

func _process(delta):
	if player:
		ammo_label.text = "    %d" % player.current_ammo


func _actualizar_nombre_nivel():
	var path := get_tree().current_scene.scene_file_path
	var file := path.get_file()  # ej: "nivel2.tscn"

	match file:
		"tile_map.tscn":
			nivel_label.text = " NIVEL 1"
		"nivel2.tscn":
			nivel_label.text = " NIVEL 2"
		"nivel3.tscn":
			nivel_label.text = " NIVEL 3"
		"nivel4.tscn":
			nivel_label.text = " NIVEL 4"
		"nivel5.tscn":
			nivel_label.text = " NIVEL 5"
		"nivelBoss.tscn":
			nivel_label.text = " JEFE FINAL"
		_:
			nivel_label.text = ""
