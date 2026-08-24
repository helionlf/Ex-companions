extends Node2D

var player_na_area: bool = false

func _ready() -> void:
	$Upgrade.visible = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_na_area = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_na_area = false
		$Upgrade.visible = false 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interagir") and player_na_area:
		$Upgrade.visible = not $Upgrade.visible
