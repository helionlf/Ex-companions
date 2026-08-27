extends AnimatedSprite2D


var attack_name : String
var target : CharacterBody2D
var speed : int
var direction: Vector2

func _ready() -> void:
	choose_projetil()

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
			$colisoes/hitbox/raio_psiquico.disabled = false
			raio_psiquico()

		"bola_de_fogo":
			#nome fiquiticio. terá um case para cada ataque
			$colisoes/hitbox2/bolade_fogo.disabled = false

func raio_psiquico():
	$".".play("attack_02")
	set_angle_projetil()
	#se tiver mais coisas alem de animação
	
func boa_de_fogo():
	pass

func configurar_ataque(attack_name_, target_, speed_):
	attack_name = attack_name_
	target = target_
	speed = speed_
	
	direction = global_position.direction_to(target.global_position)

func set_angle_projetil():
	rotation = global_position.angle_to_point(target.global_position)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Companion") or area.get_parent().is_in_group("Player"):
		return
	queue_free()
