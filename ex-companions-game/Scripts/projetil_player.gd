extends Area2D

var velocidade = 1000
var direcao = Vector2.RIGHT 

@onready var sprite_do_projetil = $AnimatedSprite2D


func iniciar(posicao_global_inicial: Vector2, direcao_inicial: Vector2):
	global_position = posicao_global_inicial
	direcao = direcao_inicial.normalized()
	
	if direcao.x < 0:
		sprite_do_projetil.flip_h = true
	else:
		sprite_do_projetil.flip_h = false


func _process(delta):
	position += direcao * velocidade * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
