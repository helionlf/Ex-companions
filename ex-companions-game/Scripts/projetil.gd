extends Area2D

@export var speed: float = 300
@export var damage: int = 1

var direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	direction = (get_global_mouse_position() -  global_position).normalized()
	rotation = direction.angle()
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name.to_lower().contains("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage, get_tree().get_first_node_in_group("Player"))
	
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
