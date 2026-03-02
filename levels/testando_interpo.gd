extends Sprite2D
@export var curva : Curve
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var besta = $Icon2

var velocidade = 2
var t = 0
var mouse_pos : Vector2 = Vector2.ZERO
var novaPosi : Vector2
func _process(delta: float) -> void:
	t += delta
	if t >= 2:
		novaPosi = get_global_mouse_position()
		t = 0
		aprox(besta.global_position, novaPosi, t)

func aprox(posi_atual : Vector2, posi_final : Vector2, t):
	var distancia = posi_atual.distance_to(posi_final)
	var bah = 1 / distancia
	print("%f\n%f"%[distancia,bah])
	besta.global_position = get_local_mouse_position()
