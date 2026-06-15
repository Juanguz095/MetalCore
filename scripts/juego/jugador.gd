extends CharacterBody2D

signal interfazActualizada(vidas_restantes: int, puntaje_actual: int)

const velocidad = 200.0
const fuerzaSalto = -400.0
const aceleracion = 15.0 
const LIMITECAIDAY = 700.0 

var mirandoDerecha = true
var disparando = false
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

var escenaBala = preload("res://escenas/juego/Bala.tscn")

var vidas = 5
var puntaje = 0
var posicion_inicial : Vector2
var esInmune = false

var tiempoPresionado = 0.0
var cargando = false

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	posicion_inicial = global_position
	add_to_group("jugador")
	
	var interfaz = get_parent().get_node_or_null("Interfaz")
	if interfaz:
		interfazActualizada.connect(interfaz.actualizarPantalla)
	
	await get_tree().process_frame
	interfazActualizada.emit(vidas, puntaje)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
		
	if global_position.y > LIMITECAIDAY:
		caerAlVacio()
		return
		
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = fuerzaSalto
		
	if Input.is_action_pressed("disparar"):
		cargando = true
		tiempoPresionado += delta
	
	if Input.is_action_just_released("disparar"):
		disparando = true
		var bala = escenaBala.instantiate()
		
		if mirandoDerecha:
			$Marker2D.position.x = abs($Marker2D.position.x)
			bala.direccion = 1
		else:
			$Marker2D.position.x = -abs($Marker2D.position.x)
			bala.direccion = -1
			
		bala.global_position = $Marker2D.global_position
		
		if tiempoPresionado >= 1.0:
			bala.esCargada = true
		else:
			bala.esCargada = false
			
		get_tree().current_scene.add_child(bala)
		
		tiempoPresionado = 0.0
		cargando = false
		$TimerDisparo.start()
		
	var direccion = Input.get_axis("izquierda", "derecha")
	if direccion:
		if direccion > 0:
			mirandoDerecha = true
		else:
			mirandoDerecha = false
		velocity.x = move_toward(velocity.x, direccion * velocidad, aceleracion)
	else:
		velocity.x = move_toward(velocity.x, 0, aceleracion)
		
	move_and_slide()
	animaciones(direccion)

func animaciones(direccion):
	if direccion != 0:
		sprite.flip_h = direccion < 0
	if not is_on_floor():
		cambiarAnimacion("Saltar")
	elif disparando and direccion != 0:
		cambiarAnimacion("CorrerDisparando")
	elif disparando:
		cambiarAnimacion("Disparar")
	elif direccion != 0:
		cambiarAnimacion("Correr")
	else:
		cambiarAnimacion("Idle")

func cambiarAnimacion(nombreAnimacion):
	if sprite.animation != nombreAnimacion:
		sprite.play(nombreAnimacion)

func caerAlVacio():
	vidas -= 1
	interfazActualizada.emit(vidas, puntaje)
	velocity = Vector2.ZERO
	
	if vidas > 0:
		call_deferred("set_global_position", posicion_inicial)
		activarInmunidad()
	else:
		get_tree().call_deferred("reload_current_scene")

func recibirDanio():
	if esInmune:
		return
		
	vidas -= 1
	interfazActualizada.emit(vidas, puntaje)
	velocity = Vector2.ZERO
	if vidas > 0:
		call_deferred("set_global_position", posicion_inicial)
		activarInmunidad()
	else:
		get_tree().call_deferred("reload_current_scene")

func activarInmunidad():
	esInmune = true
	var tween = create_tween().set_loops(6)
	tween.tween_property(sprite, "modulate:a", 0.2, 0.12)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.12)
	await tween.finished
	esInmune = false

func sumarPuntos(cantidad):
	puntaje += cantidad
	interfazActualizada.emit(vidas, puntaje)

func _on_timer_disparo_timeout() -> void:
	disparando = false
