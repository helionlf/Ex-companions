extends Control

@onready var lista_materiais = $Abas/Armas/ListaMaterias

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
			
			# O Ícone do Item (Como você tem os ícones, depois você coloca a textura aqui)
			var icone = TextureRect.new()
			icone.custom_minimum_size = Vector2(32, 32)
			icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			# icone.texture = load("res://caminho/do/seu/icone.png") # <--- DESCOMENTE QUANDO FOR USAR A IMAGEM
			
			# Opcional enquanto não põe a imagem: Um quadradinho colorido de placeholder
			var cor_temp = ColorRect.new()
			cor_temp.custom_minimum_size = Vector2(32, 32)
			cor_temp.color = Color(0.5, 0.3, 0.1) # Marrom pra madeira
			linha.add_child(cor_temp) # Troque 'cor_temp' por 'icone' depois
			
			# O Texto (Nome + Quantidade)
			var nome_label = Label.new()
			nome_label.text = chave_item.capitalize() + "   x" + str(quantidade)
			nome_label.add_theme_font_size_override("font_size", 18)
			
			# Monta a linha
			linha.add_child(nome_label)
			lista_materiais.add_child(linha)
			
			# Adiciona um separador bonitinho embaixo (Estilo RPG)
			var separador = HSeparator.new()
			lista_materiais.add_child(separador)
