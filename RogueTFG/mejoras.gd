extends Control

@export var next_scene_path: String = "res://Escenas/nivel2.tscn"

@onready var btn_vida: Button = $VBoxContainer/Button_Vida
@onready var btn_municion: Button = $VBoxContainer/Button_Municion
@onready var btn_velocidad: Button = $VBoxContainer/Button_Velocidad
@onready var btn_cadencia: Button = $VBoxContainer/Button_Cadencia

static var previous_scene_path := ""

func _ready() -> void:
	btn_vida.pressed.connect(_on_btn_vida)
	btn_municion.pressed.connect(_on_btn_municion)
	btn_velocidad.pressed.connect(_on_btn_velocidad)
	btn_cadencia.pressed.connect(_on_btn_cadencia)

func _on_btn_vida() -> void:
	PlayerStats.vida += 1
	_go_next()

func _on_btn_municion() -> void:
	var antes = PlayerStats.municion_pistola
	PlayerStats.municion_pistola += 50
	var despues = PlayerStats.municion_pistola
	print("Mejora: Munición. Munición pasa de %d a %d" % [antes, despues])
	_go_next()

func _on_btn_velocidad() -> void:
	var antes = PlayerStats.velocidad
	PlayerStats.velocidad *= 1.20
	var despues = PlayerStats.velocidad
	print("Mejora: Velocidad. Velocidad pasa de %f a %f" % [antes, despues])
	_go_next()

func _on_btn_cadencia() -> void:
	var antes = PlayerStats.velocidad_disparo
	PlayerStats.velocidad_disparo = max(0.02, PlayerStats.velocidad_disparo * 0.8)
	var despues = PlayerStats.velocidad_disparo
	print("Mejora: Cadencia. Velocidad de disparo pasa de %f a %f" % [antes, despues])
	_go_next()

func _go_next():
	var next := ""

	if previous_scene_path.ends_with("tile_map.tscn"):
		next = "res://Escenas/nivel2.tscn"
	elif previous_scene_path.ends_with("nivel2.tscn"):
		next = "res://Escenas/nivel3.tscn"
	elif previous_scene_path.ends_with("nivel3.tscn"):
		next = "res://Escenas/nivel4.tscn"
	else:
		# Si venimos de un nivel desconocido volvemos al menú
		next = "res://Escenas/menu_principal"

	print("Cargando siguiente nivel:", next)
	get_tree().change_scene_to_file(next)
