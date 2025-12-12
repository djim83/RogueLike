extends Area2D

@onready var anim := $AnimatedSprite2D

func _ready():
	add_to_group("Puerta")
	anim.play()  # reproduce la animación en loop
	connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body):
	if body.is_in_group("Jugador"):
		print("Vamos a la fase siguiente")

		var mejoras_scene = load("res://Escenas/Mejoras.tscn").instantiate()
		mejoras_scene.previous_scene_path = get_tree().current_scene.scene_file_path

		get_tree().root.add_child(mejoras_scene)
		
		get_tree().current_scene.queue_free()
		get_tree().current_scene = mejoras_scene
