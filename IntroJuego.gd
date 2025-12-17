extends Control

@onready var label: Label = $Label
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var label_continue: Label = $Label2

# Texto completo de la historia
var full_text := """

De camino a casa tras el colegio,
el joven Pixel ve algo imposible…

Una puerta luminosa,
flotando en la calle.

No sabe por qué,
pero decide cruzarla.

Al otro lado le espera
un mundo hostil,
muros interminables
y criaturas peligrosas.

Armado con lo único que encuentra,
Pixel deberá abrirse paso
nivel tras nivel…

si quiere volver a casa.
"""

@export var char_delay := 0.06

var current_index := 0
var finished := false
var timer := 0.0

func _ready() -> void:
	label.text = ""
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL

	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.play("Normal")
	#label_continue.visible = false
	_parpadeo()

func _process(delta: float) -> void:
	if finished:
		return

	timer += delta
	if timer >= char_delay:
		timer = 0.0

		if current_index < full_text.length():
			label.text += full_text[current_index]
			current_index += 1
		else:
			finished = true
			# label.text += "\n\n[ Pulsa cualquier tecla para continuar ]"

func _input(event):
	if event.is_pressed():
		_go_to_game()

func _go_to_game():
	get_tree().change_scene_to_file("res://Escenas/tile_map.tscn")

func _parpadeo() -> void:
	var tween := get_tree().create_tween()
	tween.set_loops()

	tween.tween_property(label_continue, "modulate:a", 1.0, 0.6)
	tween.tween_property(label_continue, "modulate:a", 0.0, 0.6)
