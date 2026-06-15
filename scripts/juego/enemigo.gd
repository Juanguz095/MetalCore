extends CharacterBody2D

const velocidad = 100.0
var jugador = null
var persiguiendo = false

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):
	if persiguiendo and jugador != null:
		var direccion = jugador.global_position - global_position
		direccion = direccion.normalized()
		velocity = direccion * velocidad
		sprite.flip_h = velocity.x < 0
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto = colision.get_collider()
		if objeto.is_in_group("jugador") and objeto.has_method("recibirDanio"):
			objeto.recibirDanio()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		jugador = body
		persiguiendo = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		persiguiendo = false
		jugador = null

func morir():
	remove_from_group("enemigos")
	var nodo_jugador = get_tree().get_first_node_in_group("jugador")
	if nodo_jugador and nodo_jugador.has_method("sumarPuntos"):
		nodo_jugador.sumarPuntos(20)
		
	queue_free()
