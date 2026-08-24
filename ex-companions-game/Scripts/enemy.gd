class_name EnemyBase
extends CharacterBody2D


@export var speed = 46.0
@export var health = 5

@export var chase_range = 100.0
@export var attack_range = 15.0


var target: CharacterBody2D

@onready var navigation = $NavigationAgent2D
@onready var time = $Timer_attack
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var can_attack = true
var can_super_attack = true # Inicia como TRUE
var is_performing_super_atk = false # Trava o movimento normal durante o ataque
var is_dead = false 

var mira_linha: Line2D = null # Referência para a linha vermelha

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
		
	if target == null:
		target = get_tree().get_first_node_in_group("Player")
		if target == null:
			return
			
	# Se estiver preparando ou executando o super ataque, congela o movimento da IA padrão
	if is_performing_super_atk:
		return

	velocity = Vector2.ZERO
	
	# 1. Tenta fazer o SUPER ATAQUE primeiro se estiver no raio de visão
	if chase_player() and can_super_attack:
		super_atk()
		return
	
	# 2. Movimento e ataque normal
	if chase_player() and !attack_player():
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		look_target()

	if attack_player() and can_attack:
		look_target()
		attack()
		can_attack = false
		time.start()

	move_and_slide()
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.play("Parado")
	else:
		$AnimatedSprite2D.play("Andando")

func attack():
	print("inimigo atacou normal")
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.disabled = false
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(self) and has_node("hitbox/CollisionShape2D"):
			$hitbox/CollisionShape2D.disabled = true

func super_atk() -> void:
	can_super_attack = false
	is_performing_super_atk = true
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("Parado")
	
	# Trava o ponto final onde o player estava no início da mira
	var ponto_inicio = global_position
	var ponto_alvo = target.global_position
	look_target()

	# --- 1. CRIA A LINHA VERMELHA DE MIRA ---
	mira_linha = Line2D.new()
	mira_linha.width = 4.0
	mira_linha.default_color = Color(1.0, 0.1, 0.1, 0.45) # Vermelho translúcido/opaco
	get_tree().current_scene.add_child(mira_linha)
	mira_linha.add_point(ponto_inicio)
	mira_linha.add_point(ponto_alvo)

	# Pisca a linha levemente durante o carregamento de 1.5s
	var tween_mira = create_tween().set_loops(3)
	tween_mira.tween_property(mira_linha, "modulate:a", 0.2, 0.25)
	tween_mira.tween_property(mira_linha, "modulate:a", 1.0, 0.25)

	# Aguarda 1.5 segundos preparando o golpe
	await get_tree().create_timer(1).timeout

	# Se morreu durante a espera, interrompe
	if is_dead:
		if is_instance_valid(mira_linha):
			mira_linha.queue_free()
		return

	# Remove a linha de mira antes do dash
	if is_instance_valid(mira_linha):
		mira_linha.queue_free()

	# --- 2. EXECUTA O DASH VELOZ ---
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.disabled = false

	# Move rapidamente em linha reta até o ponto cravado (em 0.25 segundos)
	var tween_dash = create_tween()
	tween_dash.tween_property(self, "global_position", ponto_alvo, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween_dash.finished

	# Desativa a hitbox ao terminar o dash
	if is_instance_valid(self) and has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.disabled = true

	is_performing_super_atk = false

	# --- 3. COOLDOWN DE 15 SEGUNDOS ---
	await get_tree().create_timer(15.0).timeout
	if is_instance_valid(self):
		can_super_attack = true
		print("Inimigo recarregou o Super Ataque!")

func take_damage(amount: int, _attacker: Node2D = null) -> void:
	if is_dead:
		return
		
	print("inimigo tomou dano")
	health -= amount
	var tween_dano = create_tween()
	tween_dano.tween_property(sprite, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.08)
	tween_dano.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.08)
	if health <= 0:
		dropar_item_e_morrer()

func dropar_item_e_morrer() -> void:
	is_dead = true
	visible = false
	
	# Se a linha de mira ainda estiver ativa, deleta
	if is_instance_valid(mira_linha):
		mira_linha.queue_free()
	
	if $CollisionShape2D:
		$CollisionShape2D.set_deferred("disabled", true)
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.set_deferred("disabled", true)
	if has_node("hurtbox/CollisionShape2D"):
		$hurtbox/CollisionShape2D.set_deferred("disabled", true)

	var player_node = target
	if not is_instance_valid(player_node):
		player_node = get_tree().get_first_node_in_group("Player")
	
	if not is_instance_valid(player_node):
		queue_free()
		return

	var pos_inicial = global_position
	var pos_final = player_node.global_position

	var raio_luz = ColorRect.new()
	raio_luz.color = Color(0.974, 0.97, 0.976, 1.0)
	raio_luz.size = Vector2(4, 4)
	get_tree().current_scene.add_child(raio_luz)
	raio_luz.global_position = pos_inicial - (raio_luz.size / 2.0)

	var rastro = Line2D.new()
	rastro.width = 6.0
	rastro.default_color = raio_luz.color
	
	var curva = Curve.new()
	curva.add_point(Vector2(0, 0.0))
	curva.add_point(Vector2(1, 1.0))
	rastro.width_curve = curva

	get_tree().current_scene.add_child(rastro)
	rastro.add_point(pos_inicial)
	rastro.add_point(pos_inicial)

	var tween = get_tree().current_scene.create_tween()

	tween.parallel().tween_property(raio_luz, "global_position", pos_final - (raio_luz.size / 2.0), 0.15)
	tween.parallel().tween_method(
		func(p: Vector2): if is_instance_valid(rastro): rastro.set_point_position(1, p),
		pos_inicial, pos_final, 0.15
	)

	tween.parallel().tween_method(
		func(p: Vector2): if is_instance_valid(rastro): rastro.set_point_position(0, p),
		pos_inicial, pos_final, 0.35
	)

	tween.tween_callback(func():
		if is_instance_valid(raio_luz): 
			raio_luz.queue_free()
			
		InventarioGlobal.adicionar_item("pena", 1)
		mostrar_notificacao_gui("+ 1 Pena")
	)

	tween.tween_property(rastro, "modulate:a", 0.0, 0.15)

	tween.tween_callback(func():
		if is_instance_valid(rastro): 
			rastro.queue_free()
			
		queue_free()
	)

func mostrar_notificacao_gui(texto: String) -> void:
	var label = Label.new()
	label.text = texto
	label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0))
	
	var canvas = get_tree().current_scene.get_node_or_null("CanvasLayer")
	if canvas:
		canvas.add_child(label)
		var tamanho_tela = get_viewport_rect().size
		label.position = Vector2(tamanho_tela.x + 50, 20)
		
		var tween_gui = label.create_tween()
		tween_gui.tween_property(label, "position:x", tamanho_tela.x - 120, 0.3).set_trans(Tween.TRANS_BOUNCE)
		tween_gui.tween_interval(1.5)
		tween_gui.tween_property(label, "modulate:a", 0.0, 0.5)
		tween_gui.tween_callback(label.queue_free)

func chase_player():
	return global_position.distance_to(target.global_position) < chase_range
	
func attack_player():
	return global_position.distance_to(target.global_position) < attack_range
	
func look_target():
	if target.global_position.x > global_position.x:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true

func _on_timer_attack_timeout() -> void:
	can_attack = true
