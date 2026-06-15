# interfaz.gd
extends CanvasLayer

@onready var vidas_label = $HBoxContainer/Vidas
@onready var puntaje_label = $HBoxContainer/Puntaje

func actualizarPantalla(vidas: int, puntaje: int):
	vidas_label.text = "VIDAS: " + str(vidas)
	puntaje_label.text = "PUNTAJE: " + str(puntaje)
	
func _ready():
	vidas_label.add_theme_font_size_override("font_size", 12)
	vidas_label.add_theme_color_override("font_color", Color("#ffffff"))
	puntaje_label.add_theme_font_size_override("font_size", 12)
	puntaje_label.add_theme_color_override("font_color", Color("#d4379a"))
