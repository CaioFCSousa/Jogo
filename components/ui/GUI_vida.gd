extends PanelContainer

@export var comp_vida : comp_Vida
var barra_vida : ProgressBar = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	barra_vida = $VBoxContainer/ProgressBar
	barra_vida.max_value = comp_vida.vida_Maxima
	barra_vida.min_value = comp_vida.vida_Minima
	pass # Replace with function body.

func _process(delta: float) -> void:
	barra_vida.value = comp_vida.vida
	pass
