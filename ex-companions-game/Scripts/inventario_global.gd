extends Node

var player_attack_cooldown: float = 0.8	

var itens: Dictionary = {
	"madeira": 0,
	"pedra": 0,
	"pena": 0,
	"espada_enferrujada": 0
}



# Sinais para avisar a interface/mochila sobre mudanças
signal item_adicionado(nome_do_item, quantidade_total)
signal item_removido(nome_do_item, quantidade_total)

func adicionar_item(nome: String, quantidade: int) -> void:
	if itens.has(nome):
		itens[nome] += quantidade
	else:
		itens[nome] = quantidade
		
	item_adicionado.emit(nome, itens[nome])
	print("Coletou: ", nome, " | Total: ", itens[nome])

# --- NOVAS FUNÇÕES PARA O SISTEMA DE UPGRADE / CRAFTING ---

# 1. Verifica se o player tem a quantidade necessária do item
func tem_item(nome: String, quantidade: int) -> bool:
	if itens.has(nome):
		return itens[nome] >= quantidade
	return false

# 2. Remove o item e avisa os sinais do jogo
func remover_item(nome: String, quantidade: int) -> bool:
	if tem_item(nome, quantidade):
		itens[nome] -= quantidade
		item_removido.emit(nome, itens[nome])
		print("Gastou: ", quantidade, " de ", nome, " | Restam: ", itens[nome])
		return true
	
	print("Falha ao remover: ", nome, " insuficiente!")
	return false
