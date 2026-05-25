extends CharacterBody2D

@export var speed = 75.0
@export var chase_range = 50.0
@export var attack_range = 30.0
@export var player_follow_distance = 20.0 

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO

	var enemy = get_tree().get_first_node_in_group("Enemy")
	var player = get_tree().get_first_node_in_group("Player")

	if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) < chase_range:
		var distance_to_enemy = global_position.distance_to(enemy.global_position)
		
		if distance_to_enemy >= attack_range:
			var direction = (enemy.global_position - global_position).normalized()
			velocity = direction * speed
		
		if distance_to_enemy < attack_range:
			print("atacando inimigo!")


	elif is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player > player_follow_distance:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed

	move_and_collide(velocity * _delta)
