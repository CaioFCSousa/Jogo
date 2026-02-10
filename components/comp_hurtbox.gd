extends Area2D
class_name comp_hurtbox

# debug
var texto_debug : Label 

@export var vida : Vida_Comp
var hitbox_em_contato : Array[comp_hitbox]


signal dano_recebido(dano : float)

func _ready() -> void:
	if find_child("texto_debug"):
		texto_debug = $texto_debug
	connect("area_entered", _na_area_entrada)
	connect("area_exited", _na_area_saiu)

func verificar_dano():
	pass

func _na_area_entrada(hitbox : comp_hitbox)-> void:
	if hitbox.get_parent() != get_parent():
		hitbox_em_contato.append(hitbox)
		vida.tomar_dano(hitbox.dano)
	atualizar_texto_debug([hitbox.dano, " ", hitbox_em_contato])

func _na_area_saiu(hitbox : comp_hitbox):
	hitbox_em_contato.pop_back()
	atualizar_texto_debug(hitbox_em_contato)
	pass

func _set_monitorar(valor : bool):
	monitoring = valor
	pass

func atualizar_texto_debug(valor : Array):
	if texto_debug != null:
		var texto : String = ''
		for x in valor:
			texto = texto + str(x)
		texto_debug.text = texto
