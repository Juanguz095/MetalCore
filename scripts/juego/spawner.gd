extends Node

@export var escenaEnemigo: PackedScene
@export var intervalo: float = 3.0
@export var maxEnemigos: int = 5
@onready var puntos = $PuntosSpawn
var timer = 0.0

func _process(delta):
	timer += delta
	if timer >= intervalo:
		timer = 0.0
		_spawnear()

func _spawnear():
	if get_tree().get_nodes_in_group("enemigos").size() >= maxEnemigos:
		return
	
	var hijos = puntos.get_children()
	if hijos.is_empty():
		return
	
	var punto = hijos[randi() % hijos.size()]
	
	var enemigo = escenaEnemigo.instantiate()
	get_tree().current_scene.add_child(enemigo)
	enemigo.global_position = punto.global_position
	enemigo.add_to_group("enemigos")
