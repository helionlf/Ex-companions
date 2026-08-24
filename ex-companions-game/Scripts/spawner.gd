extends StaticBody2D

const Cena_Galinha = preload("res://Scenes/enemy.tscn")
const Cena_Boss = preload("res://Scenes/enemy_boss.tscn") # Carrega a cena do Boss

# 0.01 = 1% de chance (1 a cada 100)
@export var chance_boss: float = 0.9

var inimigos_vivos: Array = []
var max_inimigos = 3
var raio_spawn: float = 100.0

func _ready() -> void:
	# Criamos um temporizador via código para rodar a cada 4 segundos
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
	# Sorteia se vai ser o Boss (1%) ou Inimigo Comum (99%)
	var inimigo: Node2D = null
	if randf() < chance_boss:
		inimigo = Cena_Boss.instantiate()
		print("BOSS SPAWNADO!")
	else:
		inimigo = Cena_Galinha.instantiate()
	
	# Sorteia uma posição aleatória dentro do raio de spawn
	var offset_x = randf_range(-raio_spawn, raio_spawn)
	var offset_y = randf_range(-raio_spawn, raio_spawn)
	
	# Adicionamos o inimigo no nó pai do spawner
	get_parent().add_child(inimigo)
	
	# Define a posição
	inimigo.global_position = global_position + Vector2(offset_x, offset_y)
	
	# Registra na contagem de inimigos vivos
	inimigos_vivos.append(inimigo)
