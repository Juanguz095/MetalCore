# interfaz.gd
extends CanvasLayer

const TIEMPO_MISION = 120.0

@onready var vidasLabel = $HBoxContainer/Vidas
@onready var puntajeLabel = $HBoxContainer/Puntaje
@onready var timerLabel = $HBoxContainer/Timer

var tiempoRestante: float = TIEMPO_MISION
var misionActiva: bool = true

func _ready():
	vidasLabel.add_theme_font_size_override("font_size", 12)
	vidasLabel.add_theme_color_override("font_color", Color("#ffffff"))
	puntajeLabel.add_theme_font_size_override("font_size", 12)
	puntajeLabel.add_theme_color_override("font_color", Color("#d4379a"))
	timerLabel.add_theme_font_size_override("font_size", 12)
	timerLabel.add_theme_color_override("font_color", Color("#00f0ff"))

func _process(delta: float):
	if not misionActiva:
		return
	tiempoRestante = max(tiempoRestante - delta, 0.0)
	_actualizarTimer()
	if tiempoRestante <= 0.0:
		misionActiva = false
		_victoria()

func _actualizarTimer():
	var mins = int(tiempoRestante) / 60
	var segs = int(tiempoRestante) % 60
	timerLabel.text = "%01d:%02d" % [mins, segs]
	if tiempoRestante <= 30.0:
		timerLabel.add_theme_color_override("font_color", Color("#ff3300"))
	elif tiempoRestante <= 60.0:
		timerLabel.add_theme_color_override("font_color", Color("#ffea00"))

func actualizarPantalla(vidas: int, puntaje: int):
	vidasLabel.text = "VIDAS: " + str(vidas)
	puntajeLabel.text = "PUNTAJE: " + str(puntaje)

func _victoria():
	get_tree().paused = true

	var panel = ColorRect.new()
	panel.color = Color(0, 0, 0, 0.75)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -100
	vbox.offset_top = -40
	vbox.offset_right = 100
	vbox.offset_bottom = 40
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	var titulo = Label.new()
	titulo.text = "EXTRACCIÓN COMPLETADA"
	titulo.add_theme_font_size_override("font_size", 14)
	titulo.add_theme_color_override("font_color", Color("#d4379a"))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	var sub = Label.new()
	sub.text = "MC-01 sobrevivió el planeta bosque."
	sub.add_theme_font_size_override("font_size", 8)
	sub.add_theme_color_override("font_color", Color("#c8c8d4"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	var btn = Button.new()
	btn.text = "[ VOLVER A BASE ]"
	btn.flat = true
	btn.add_theme_font_size_override("font_size", 8)
	btn.add_theme_color_override("font_color", Color("#00f0ff"))
	btn.process_mode = Node.PROCESS_MODE_ALWAYS
	btn.pressed.connect(_volverABase)
	vbox.add_child(btn)

func _volverABase():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/ui/interfaz.tscn")
