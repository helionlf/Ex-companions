extends CharacterBody2D

@export var speed = 100.0
@export var health = 999
@export var projetil_scene: PackedScene 

var can_attack: bool = true
var attack_cooldown: float = 0.5 
var attack_cooldown_minimo: float = 0.1

func _ready() -> void:
	add_to_group("Player")
	# 1. Carrega o status salvo no Autoload assim que o Player nasce na cena
	attack_cooldown = InventarioGlobal.player_attack_cooldown


func _physics_process(_delta: float) -> void:
	handle_input()
	move_and_slide()
	death()

func attack():
	if not can_attack:
		return
		
	can_attack = false
	
	if projetil_scene:
		var projetil = projetil_scene.instantiate()
		projetil.global_position = global_position
		get_tree().current_scene.add_child(projetil)
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func melhorar_velocidade_ataque(valor: float) -> void:
	attack_cooldown = max(attack_cooldown_minimo, attack_cooldown - valor)
	# 2. Salva no Autoload para não perder ao mudar de cena!
	InventarioGlobal.player_attack_cooldown = attack_cooldown
	print("Novo tempo de recarga salvo: ", attack_cooldown)

func take_damage(amount):
	print(health)
	health -= amount
	if health <= 0:
		queue_free()

func death():
	if health <= 0:
		get_tree().change_scene_to_file("res://Scenes/lobby_final.tscn")

func handle_input():
	var input := Vector2.ZERO
	input = Input.get_vector("walk_feft", "walk_right", "walk_up", "walk_down")
	velocity = input * speed

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		attack()
