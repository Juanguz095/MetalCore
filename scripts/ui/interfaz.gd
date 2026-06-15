extends Control

@onready var nombreLabel = $HBoxContainer/VBoxContainer/Dialogos/ScrollContainer/VBoxContainer/NombreLabel
@onready var textoLabel = $HBoxContainer/VBoxContainer/Dialogos/ScrollContainer/VBoxContainer/TextoLabel
@onready var opcionesContainer = $HBoxContainer/VBoxContainer/Dialogos/ScrollContainer/VBoxContainer/OpcionesContainer
@onready var accionesContainer = $HBoxContainer/VBoxContainer3/HBoxContainer/HBoxContainer4/Panel/ScrollContainer/VBoxContainer/AccionesContainer
@onready var escenaImg = $HBoxContainer/VBoxContainer/Escena/TextureRect

var ubicacionActual = "apartamento"
var diaActual = 1
var animandoTexto = false
var accionSeleccionada = -1
var tweenActivo: Tween = null
var opcionesActualesCache: Array = []

signal accionElegida(nombre: String)
signal opcionElegida(indice: int)

var ubicaciones = {
	"apartamento": {
		"imagen": "res://assets/fondos/apartamento.png",
		"acciones": ["IR AL BAR EL LIMBO", "MERCADO NEGRO", "DESCANSAR (DÍA SIGUIENTE)"],
		"dialogo": {
			"nombre": "...",
			"texto": "El dinero no cae del cielo",
			"opciones": []
		}
	},
	"bar": {
		"imagen": "res://assets/fondos/bar.png",
		"acciones": ["HABLAR CON PERSONAJES", "IR AL APARTAMENTO"],
		"dialogo": {
			"nombre": "BROKER",
			"texto": "Tienes suerte de seguir vivo. No todos aguantan tanto como tú.\nAquí tienes el trabajo de hoy. Fácil, rápido y bien pagado.\nNo preguntes demasiado.",
			"opciones": ["Aceptar contrato", "Preguntar detalles", "Rechazar", "Cambiar de tema"]
		}
	},
	"mercado": {
		"imagen": "res://assets/fondos/mercado.png",
		"acciones": ["IR AL APARTAMENTO", "IR AL BAR EL LIMBO"],
		"dialogo": {
			"nombre": "VENDEDOR",
			"texto": "Psst. Tengo de todo. Medicinas, datos, lo que necesites.\nPero nada es gratis por aquí.",
			"opciones": ["Ver mercancía", "Preguntar por info", "Irse"]
		}
	},
}

var respuestas = {
	# Bar - Broker
	"Aceptar contrato": {
		"nombre": "BROKER",
		"texto": "Bien. El planeta KX-7. Tienes que mantenerte vivo 2 minutos en la superficie.\nLa extracción llega automáticamente. Solo... no mueras.",
		"opciones": ["Ir a la misión", "Necesito más info"]
	},
	"Preguntar detalles": {
		"nombre": "BROKER",
		"texto": "Un planeta hostil. Dos minutos. Extracción automática.\n¿Qué más necesitas saber?",
		"opciones": ["Aceptar contrato", "Rechazar"]
	},
	"Rechazar": {
		"nombre": "BROKER",
		"texto": "Tu pérdida. Otro lo hará.",
		"opciones": []
	},
	"Cambiar de tema": {
		"nombre": "BROKER",
		"texto": "No tengo tiempo para charlas.",
		"opciones": []
	},
	"Necesito más info": {
		"nombre": "BROKER",
		"texto": "KX-7 tiene fauna agresiva y tormentas de ácido.\nTienes un escudo de emergencia. Úsalo bien.\nDos minutos. Sobrevive y cobras.",
		"opciones": ["Ir a la misión", "Rechazar"]
	},
	"Ir a la misión": {
		"nombre": "...",
		"texto": "Te preparas. La cápsula de descenso te espera.\nDos minutos. Solo dos minutos.",
		"opciones": ["_INICIAR_MISION_"]
	},
	# Bar - Personajes
	"Hablar con él": {
		"nombre": "RATA",
		"texto": "Oye... ¿vas a KX-7?\nConozco gente que no volvió de ahí. Ten cuidado.",
		"opciones": ["Ignorar"]
	},
	"Ignorar": {
		"nombre": "...",
		"texto": "Sigues tu camino.",
		"opciones": []
	},
	# Mercado
	"Ver mercancía": {
		"nombre": "VENDEDOR",
		"texto": "Tengo medicinas, munición y algo más... por el precio correcto.",
		"opciones": ["Comprar", "Irse"]
	},
	"Preguntar por info": {
		"nombre": "VENDEDOR",
		"texto": "Info cuesta el doble. ¿Tienes créditos?",
		"opciones": ["Pagar", "Irse"]
	},
	"Irse": {
		"nombre": "...",
		"texto": "Te alejas sin decir nada.",
		"opciones": []
	},
	"Comprar": {
		"nombre": "VENDEDOR",
		"texto": "Buen negocio.",
		"opciones": []
	},
	"Pagar": {
		"nombre": "VENDEDOR",
		"texto": "Escucha bien porque no lo repito.",
		"opciones": []
	},
}

