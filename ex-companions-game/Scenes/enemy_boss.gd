extends CharacterBody2D

# --- CONFIGURAÇÕES DE ATRIBUTOS (Altere pelo Inspetor se quiser) ---
@export_group("Atributos")
@export var speed: float = 40.0
@export var health: int = 50 

@export_group("Danos")
@export var dano_ataque_normal: int = 2      # Dano do golpe corpo a corpo
@export var dano_super_ataque: int = 5       # Dano do Dash

@export_group("Distâncias")
@export var chase_range: float = 120.0       # Reduzido para não te ver de longe
@export var attack_range: float = 100.0       # Distância para iniciar ataque normal

var target: CharacterBody2D = null

# Referências aos nós
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var time: Timer = $TimerAttack
@onready var hitbox: Area2D = $HitBox
@onready var hitbox_col: CollisionShape2D = $HitBox/CollisionShape2D
@onready var hurtbox_col: CollisionShape2D = $HurtBox/CollisionShape2D

var can_attack: bool = true
var can_super_attack: bool = true
var is_performing_super_atk: bool = false
var is_dead: bool = false 

var dano_atual_hitbox: int = 1 # Guarda qual dano aplicar no momento
var mira_linha: Line2D = null

func _ready() -> void:
	add_to_group("Inimigos")
	buscar_player()
	
	# Desativa a hitbox no início para segurança
	if is_instance_valid(hitbox_col):
		hitbox_col.disabled = true

func buscar_player() -> void:
	target = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta: float) -> void:
	if is_dead or is_performing_super_atk:
		return
		
	if not is_instance_valid(target):
		buscar_player()
		if not is_instance_valid(target):
			return

	velocity = Vector2.ZERO
	
	# 1. Super ataque se o player entrar no campo de visão
	if chase_player() and can_super_attack:
		super_atk()
		return
	
	# 2. Perseguição
	if chase_player() and not attack_player():
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		look_target()

	# 3. Ataque normal
	if attack_player() and can_attack:
		look_target()
		attack()
		can_attack = false
		if is_instance_valid(time):
			time.start()

	move_and_collide()
	
	# Animações
	if velocity == Vector2.ZERO:
		sprite.play("Parado_Boss")
	else:
		sprite.play("Andando_Boss")

func attack() -> void:
	print("Boss iniciou ataque normal!")
	dano_atual_hitbox = dano_ataque_normal
	
	if is_instance_valid(hitbox_col):
		hitbox_col.disabled = false
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(self) and is_instance_valid(hitbox_col):
			hitbox_col.disabled = true

func super_atk() -> void:
	if not is_instance_valid(target):
		return
		
	can_super_attack = false
	is_performing_super_atk = true
	velocity = Vector2.ZERO
	sprite.play("Parado_Boss")
	
	var ponto_inicio = global_position
	var ponto_alvo = target.global_position
	look_target()

	# Linha vermelha de mira
	mira_linha = Line2D.new()
	mira_linha.width = 8.0
	mira_linha.z_index = 10
	mira_linha.default_color = Color(1.0, 0.1, 0.1, 0.6)
	get_tree().current_scene.add_child(mira_linha)
	mira_linha.add_point(ponto_inicio)
	mira_linha.add_point(ponto_alvo)

	# Pisca a mira
	var tween_mira = create_tween().set_loops(4)
	tween_mira.tween_property(mira_linha, "modulate:a", 0.2, 0.2)
	tween_mira.tween_property(mira_linha, "modulate:a", 1.0, 0.2)

	await get_tree().create_timer(1.5).timeout

	if is_dead:
		if is_instance_valid(mira_linha):
			mira_linha.queue_free()
		return

	if is_instance_valid(mira_linha):
		mira_linha.queue_free()

	# Aplica o dano pesado do SUPER ATAQUE
	dano_atual_hitbox = dano_super_ataque
	
	if is_instance_valid(hitbox_col):
		hitbox_col.disabled = false

	# Dash veloz
	var tween_dash = create_tween()
	tween_dash.tween_property(self, "global_position", ponto_alvo, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween_dash.finished

	if is_instance_valid(self) and is_instance_valid(hitbox_col):
		hitbox_col.disabled = true

	is_performing_super_atk = false

	# Tempo de recarga do Super Ataque (12 segundos)
	await get_tree().create_timer(12.0).timeout
	if is_instance_valid(self):
		can_super_attack = true

func _on_hit_box_body_entered(body: Node2D) -> void:
	# Quando a Hitbox encostar no Player, causa o dano configurado
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(dano_atual_hitbox)
		print("Boss acertou o player com dano de: ", dano_atual_hitbox)

func take_damage(amount: int, _attacker: Node2D = null) -> void:
	if is_dead:
		return
		
	print("Boss tomou dano! Resta: ", health - amount)
	health -= amount
	
	var tween_dano = create_tween()
	tween_dano.tween_property(sprite, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.08)
	tween_dano.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.08)
	
	if health <= 0:
		dropar_recompensa_boss()

