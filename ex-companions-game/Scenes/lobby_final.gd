extends Node2D

# 1. Carrega a cena do Player (ajuste o caminho se a sua pasta for diferente)
const PLAYER_SCENE = preload("res://Scenes/player.tscn")

var player_na_area: bool = false
var player_troca: bool = false

# 2. Referência ao nó Marker2D
@onready var spawn_point: Marker2D = $Marker2D

func _ready() -> void:
	spawn_player()

func spawn_player() -> void:
	if PLAYER_SCENE and spawn_point:
		# Instancia o Player
		var player_instancia = PLAYER_SCENE.instantiate()
		
		# Adiciona como filho do Lobby
		add_child(player_instancia)
		
		# Move o Player para a coordenada global exata do Marker2D
		player_instancia.global_position = spawn_point.global_position
		print("Player spawnado com sucesso na posição: ", spawn_point.global_position)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_na_area = true
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_na_area = false
		$StaticBody2D/Area2D/Upgrade.visible = false
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interagir") and player_na_area:
		$StaticBody2D/Area2D/Upgrade.visible = not $StaticBody2D/Area2D/Upgrade.visible
		
	if event.is_action_pressed("Interagir") and player_troca:
		get_tree().change_scene_to_file("res://Scenes/MapaProceduralTeste.tscn")


func _on_entrada_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_troca = true


func _on_entrada_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_troca = false