func _ready():
	nombreLabel.add_theme_font_size_override("font_size", 6)
	nombreLabel.add_theme_color_override("font_color", Color("#d4379a"))
	nombreLabel.custom_minimum_size = Vector2(0, 10)
	textoLabel.add_theme_font_size_override("font_size", 6)
	textoLabel.custom_minimum_size = Vector2(0, 30)
	opcionesContainer.add_theme_constant_override("separation", 4)
	_irUbicacion("apartamento")

func _irUbicacion(ubicacion: String):
	ubicacionActual = ubicacion
	accionSeleccionada = -1
	_cambiarImagen(ubicaciones[ubicacion]["imagen"])
	_renderizarAcciones()
	var d = ubicaciones[ubicacion]["dialogo"]
	mostrarDialogo(d["nombre"], d["texto"], d["opciones"])

func _cambiarImagen(ruta: String):
	if ResourceLoader.exists(ruta):
		escenaImg.texture = load(ruta)

func _onAccionSeleccionada(indice: int):
	var acciones = ubicaciones[ubicacionActual]["acciones"]
	var accion = acciones[indice]
	accionSeleccionada = indice
	_renderizarAcciones()

	match accion:
		"IR AL BAR EL LIMBO":        _irUbicacion("bar")
		"IR AL APARTAMENTO":         _irUbicacion("apartamento")
		"MERCADO NEGRO":             _irUbicacion("mercado")
		"DESCANSAR (DÍA SIGUIENTE)":
			diaActual += 1
			mostrarDialogo("...", "Día %d. El ciclo continúa." % diaActual, [])
		"HABLAR CON PERSONAJES":
			mostrarDialogo("DESCONOCIDO", "Hay un tipo en la esquina. Parece que te conoce.", ["Hablar con él", "Ignorar"])
		_:
			emit_signal("accionElegida", accion)

func _renderizarAcciones():
	for hijo in accionesContainer.get_children():
		hijo.queue_free()
	var acciones = ubicaciones.get(ubicacionActual, {}).get("acciones", [])
	for i in acciones.size():
		var btn = Button.new()
		btn.text = ("  " if i != accionSeleccionada else " ") + acciones[i]
		btn.flat = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 4)
		btn.custom_minimum_size = Vector2(0, 9)
		btn.focus_mode = Control.FOCUS_NONE
		var transparente = StyleBoxFlat.new()
		transparente.bg_color = Color(0, 0, 0, 0)
		transparente.draw_center = false
		btn.add_theme_stylebox_override("normal", transparente)
		btn.add_theme_stylebox_override("hover", transparente)
		btn.add_theme_stylebox_override("pressed", transparente)
		btn.add_theme_stylebox_override("focus", transparente)
		btn.add_theme_color_override("font_color", Color("#d4379a") if i == accionSeleccionada else Color("#c8c8d4"))
		btn.add_theme_color_override("font_hover_color", Color("#e05cb0"))
		btn.pressed.connect(_onAccionSeleccionada.bind(i))
		accionesContainer.add_child(btn)

func mostrarDialogo(nombre: String, texto: String, opciones: Array):
	nombreLabel.text = nombre
	textoLabel.text = ""
	_limpiarOpciones()
	await _animarTexto(texto)
	opcionesActualesCache = opciones
	_mostrarOpciones(opciones)

func _animarTexto(texto: String):
	if tweenActivo != null:
		tweenActivo.kill()
	animandoTexto = true
	tweenActivo = create_tween()
	for i in range(texto.length() + 1):
		tweenActivo.tween_callback(textoLabel.set.bind("text", texto.substr(0, i)))
		tweenActivo.tween_interval(0.03)
	await tweenActivo.finished
	animandoTexto = false
	tweenActivo = null

func _mostrarOpciones(opciones: Array):
	for i in opciones.size():
		if opciones[i].begins_with("_"):
			continue
		_agregarOpcion(opciones[i], i)

func _limpiarOpciones():
	for hijo in opcionesContainer.get_children():
		hijo.queue_free()

func _agregarOpcion(texto_opcion: String, indice: int):
	var btn = Button.new()
	btn.text = "[" + texto_opcion + "]"
	btn.flat = true
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 6)
	btn.focus_mode = Control.FOCUS_NONE
	var transparente = StyleBoxFlat.new()
	transparente.bg_color = Color(0, 0, 0, 0)
	transparente.draw_center = false
	btn.add_theme_stylebox_override("normal", transparente)
	btn.add_theme_stylebox_override("hover", transparente)
	btn.add_theme_stylebox_override("pressed", transparente)
	btn.add_theme_stylebox_override("focus", transparente)
	btn.add_theme_color_override("font_color", Color("#c8c8d4"))
	btn.add_theme_color_override("font_hover_color", Color("#e05cb0"))
	btn.add_theme_color_override("font_focus_color", Color("#d4379a"))
	btn.pressed.connect(_onOpcionSeleccionada.bind(indice))
	opcionesContainer.add_child(btn)

func _onOpcionSeleccionada(indice: int):
	if indice >= opcionesActualesCache.size():
		return
	var opcion = opcionesActualesCache[indice]

	match opcion:
		"_INICIAR_MISION_", "Ir a la misión":
			get_tree().change_scene_to_file("res://escenas/juego/niveles/Nivel1.tscn")
			return

	if respuestas.has(opcion):
		var r = respuestas[opcion]
		mostrarDialogo(r["nombre"], r["texto"], r["opciones"])

	emit_signal("opcionElegida", indice)
