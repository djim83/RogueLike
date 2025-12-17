# Valores globales para los atributos del jugador

extends Node

var velocidad: float = 600.0
var vida: int = 5
var velocidad_disparo: float = 0.1
var velocidad_disparo_secundaria: float = 0.3
var municion_pistola: float = 500
var secondary_weapon_scene: PackedScene = null
var has_secondary_weapon: bool = false

var history: Array[String] = []

func push(scene_path: String) -> void:
	if history.is_empty() or history[-1] != scene_path:
		history.append(scene_path)

func get_last_non_mejoras() -> String:
	for i in range(history.size() - 1, -1, -1,):
		if not history[i].ends_with("Mejoras.tscn"):
			return history[i]
	return ""
