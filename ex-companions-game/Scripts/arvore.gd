extends StaticBody2D

var player_perto: bool = false
var player_node: Node2D = null

@export var health: int = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.to_lower().contains("player"):
		player_perto = true
		player_node = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name.to_lower().contains("player"):
		player_perto = false
		player_node = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interagir") and player_perto:
		coletar_arvore()

func coletar_arvore() -> void:
	# 1. DESATIVA APENAS AS COLISÕES E A IMAGEM (Evita congelar os Tweens)
	visible = false
	player_perto = false
	
	if $CollisionShape2D:
		$CollisionShape2D.set_deferred("disabled", true)
	if has_node("Area2D/CollisionShape2D"):
		$Area2D/CollisionShape2D.set_deferred("disabled", true)

	# 2. VALIDAÇÃO DO PLAYER
	if not is_instance_valid(player_node):
		player_node = get_tree().get_first_node_in_group("Player")
	
	if not is_instance_valid(player_node):
		atualizar_minimapa_ao_destruir()
		queue_free()
		return

	var pos_inicial = global_position
	var pos_final = player_node.global_position

	# 3. CRIAÇÃO DOS ELEMENTOS VISUAIS
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

	# 4. TWEEN CRIADO NA CENA PRINCIPAL (IMPOSSÍVEL DE CONGELAR)
	var tween = get_tree().current_scene.create_tween()

	# Movimento do Quadradinho e da Cabeça do Rastro (0.15s)
	tween.parallel().tween_property(raio_luz, "global_position", pos_final - (raio_luz.size / 2.0), 0.15)
	tween.parallel().tween_method(
		func(p: Vector2): if is_instance_valid(rastro): rastro.set_point_position(1, p),
		pos_inicial, pos_final, 0.15
	)

	# Movimento da Cauda do Rastro (0.35s)
	tween.parallel().tween_method(
		func(p: Vector2): if is_instance_valid(rastro): rastro.set_point_position(0, p),
		pos_inicial, pos_final, 0.35
	)

	# Quando a luz atinge o player
	tween.tween_callback(func():
		if is_instance_valid(raio_luz): 
			raio_luz.queue_free()
			
		InventarioGlobal.adicionar_item("madeira", 1)
		mostrar_notificacao_gui("+ 1 Madeira")
	)

	# Faz o rastro sumir suavemente
	tween.tween_property(rastro, "modulate:a", 0.0, 0.15)

	# LIMPEZA FINAL
	tween.tween_callback(func():
		if is_instance_valid(rastro): 
			rastro.queue_free()
			
		atualizar_minimapa_ao_destruir()
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

func atualizar_minimapa_ao_destruir() -> void:
	var cena_mapa = get_tree().current_scene
	if cena_mapa and cena_mapa.has_node("TileMapLayer"):
		var tile_map_layer: TileMapLayer = cena_mapa.get_node("TileMapLayer")
		var tile_pos: Vector2i = tile_map_layer.local_to_map(tile_map_layer.to_local(global_position))
		
		var minimapa = cena_mapa.get_node_or_null("CanvasLayer/MiniMapa")
		if minimapa and minimapa.has_method("remover_do_mapa"):
			minimapa.remover_do_mapa(tile_pos.x, tile_pos.y)

func take_damage(amount: int, player_ref: Node2D = null) -> void:
	health -= amount
	if health <= 0:
		if player_ref:
			player_node = player_ref
		if not player_node:
			player_node = get_tree().get_first_node_in_group("Player")
		if player_node:
			coletar_arvore()
