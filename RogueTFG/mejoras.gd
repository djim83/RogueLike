extends Control

@export var next_scene_path: String = "res://Escenas/nivel2.tscn"

static var previous_scene_path := ""

@onready var contenedor := $VBoxContainer
@onready var titulo: Label = $Label

var mejoras := [
	{
	"texto": "Vida +1",
	"accion": func():
	PlayerStats.vida += 1
	},

	{
	"texto": "Vida +2",
	"accion": func():
	PlayerStats.vida += 2
	},

	{
	"texto": "Munición +100",
	"accion": func():
	PlayerStats.municion_pistola += 100
	},

	{
	"texto": "Munición +200",
	"accion": func():
	PlayerStats.municion_pistola += 200
	},

	{
	"texto": "Velocidad +10%",
	"accion": func():
	PlayerStats.velocidad *= 1.10
	},

	{
	"texto": "Velocidad +20%",
	"accion": func():
	PlayerStats.velocidad *= 1.20
	},

	{
	"texto": "Cadencia +10%",
	"accion": func():
	PlayerStats.velocidad_disparo = max(0.02, PlayerStats.velocidad_disparo * 0.9)
	},

	{
	"texto": "Cadencia +20%",
	"accion": func():
	PlayerStats.velocidad_disparo = max(0.02, PlayerStats.velocidad_disparo * 0.8)
	},
]



# Seleccionamos 4 mejoras aleatorias y generamos los botones
func _ready() -> void:

	# Poner un color aleatorio al label
	_set_random_title_color()
	
	# Mezclar la lista
	var lista = mejoras
	lista.shuffle()

	# Elegir las primeras 4
	var seleccion = lista.slice(0, 4)

	# Crear un botón para cada mejora seleccionada
	for mejora in seleccion:
		var b := Button.new()
		b.text = mejora["texto"]
		b.custom_minimum_size = Vector2(0, 60)

		# Conectar la acción
		b.pressed.connect(func():
			mejora["accion"].call()
			_go_next()
		)

		contenedor.add_child(b)



func _go_next():
	var next := ""

	if previous_scene_path.ends_with("tile_map.tscn"):
		next = "res://Escenas/nivel2.tscn"
	elif previous_scene_path.ends_with("nivel2.tscn"):
		next = "res://Escenas/nivel3.tscn"
	elif previous_scene_path.ends_with("nivel3.tscn"):
		next = "res://Escenas/nivel4.tscn"
	elif previous_scene_path.ends_with("nivel4.tscn"):
		next = "res://Escenas/nivel5.tscn"
	else:
		next = "res://Escenas/menu_principal"

	print("Cargando siguiente nivel:", next)
	get_tree().change_scene_to_file(next)

func _set_random_title_color() -> void:
	# Colores estilo pixel interesantes:
	var colores := [
		Color(1, 1, 0),        # Amarillo
		Color(1, 0.5, 0),      # Naranja
		Color(0, 1, 1),        # Turquesa
		Color(1, 0, 0),        # Rojo
		Color(0.6, 1, 0.2),    # Verde lima
		Color(1, 0.2, 0.7),    # Rosa
		Color(1, 1, 1),        # Blanco brillante
	]

	titulo.modulate = colores.pick_random()
