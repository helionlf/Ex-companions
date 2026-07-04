extends StaticBody2D


const Cena_Galinha = preload("res://Scenes/enemy.tscn") 

var inimigos_vivos: Array = []
var max_inimigos = 3
var raio_spawn: float = 100.0

func _ready() -> void:
	# Criamos um temporizador via código para rodar a cada 10 segundos
	var timer = Timer.new()
	timer.wait_time = 4.0
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _on_timer_timeout() -> void:
	# 1. Limpa a lista removendo inimigos que já foram derrotados/deletados do jogo
	inimigos_vivos = inimigos_vivos.filter(func(inimigo): return is_instance_valid(inimigo))
	
	# 2. Se tiver menos de 3 vivos, spawna um novo
	if inimigos_vivos.size() < max_inimigos:
		spawnar_inimigo()

func spawnar_inimigo() -> void:
	var inimigo = Cena_Galinha.instantiate()
	
	# Sorteia uma posição aleatória entre -10 e 10 pixels de distância do spawner
	var offset_x = randf_range(-raio_spawn, raio_spawn)
	var offset_y = randf_range(-raio_spawn, raio_spawn)
	
	# Adicionamos o inimigo no "Pai" do spawner (o container de objetos) 
	# para ele não ficar preso ao spawner e poder andar pelo mapa
	get_parent().add_child(inimigo)
	
	# Define a posição do inimigo somando a posição do spawner + o offset sorteado
	inimigo.global_position = global_position + Vector2(offset_x, offset_y)
	
	# Registra que esse inimigo está vivo
	inimigos_vivos.append(inimigo)
