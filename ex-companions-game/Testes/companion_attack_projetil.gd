extends AnimatedSprite2D



var attack_name : String
var target = PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	desativar_colisoes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if attack_name and target:
		lancar_projetil(attack_name, target)

func lancar_projetil(name, target):
	match name:
		"raio_psiquico":
			$colisoes/raio_psiquico.disabled = false
			raio_psiquico(target)

		"bola_de_fogo":
			pass

func raio_psiquico(target, speed = 20):
	$".".play("attack_02")
	
	
func boa_de_fogo():
	pass

func desativar_colisoes():
	for c in $colisoes.get_children():
		c.disabled = true

func configurar_ataque(name, target_scn):
	attack_name = name
	target = target_scn

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
