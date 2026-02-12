extends Sprite2D

var t = 0
var posicOG : Vector2
@export var velocidade : float = 1
@export var quanto : float = 10

func _ready() -> void:
	posicOG = position

func _process(delta: float) -> void:
	t += delta
	var vx = sin(t*velocidade)*quanto
	# var vy = sin(t*velocidade)*quanto 
	position = Vector2( vx + posicOG.x , posicOG.y )
