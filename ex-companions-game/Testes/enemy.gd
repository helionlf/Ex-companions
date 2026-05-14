extends CharacterBody2D


@export var speed = 100.0
@export var life = 5

@export var chase_range = 500.0
@export var attack_range = 150.0

@export var target: CharacterBody2D

@onready var time = $Timer_attack

var can_attack = true


func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO

	if chase_player() and !attack_player():
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		look_target()
	
	if attack_player() and can_attack:
		look_target()
		attack()
		can_attack = false
		time.start()

	#move_and_slide()
	move_and_collide(velocity * _delta)

func attack():
	print("inimigo atacou")
	#$AnimatedSprite2D.stop()
	#$AnimatedSprite2D.play("attack")
	$hitbox/CollisionShape2D.disabled = false
	#aqyui troca o time por esperar animação acabar
	await get_tree().create_timer(1.0).timeout
	#await $AnimatedSprite2D.animation_finished
	$hitbox/CollisionShape2D.disabled = true

func take_damage(damage):
	print("inimigo tomou dano")
	life -= damage

#FUNÇÕES AUXILIARES --------------------------------------------------------------------------------

func chase_player():
	return global_position.distance_to(target.global_position) < chase_range
func attack_player():
	return global_position.distance_to(target.global_position) < attack_range
func look_target():
	if target.global_position.x > global_position.x:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true

#CONEXÕES ------------------------------------------------------------------------------------------

func _on_timer_attack_timeout() -> void:
	can_attack = true

#TROCAR POR AREA PARA FAZER HURTBOX NO PLAYER
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.get_name() == "player": #aqui adiciona todos q podem tomar dano
		body.take_damage(1)
