extends PanelContainer

@export var comp_vida : Vida_Comp
var barra : ProgressBar

func _ready() -> void:
	comp_vida.connect("vida_mudou", atualizar)
	barra = $VBoxContainer/ProgressBar
	barra.max_value = comp_vida.vida_Maxima
	barra.min_value = comp_vida.vida_Minima
	barra.value =comp_vida.vida

func atualizar()->void:
	barra.value =comp_vida.vida
	pass
