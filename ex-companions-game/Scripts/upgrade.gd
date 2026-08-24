extends CanvasLayer 

@export var custo_pedra: int = 3
@export var aumento_atk_speed: float = 0.05

func _on_button_pressed() -> void:
	# 1. Verifica se o InventarioGlobal tem pedras suficientes
	# Assumindo que seu inventário tem um método para checar/remover itens:
	if InventarioGlobal.tem_item("pedra", custo_pedra):
		# 2. Consome/Remove as pedras do inventário
		InventarioGlobal.remover_item("pedra", custo_pedra)
		
		# 3. Localiza o Player na cena e melhora o atributo
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("melhorar_velocidade_ataque"):
			player.melhorar_velocidade_ataque(aumento_atk_speed)
			print("Upgrade comprado com sucesso!")
	else:
		print("Pedras insuficientes! Você precisa de ", custo_pedra, " pedras.")
