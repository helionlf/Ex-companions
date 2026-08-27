extends CharacterBody2D


@export var speed = 75.0
@export var chase_range = 90.0
@export var attack_range = 50.0
@export var player_follow_distance = 20.0 

var enemy
var player

var random_attack = 0
var current_attack = 0
var can_attack = true

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO

	enemy = get_tree().get_first_node_in_group("Enemy")
	player = get_tree().get_first_node_in_group("Player")

	if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) < chase_range:
		var distance_to_enemy = global_position.distance_to(enemy.global_position)
		
		if distance_to_enemy >= attack_range:
			var direction = (enemy.global_position - global_position).normalized()
			velocity = direction * speed
		
		if distance_to_enemy < attack_range and can_attack:
			print("atacando inimigo!")
			can_attack = false
			choose_attack()
			await get_tree().create_timer(2.0).timeout
			can_attack = true


	elif is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player > player_follow_distance:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed

	move_and_collide(velocity * _delta)
	
func choose_attack():
	var r_attack = 2
	#var r_attack = randi_range(1, 3)
	
	match r_attack:
		1:
			pass
		2:
			if enemy:
				var projetil = preload("res://Testes/Companion_attack_projetil.tscn").instantiate()

				projetil.global_position = global_position
				projetil.configurar_ataque("raio_psiquico", enemy, 100)
				
				get_tree().current_scene.add_child(projetil)

		3:
			pass
		_:
			pass
