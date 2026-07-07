extends CharacterBody2D

@export var speed = 46.0
@export var health = 5

# 1. AUMENTAMOS O RAIO DE VISÃO (De 100 para 300)
@export var chase_range = 100.0
@export var attack_range = 15.0

var target: CharacterBody2D

@onready var navigation = $NavigationAgent2D
@onready var time = $Timer_attack

var can_attack = true

func _physics_process(_delta: float) -> void:
	# 2. CAÇA CONTÍNUA: Se perdeu o Player de vista ou nasceu cego, tenta achar de novo!
	if target == null:
		target = get_tree().get_first_node_in_group("Player")
		if target == null:
			return # Ainda não tem player, fica parado aguardando
			
	velocity = Vector2.ZERO
	
	if chase_player() and !attack_player():
		# 3. MOVIMENTO DIRETO (Ignora colisões complexas, mas funciona sempre)
		# Vamos usar matemática vetorial simples para ele ir na sua direção.
		# Se isso fizer eles andarem, significa que o seu TileSet estava sem Navigation!
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		look_target()

		# --- SE VOCÊ QUISER USAR O NAVIGATION DE NOVO NO FUTURO ---
		# Apague as 3 linhas acima e descomente as linhas abaixo.
		# (Mas lembre-se de configurar a camada de "Navigation" no seu TileSet da grama!)
		# navigation.target_position = target.global_position
		# var next_position = navigation.get_next_path_position()
		# var direction = (next_position - global_position).normalized()
		# velocity = direction * speed
		# look_target()

	if attack_player() and can_attack:
		look_target()
		attack()
		can_attack = false
		time.start()

	move_and_slide()
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.play("Parado") # Substitua pelo nome exato que está no seu Sprite
	else:
		$AnimatedSprite2D.play("Andando") # Substitua pelo nome exato da animação de andar

func attack():
	var indicator = preload("res://Scenes/attackindicator.tscn").instantiate()
	add_child(indicator)
	indicator.position = Vector2.ZERO
	indicator.play(10, 0.6)
	await get_tree().create_timer(1.0).timeout
	$hitbox/CollisionShape2D.disabled = false
	await get_tree().create_timer(0.1).timeout
	$hitbox/CollisionShape2D.disabled = true
	

func take_damage(amount):
	#print("inimigo tomou dano")
	health -= amount

# FUNÇÕES AUXILIARES -------------------------------------------------------------------------------
func chase_player():
	return global_position.distance_to(target.global_position) < chase_range
	
func attack_player():
	return global_position.distance_to(target.global_position) < attack_range
	
func look_target():
	if target.global_position.x > global_position.x:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true

# CONEXÕES -----------------------------------------------------------------------------------------
func _on_timer_attack_timeout() -> void:
	can_attack = true
