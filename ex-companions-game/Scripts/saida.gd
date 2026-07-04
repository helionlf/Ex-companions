extends StaticBody2D

var pode_apertar: bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	pode_apertar = true
	print(pode_apertar)

func _on_area_2d_body_exited(body: Node2D) -> void:
	pode_apertar = false
	print(pode_apertar)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interagir") and pode_apertar:
		get_tree().change_scene_to_file("res://Scenes/MapaProceduralTeste.tscn")
