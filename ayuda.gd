extends Control

@onready var boton: Button = $Button

func _ready() -> void:
	$Button.pressed.connect(pulsado)

func pulsado():
	get_tree().change_scene_to_file("res://menu_principal.tscn")
