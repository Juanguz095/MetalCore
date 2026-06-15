extends TextureRect

var frames: Array = []
var frameActual: int = 0
var fps: float = 12.0

func _ready():
	custom_minimum_size = Vector2(80, 80)
	size = Vector2(80, 80)
	
	for i in range(0, 189): 
		var path = "res://assets/gato/frame_%03d_delay-0.03s.png" % i
		if ResourceLoader.exists(path):
			frames.append(load(path))
	
	print("Frames cargados: ", frames.size()) 
	
	if frames.size() > 0:
		_animar()

func _animar():
	if frames.size() == 0:
		return
	texture = frames[frameActual]
	frameActual = (frameActual + 1) % frames.size()
	await get_tree().create_timer(1.0 / fps).timeout
	_animar()