func dropar_recompensa_boss() -> void:
	is_dead = true
	visible = false
	
	if is_instance_valid(mira_linha):
		mira_linha.queue_free()
	
	if $CollisionShape2D:
		$CollisionShape2D.set_deferred("disabled", true)
	if is_instance_valid(hitbox_col):
		hitbox_col.set_deferred("disabled", true)
	if is_instance_valid(hurtbox_col):
		hurtbox_col.set_deferred("disabled", true)

	var player_node = target
	if not is_instance_valid(player_node):
		player_node = get_tree().get_first_node_in_group("Player")
	
	if not is_instance_valid(player_node):
		queue_free()
		return

	var pos_inicial = global_position
	var pos_final = player_node.global_position

	var raio_luz = ColorRect.new()
	raio_luz.color = Color(1.0, 0.85, 0.2, 1.0)
	raio_luz.size = Vector2(8, 8)
	get_tree().current_scene.add_child(raio_luz)
	raio_luz.global_position = pos_inicial - (raio_luz.size / 2.0)

	var rastro = Line2D.new()
	rastro.width = 10.0
	rastro.default_color = raio_luz.color
	
	var curva = Curve.new()
	curva.add_point(Vector2(0, 0.0))
	curva.add_point(Vector2(1, 1.0))
	rastro.width_curve = curva

	get_tree().current_scene.add_child(rastro)
	rastro.add_point(pos_inicial)
	rastro.add_point(pos_inicial)

	var tween = get_tree().current_scene.create_tween()

	tween.parallel().tween_property(raio_luz, "global_position", pos_final - (raio_luz.size / 2.0), 0.2)
	tween.parallel().tween_method(
		func(p: Vector2): if is_instance_valid(rastro): rastro.set_point_position(1, p),
		pos_inicial, pos_final, 0.2
	)

	tween.parallel().tween_method(
		func(p: Vector2): if is_instance_valid(rastro): rastro.set_point_position(0, p),
		pos_inicial, pos_final, 0.45
	)

	tween.tween_callback(func():
		if is_instance_valid(raio_luz): 
			raio_luz.queue_free()
			
		InventarioGlobal.adicionar_item("pena", 5)
		InventarioGlobal.adicionar_item("ovo", 1)
		mostrar_notificacao_gui("+ 5 Penas & + 1 Ovo Raro!")
	)

	tween.tween_property(rastro, "modulate:a", 0.0, 0.2)

	tween.tween_callback(func():
		if is_instance_valid(rastro): 
			rastro.queue_free()
		queue_free()
	)

func mostrar_notificacao_gui(texto: String) -> void:
	var label = Label.new()
	label.text = texto
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0, 1.0))
	
	var canvas = get_tree().current_scene.get_node_or_null("CanvasLayer")
	if canvas:
		canvas.add_child(label)
		var tamanho_tela = get_viewport_rect().size
		label.position = Vector2(tamanho_tela.x + 50, 20)
		
		var tween_gui = label.create_tween()
		tween_gui.tween_property(label, "position:x", tamanho_tela.x - 180, 0.3).set_trans(Tween.TRANS_BOUNCE)
		tween_gui.tween_interval(2.0)
		tween_gui.tween_property(label, "modulate:a", 0.0, 0.5)
		tween_gui.tween_callback(label.queue_free)

func chase_player() -> bool:
	if not is_instance_valid(target): return false
	return global_position.distance_to(target.global_position) < chase_range
	
func attack_player() -> bool:
	if not is_instance_valid(target): return false
	return global_position.distance_to(target.global_position) < attack_range
	
func look_target() -> void:
	if not is_instance_valid(target): return
	if target.global_position.x > global_position.x:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func _on_timer_attack_timeout() -> void:
	can_attack = true
