extends Node

@export var vida_comp : Vida_Comp
@export var tempo_imortal : Timer

func _ready() -> void:
	if vida_comp:
		vida_comp.connect("tomei_dano", imortal_ativar)
	else:
		print("falta atribuir vida")
	if tempo_imortal:
		tempo_imortal.connect("timeout", imortal_acabar)
	else:
		print("falta atribuir o tempo")

func imortal_ativar():
	print("fiquei imortal")
	vida_comp._set_imortal(true)
	tempo_imortal.start()
	pass

func imortal_acabar():
	print("cabo imortal")
	vida_comp._set_imortal(false)
	pass
