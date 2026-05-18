extends CharacterBody2D


@export var speed = 100.0

@export var chase_range = 500.0
@export var attack_range = 200.0

@export var target: CharacterBody2D


func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO

	if chase_player() and !attack_player():
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
	
	if attack_player():
		print("atacando")

	#move_and_slide()
	move_and_collide(velocity * _delta)


func chase_player():
	return global_position.distance_to(target.global_position) < chase_range

func attack_player():
	return global_position.distance_to(target.global_position) < attack_range
