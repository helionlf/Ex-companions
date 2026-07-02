extends TextureRect

const CHUNK_SIZE = 16
var Map_chunks_x = 6
var Map_chunks_y = 6

var map_width: int
var map_length: int

const cor_nevoa = Color(0, 0, 0, 1)
const cor_grama = Color(0.2, 0.6, 0.2, 1)
const cor_arvore = Color(0.1, 0.4, 0.1, 1)
const cor_pedra = Color(0.5, 0.5, 0.5, 1)
const cor_player = Color(0.9, 0.2, 0.2, 1)

var image_mapa: Image
var imagem_nevoa: Image
var textura_final: ImageTexture
var atlas_textura: AtlasTexture

const Raio_Visao = 10

# --- CONFIGURAÇÕES DINÂMICAS DE ZOOM ---
var tamanho_do_zoom: float = 32.0  # Começa com 32 tiles visíveis
const ZOOM_MINIMO: float = 24.0    # Máximo de zoom aproximado (perto)
const ZOOM_MAXIMO: float = 400.0   # Máximo de zoom afastado (longe)
const VELOCIDADE_ZOOM: float = 4.0  # Quantos tiles mudam por clique no scroll

var tela_cheia: bool = false
var tamanho_original: Vector2
var posicao_original: Vector2

# --- CONTROLE DA CÂMERA E ARRASTO ---
var arrastando: bool = false
var centro_camera: Vector2 = Vector2.ZERO
var usando_camera_manual: bool = false
var ultima_posicao_mouse: Vector2 = Vector2.ZERO

func _ready() -> void:
	if get_parent() and get_parent().get_parent() and "Map_chunks_x" in get_parent().get_parent():
		Map_chunks_x = get_parent().get_parent().Map_chunks_x
		Map_chunks_y = get_parent().get_parent().Map_chunks_y

	map_width = Map_chunks_x * CHUNK_SIZE
	map_length = Map_chunks_y * CHUNK_SIZE
	
	tamanho_original = size
	posicao_original = position
	
	image_mapa = Image.create(map_width, map_length, false, Image.FORMAT_RGBA8)
	image_mapa.fill(cor_nevoa)
	
	imagem_nevoa = Image.create(map_width, map_length, false, Image.FORMAT_RGBA8)
	imagem_nevoa.fill(Color(0,0,0,1))
	
	textura_final = ImageTexture.create_from_image(image_mapa)
	
	atlas_textura = AtlasTexture.new()
	atlas_textura.atlas = textura_final
	texture = atlas_textura
	
	# Inicializa o centro da câmera no meio do mapa
	centro_camera = Vector2(map_width / 2.0, map_length / 2.0)
	
	atualizar_minimapa_visual(Vector2i(-1, -1))

# --- CAPTURANDO SCROLL E ARRASTO (MÉTODO GUI) ---
func _gui_input(event: InputEvent) -> void:
	# 1. CAPTURA DO SCROLL DO MOUSE (ZOOM)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Scroll para cima: Aproxima a câmera (diminui a área visível)
			tamanho_do_zoom = clampf(tamanho_do_zoom - VELOCIDADE_ZOOM, ZOOM_MINIMO, min(ZOOM_MAXIMO, map_width))
			_forcar_update_com_player()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Scroll para baixo: Afasta a câmera (aumenta a área visível)
			tamanho_do_zoom = clampf(tamanho_do_zoom + VELOCIDADE_ZOOM, ZOOM_MINIMO, min(ZOOM_MAXIMO, map_width))
			_forcar_update_com_player()

		# 2. CAPTURA DO CLIQUE PARA ARRASTAR
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				arrastando = true
				usando_camera_manual = true
				ultima_posicao_mouse = event.position
			else:
				arrastando = false

	# 3. MOVIMENTO DO ARRASTO (PAN)
	if event is InputEventMouseMotion and arrastando:
		# Calcula quanto o mouse andou em pixels na tela
		var delta_mouse = event.position - ultima_posicao_mouse
		ultima_posicao_mouse = event.position
		
		# Converte o movimento de pixels da tela para proporção de tiles baseada no zoom atual
		var pixels_por_tile_x = size.x / tamanho_do_zoom
		var pixels_por_tile_y = size.y / tamanho_do_zoom
		
		# Movemos a câmera na direção oposta do arrasto para dar a sensação natural de puxar o mapa
		centro_camera.x -= delta_mouse.x / pixels_por_tile_x
		centro_camera.y -= delta_mouse.y / pixels_por_tile_y

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Abrir"):
		alternar_tela_cheia()
		
	if event.is_action_pressed("Fechar"):
		if tela_cheia:
			alternar_tela_cheia()
		visible = not visible
	if event.is_action_pressed("Zoom_Back"):
		usando_camera_manual = false 
		_forcar_update_com_player()

