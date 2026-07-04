extends StaticBody2D

var player_perto: bool = false
var player_node: Node2D = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.to_lower().contains("player"):
		player_perto = true
		player_node = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name.to_lower().contains("player"):
		player_perto = false
		player_node = null

func _unhandled_input(event: InputEvent) -> void:
	# Quando apertar interagir perto da árvore
	if event.is_action_pressed("Interagir") and player_perto:
		coletar_arvore()

func coletar_arvore() -> void:
	visible = false
	player_perto = false 
	
	var pos_inicial = global_position
	var pos_final = player_node.global_position
	
	# 1. Cria a Cabeça (O Quadradinho que te acerta)
	var raio_luz = ColorRect.new()
	raio_luz.color = Color(0.96, 0.972, 1.0, 1.0)
	raio_luz.size = Vector2(4, 4) # Tamanho do quadrado
	get_tree().current_scene.add_child(raio_luz)
	raio_luz.global_position = pos_inicial - (raio_luz.size / 2.0) # Centraliza
	
	# 2. Cria a Linha Contínua (O Rastro com Curva)
	var rastro = Line2D.new()
	rastro.width = 6.0 # Largura MÁXIMA da linha (a parte gordinha)
	rastro.default_color = Color(1.0, 1.0, 1.0, 1.0)
	
	# --- A MÁGICA DO FORMATO ACONTECE AQUI ---
	var curva = Curve.new()
	curva.add_point(Vector2(0, 0.0)) # Ponto 0 (A Cauda): 0% de grossura (Fininha)
	curva.add_point(Vector2(1, 1.0)) # Ponto 1 (A Cabeça): 100% de grossura (Gordinha)
	rastro.width_curve = curva
	
	get_tree().current_scene.add_child(rastro)
	
	rastro.add_point(pos_inicial) # Índice 0: Cauda
	rastro.add_point(pos_inicial) # Índice 1: Cabeça
	
	# 3. Animação de Movimento (Rodando tudo ao mesmo tempo)
	var tween_movimento = create_tween().set_parallel(true)
	
	# Faz o Quadrado e a Cabeça da Linha voarem juntos (0.15s - Muito rápido!)
	tween_movimento.tween_property(raio_luz, "global_position", pos_final - (raio_luz.size / 2.0), 0.15).set_trans(Tween.TRANS_SINE)
	tween_movimento.tween_method(
		func(pos: Vector2): rastro.set_point_position(1, pos),
		pos_inicial, pos_final, 0.15
	).set_trans(Tween.TRANS_SINE)
	
	# Faz a Cauda seguir atrás mais devagar, criando o "estirão" elástico (0.4s)
	tween_movimento.tween_method(
		func(pos: Vector2): rastro.set_point_position(0, pos),
		pos_inicial, pos_final, 0.4
	).set_trans(Tween.TRANS_SINE)
	
	# Desaparecimento gradual do rastro (0.5s)
	tween_movimento.tween_property(rastro, "modulate:a", 0.0, 0.5)

	# 4. Lógica de Acerto
	var tween_logica = create_tween()
	tween_logica.tween_interval(0.15) # Exatamente a hora que o quadrado te atinge
	tween_logica.tween_callback(func():
		raio_luz.visible = false # Esconde o quadradinho instantaneamente ao bater
		InventarioGlobal.adicionar_item("pedra", 1)
		mostrar_notificacao_gui("+ 1 Pedra")
	)

	# 5. Limpeza de Memória
	var tween_limpeza = create_tween()
	tween_limpeza.tween_interval(0.5) # Espera o rastro terminar de sumir
	tween_limpeza.tween_callback(func():
		raio_luz.queue_free()
		rastro.queue_free() 
		queue_free() # Deleta a árvore
	)

func mostrar_notificacao_gui(texto: String) -> void:
	var label = Label.new()
	label.text = texto
	label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0)) # Texto Dourado
	
	var canvas = get_tree().current_scene.get_node("CanvasLayer")
	if canvas:
		canvas.add_child(label)
		
		var tamanho_tela = get_viewport_rect().size
		label.position = Vector2(tamanho_tela.x + 50, 20)
		
		# IMPORTANTE: Cria o tween amarrado à LABEL (label.create_tween)
		var tween_gui = label.create_tween()
		tween_gui.tween_property(label, "position:x", tamanho_tela.x - 120, 0.3).set_trans(Tween.TRANS_BOUNCE)
		tween_gui.tween_interval(1.5) 
		tween_gui.tween_property(label, "modulate:a", 0.0, 0.5) 
		tween_gui.tween_callback(label.queue_free)
