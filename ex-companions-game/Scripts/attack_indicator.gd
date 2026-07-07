extends Node2D

@onready var sprite = $Sprite2D

func play(radius: float, charge_time: float):
	sprite.scale = Vector2.ZERO
	sprite.scale = Vector2.ZERO
	sprite.modulate.a = 0.5
	var target_scale = Vector2.ONE * (radius / 64.0)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", target_scale, charge_time)
	await tween.finished
	sprite.modulate = Color(0.74, 0.185, 0.0, 0.776)
	await get_tree().create_timer(0.4).timeout
	queue_free()
