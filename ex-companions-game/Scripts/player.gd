extends CharacterBody2D


@export var speed = 500.0
@export var health = 5


func _physics_process(_delta: float) -> void:
	handle_input()
	move_and_slide()

func attack():
	print("jogador atacou")

func take_damage(amount):
	print("jogador tomou dano")
	health -= amount

func handle_input():
	var input := Vector2.ZERO
	input = Input.get_vector("walk_feft", "walk_right", "walk_up", "walk_down")

	velocity = input * speed
