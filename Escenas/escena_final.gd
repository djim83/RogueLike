extends Control

@onready var btn_menu: Button = $FinalOverLayer/Panel/Menu
@onready var btn_salir: Button = $FinalOverLayer/Panel/Salir


func _ready() -> void:
	btn_menu.pressed.connect(_on_btn_menu_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)


func _on_btn_menu_pressed() -> void:
	print("Volver al menú principal")
	get_tree().change_scene_to_file("res://menu_principal.tscn")
	PlayerStats.municion_pistola = 500
	PlayerStats.vida = 5
	PlayerStats.velocidad = 600
	PlayerStats.velocidad_disparo = 0.1
	PlayerStats.secondary_weapon_scene = null
	


func _on_btn_salir_pressed() -> void:
	print("Salir del juego")
	get_tree().quit()
