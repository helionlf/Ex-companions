extends AnimatedSprite2D


var attack_name : String
var target : CharacterBody2D
var speed : int
var direction: Vector2

func _ready() -> void:
	desativar_colisoes()

func _process(delta: float) -> void:
	# cada if é uma lógica que execulta diferentes movimentações de projectil dependendo do ataque
	if target:
		if attack_name == "bola_de_fogo":
			direction = global_position.direction_to(target.global_position)
			look_at(target.position)
		
		# movimentação básica de movimento (em uma única direção)
		position += direction * speed * delta
		

func choose_projetil():
	match attack_name:
		"raio_psiquico":
			$colisoes/raio_psiquico.disabled = false
			raio_psiquico()

		"bola_de_fogo":
			#nome fiquiticio. terá um case para cada ataque
			pass

func raio_psiquico():
	$".".play("attack_02")
	set_angle_projetil()
	#se tiver mais coisas alem de animação
	
func boa_de_fogo():
	pass

func desativar_colisoes():
	for c in $colisoes.get_children():
		c.disabled = true

func configurar_ataque(attack_name_, target_, speed_):
	attack_name = attack_name_
	target = target_
	speed = speed_
	
	direction = global_position.direction_to(target.global_position)

func set_angle_projetil():
	rotation = global_position.angle_to_point(target.global_position)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
