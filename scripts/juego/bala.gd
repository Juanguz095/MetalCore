extends Area2D

var velocidad = 600 
var direccion = 1
var tiempoVida = 0.0

var coloresEnergia = [Color("#00f0ff"), Color("#ffea00"), Color("#ffffff")]
var indiceColor = 0
var tiempoCambioColor = 0.0

var esCargada = false
var multiplicadorEscala = 1.0

@onready var sprite = $Sprite2D 

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if esCargada:
		multiplicadorEscala = 2.5 
		velocidad = 900
		coloresEnergia = [Color("#00ff66"), Color("4fefedff"), Color("#ffffff")]
	else:
		multiplicadorEscala = 1.0
		
	scale = Vector2(0.4, 0.4) * multiplicadorEscala
	modulate = coloresEnergia[0]

func _process(delta: float) -> void:
	position.x += velocidad * direccion * delta
	tiempoVida += delta
	tiempoCambioColor += delta
	
	var velocidad_parpadeo = 0.02 if esCargada else 0.05
	if tiempoCambioColor >= velocidad_parpadeo:
		tiempoCambioColor = 0.0
		indiceColor = (indiceColor + 1) % coloresEnergia.size()
		modulate = coloresEnergia[indiceColor]
	
	var escala_objetivo = 1.0 * multiplicadorEscala
	if scale.x < escala_objetivo * 1.2:
		scale += Vector2(8.0, 8.0) * multiplicadorEscala * delta
	elif scale.x > escala_objetivo:
		scale = Vector2(escala_objetivo, escala_objetivo)
	
	scale.y = escala_objetivo + (sin(tiempoVida * 50.0) * (0.2 * multiplicadorEscala))
	
	if tiempoVida > 2.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		return
		
	if body.has_method("morir"):
		body.morir()
		crearEfectoImpacto()
	elif body.name != "Jugador" and not body is Area2D:
		crearEfectoImpacto()

func crearEfectoImpacto():
	velocidad = 0
	disconnect("body_entered", _on_body_entered)
	
	modulate = Color("#ffaa00") if esCargada else Color("#ff3300")
	
	var tween = create_tween().set_parallel(true)
	var escala_explosion = 3.5 if esCargada else 1.8
	tween.tween_property(self, "scale", Vector2(escala_explosion, escala_explosion), 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	
	await tween.finished
	queue_free()
