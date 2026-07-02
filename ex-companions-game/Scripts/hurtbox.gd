extends Area2D


@export var owner_node: Node

func take_hit(damage):
	if owner_node.has_method("take_damage"):
		owner_node.take_damage(damage)

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("hitbox"):
		return
		
	if area.owner_node == owner_node:
		return

	take_hit(area.damage)
