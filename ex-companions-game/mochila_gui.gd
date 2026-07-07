extends Control

@onready var lista_materiais = $Abas/Materiais/ListaMaterias

func _ready() -> void:
	# A mochila começa invisível
	visible = false
	# Quando o script global gritar que ganhou item, a mochila se atualiza sozinha
	InventarioGlobal.item_adicionado.connect(_on_inventario_atualizado)

func _input(event: InputEvent) -> void:
	# Abre e fecha a mochila
	if event.is_action_pressed("Mochila"):
		visible = not visible
		if visible:
			atualizar_interface()

func _on_inventario_atualizado(_nome: String, _quantidade: int) -> void:
	# Se a mochila estiver aberta quando pegar o item, atualiza em tempo real
	if visible:
		atualizar_interface()

func atualizar_interface() -> void:
	# 1. Limpa todos os itens antigos da lista para não duplicar
	for filho in lista_materiais.get_children():
		filho.queue_free()
		
	# 2. Puxa os itens do Autoload e desenha a lista
	for chave_item in InventarioGlobal.itens.keys():
		var quantidade = InventarioGlobal.itens[chave_item]
		
		# Só mostra itens que você tem na mochila
		if quantidade > 0:
			var linha = HBoxContainer.new() # Coloca ícone e texto lado a lado
			
			# O Ícone do Item usando TextureRect
			var icone = TextureRect.new()
			icone.custom_minimum_size = Vector2(32, 32)
			icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED # Evita que a imagem fique esticada/deformada
			
			# --- A MÁGICA DAS IMAGENS AQUI ---
			# Verifica o nome do item e carrega o sprite correto
			match chave_item:
				"madeira":
					icone.texture = load("res://Testes/Basic Grass Biom things 1-1.png (2).png")
				"pedra":
					icone.texture = load("res://Testes/Basic Grass Biom things 1-1.png (1).png")
				# "ovo":
				# 	icone.texture = load("res://Caminho/Do/Seu/Ovo.png")
			
			# Adiciona a imagem na linha (Substituímos aquele cor_temp daqui!)
			linha.add_child(icone) 
			
			# O Texto (Nome + Quantidade)
			var nome_label = Label.new()
			nome_label.text = chave_item.capitalize() + "   x" + str(quantidade)
			nome_label.add_theme_font_size_override("font_size", 18)
			
			# Monta a linha
			linha.add_child(nome_label)
			lista_materiais.add_child(linha)
			
			# Adiciona um separador bonitinho embaixo
			var separador = HSeparator.new()
			lista_materiais.add_child(separador)
