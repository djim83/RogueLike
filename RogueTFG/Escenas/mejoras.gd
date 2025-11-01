extends Control

@export var next_level: String = "res://nivel2.tscn"

func _ready():
	$MarginContainer/VBoxContainer/Button.connect("pressed", Callable(self, "_on_velocidad_pressed"))
	$MarginContainer/VBoxContainer/Button2.connect("pressed", Callable(self, "_on_vida_pressed"))
	$MarginContainer/VBoxContainer/Button3.connect("pressed", Callable(self, "_on_ataque_pressed"))

func _on_velocidad_pressed():
	PlayerStats.speed += 50
	_load_next_level()

func _on_vida_pressed():
	PlayerStats.max_life += 1
	PlayerStats.life = PlayerStats.max_life  # curamos de paso
	_load_next_level()

func _on_ataque_pressed():
	PlayerStats.fire_rate *= 0.8  # dispara más rápido
	_load_next_level()

func _load_next_level():
	get_tree().change_scene_to_file(next_level)
