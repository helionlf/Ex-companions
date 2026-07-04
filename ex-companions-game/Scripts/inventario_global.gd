extends Node

var itens: Dictionary = {
	"madeira": 0,
	"ovo": 0,
	"espada_enferrujada": 0
}

# Sinal que avisa o jogo inteiro que um item foi pego
signal item_adicionado(nome_do_item, quantidade_total)

func adicionar_item(nome: String, quantidade: int) -> void:
	if itens.has(nome):
		itens[nome] += quantidade
	else:
		itens[nome] = quantidade
		
	item_adicionado.emit(nome, itens[nome])
	print("Coletou: ", nome, " | Total: ", itens[nome])
