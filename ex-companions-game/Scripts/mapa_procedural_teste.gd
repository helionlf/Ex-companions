extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var objetos_container: Node2D = $Objeto

const Player = preload("res://Scenes/player.tscn")
const Arvore = preload("res://Scenes/Arvore.tscn")
const Pedra = preload("res://Scenes/pedra.tscn")

const Chunk_Size = 16
const Map_chunks_x = 6
const Map_chunks_y = 6

const Chance_Arvore = 0.001
const Chance_Pedra = 0.02

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	gerar_mapa_completo()
	spawn_centro()

func gerar_mapa_completo() -> void:
	for Chunk_X in range(Map_chunks_x):
		for Chunk_Y in range(Map_chunks_y):
			gerar_chunk(Chunk_X, Chunk_Y)
	print("tilemap scale: ", tile_map_layer.scale, " pos: ", tile_map_layer.position)
	print("canto (0,0): ", tile_map_layer.to_global(tile_map_layer.map_to_local(Vector2i(0,0))))
	print("canto (95,95): ", tile_map_layer.to_global(tile_map_layer.map_to_local(Vector2i(95,95))))

func gerar_chunk(cx: int, cy: int) -> void:
	var inicio_x = cx * Chunk_Size
	var fim_x = inicio_x + Chunk_Size
	var inicio_y = cy * Chunk_Size
	var fim_y = inicio_y + Chunk_Size
	
	for x in range(inicio_x, fim_x):
		for y in range(inicio_y, fim_y):
			tile_map_layer.set_cell(Vector2i(x, y), 0, Vector2i(2, 5))
			decorar_tile(x, y)

func decorar_tile(x: int, y: int) -> void:
	var valor_sorteado = rng.randf()
	
	var posicao_local = tile_map_layer.map_to_local(Vector2i(x, y))
	
	if valor_sorteado < Chance_Arvore:
		spawnar_objeto_alinhado(Arvore, posicao_local)
	elif valor_sorteado < (Chance_Arvore + Chance_Pedra):
		spawnar_objeto_alinhado(Pedra, posicao_local)

func spawnar_objeto_alinhado(cena_objeto: PackedScene, posicao_local: Vector2) -> void:
	var objeto = cena_objeto.instantiate()
	
	objetos_container.add_child(objeto)
	objeto.global_position = tile_map_layer.to_global(posicao_local)

func spawn_centro():
	var total_tiles_x = Map_chunks_x * Chunk_Size
	var total_tiles_y = Map_chunks_y * Chunk_Size
	
	var tile_centro_x = total_tiles_x / 2
	var tile_centro_y = total_tiles_y / 2
	var coordenacao_centro = Vector2i(tile_centro_x, tile_centro_y)
	
	var local_pos_player = tile_map_layer.map_to_local(coordenacao_centro)
	var player = Player.instantiate()
	add_child(player)
	player.global_position = tile_map_layer.to_global(local_pos_player)
	
	print("Player Spawnou no meio")
	
	
	
	
	
	
	
	