func alternar_tela_cheia() -> void:
	tela_cheia = not tela_cheia
	usando_camera_manual = false # Reseta a câmera para focar no player ao mudar de modo
	
	if tela_cheia:
		expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		stretch_mode = TextureRect.STRETCH_SCALE
		var tamanho_da_tela = get_viewport_rect().size
		var tamanho_mapa_grande = min(tamanho_da_tela.x, tamanho_da_tela.y) * 0.8
		size = Vector2(tamanho_mapa_grande, tamanho_mapa_grande)
		position = (tamanho_da_tela / 2) - (size / 2)
	else:
		size = tamanho_original
		position = posicao_original
		tamanho_do_zoom = 32.0
		
		if get_parent().get_parent().player_instanciado != null:
			var p_node = get_parent().get_parent().player_instanciado
			var tm_node = get_parent().get_parent().tile_map_layer
			var player_tile = tm_node.local_to_map(tm_node.to_local(p_node.global_position))
			centro_camera.x = player_tile.x
			centro_camera.y = player_tile.y
	
	_forcar_update_com_player()

func _forcar_update_com_player() -> void:
	if get_parent().get_parent().player_instanciado != null:
		var p_node = get_parent().get_parent().player_instanciado
		var tm_node = get_parent().get_parent().tile_map_layer
		var player_tile = tm_node.local_to_map(tm_node.to_local(p_node.global_position))
		atualizar_minimapa_visual(player_tile)

func registrar_pixel(x: int, y: int, tipo: String) -> void:
	var cor = cor_grama
	match tipo:
		"arvore": cor = cor_arvore
		"pedra": cor = cor_pedra
		"grama": cor = cor_grama
		"saida": cor = Color(1, 0.8, 0, 1)
	image_mapa.set_pixel(x, y, cor)

func remover_do_mapa(x: int, y: int) -> void:
	image_mapa.set_pixel(x, y, cor_grama)
	atualizar_minimapa_visual(Vector2i(-1, -1))

func atualizar_minimapa_visual(player_tile_pos: Vector2i) -> void:
	var exibicao: Image = Image.create(map_width, map_length, false, Image.FORMAT_RGBA8)
	
	# 1. Revela a névoa ao redor do jogador
	if player_tile_pos.x >= 0 and player_tile_pos.x < map_width and player_tile_pos.y >= 0 and player_tile_pos.y < map_length:
		for tx in range(player_tile_pos.x - Raio_Visao, player_tile_pos.x + Raio_Visao + 1):
			for ty in range(player_tile_pos.y - Raio_Visao, player_tile_pos.y + Raio_Visao + 1):
				if tx >= 0 and tx < map_width and ty >= 0 and ty < map_length:
					if Vector2(player_tile_pos).distance_to(Vector2(tx, ty)) <= Raio_Visao:
						imagem_nevoa.set_pixel(tx, ty, Color(1, 1, 1, 1))
	
	# 2. Desenha o mapa e a névoa
	for x in range(map_width):
		for y in range(map_length):
			var n = imagem_nevoa.get_pixel(x, y).r
			if n > 0.5:
				exibicao.set_pixel(x, y, image_mapa.get_pixel(x, y))
			else:
				exibicao.set_pixel(x, y, cor_nevoa)
				
	# 3. Desenha o jogador
	if player_tile_pos.x >= 0 and player_tile_pos.x < map_width and player_tile_pos.y >= 0 and player_tile_pos.y < map_length:
		exibicao.set_pixel(player_tile_pos.x, player_tile_pos.y, cor_player)
	
	textura_final.update(exibicao)
	
	if not usando_camera_manual and player_tile_pos.x >= 0:
		centro_camera.x = player_tile_pos.x
		centro_camera.y = player_tile_pos.y
	
	# Aplica o corte final na imagem baseado no tamanho_do_zoom dinâmico do Scroll
	var cant_x = centro_camera.x - (tamanho_do_zoom / 2.0)
	var cant_y = centro_camera.y - (tamanho_do_zoom / 2.0)
	
	# Garante que a câmera não saia das bordas do mapa gerado
	cant_x = clampf(cant_x, 0.0, max(0.0, map_width - tamanho_do_zoom))
	cant_y = clampf(cant_y, 0.0, max(0.0, map_length - tamanho_do_zoom))
	
	# Atualiza a região visível do nosso AtlasTexture
	atlas_textura.region = Rect2(cant_x, cant_y, tamanho_do_zoom, tamanho_do_zoom)
