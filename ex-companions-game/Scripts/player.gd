extends CharacterBody2D


@export var speed = 100.0
@export var health = 5

@export var projetil: PackedScene

func _physics_process(_delta: float) -> void:
	handle_velocity()
	move_and_slide()

func attack():
	print("jogador atacou")

func take_damage(amount):
	print("jogador tomou dano")
	health -= amount

func handle_velocity():
	var input := Vector2.ZERO
	input = Input.get_vector("walk_feft", "walk_right", "walk_up", "walk_down")

	velocity = input * speed

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		disparar_projetil()

func disparar_projetil():
	if projetil == null:
		return
	
	var novo_projetil = projetil.instantiate()
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position)
	get_tree().root.add_child(novo_projetil)
	novo_projetil.iniciar(global_position, direction)
