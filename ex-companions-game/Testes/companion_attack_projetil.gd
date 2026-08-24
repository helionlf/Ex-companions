extends AnimatedSprite2D



var attack_name : String
var target : CharacterBody2D
var speed : int
var direction: Vector2

func _ready() -> void:
	desativar_colisoes()

func _process(delta: float) -> void:
	if target:
		position += direction * speed * delta

func choose_projetil():
	match attack_name:
		"raio_psiquico":
			$colisoes/raio_psiquico.disabled = false
			raio_psiquico()

		"bola_de_fogo":
			pass

func raio_psiquico():
	$".".play("attack_02")
	#se tiver mais coisas alem de animação
	
func boa_de_fogo():
	pass

func desativar_colisoes():
	for c in $colisoes.get_children():
		c.disabled = true

func configurar_ataque(ataque, target_scn, vel):
	attack_name = ataque
	target = target_scn
	speed = vel
	
	direction = global_position.direction_to(target.global_position)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
