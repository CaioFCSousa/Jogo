extends Area2D
class_name comp_hurtbox

# debug
var texto_debug : Label 

@export var vida : Vida_Comp
# futura implementação irá somar todo o dano além de verificar quem tem prioridade baseado na chegada
var hitbox_em_contato : Array[comp_hitbox]


signal dano_recebido(dano : float)

func _ready() -> void:
	# automaticamante puxa um texto de debugg se nn tiver ele simplemente ignora esse passo
	if find_child("texto_debug"):
		texto_debug = $texto_debug
	
	# conecta alguns simais
	connect("area_entered", _na_area_entrada)
	connect("area_exited", _na_area_saiu)

func verificar_dano():
	# futura implementação provalvemnte terei de mecher na "na area entrada"
	pass

# função que verifica quem é hitbox e só aceita se for diferente // pelo visto só é verificado caso seja do tipo hitbox
func _na_area_entrada(hitbox : comp_hitbox)-> void:
	# esqueci como esse if funciona mas ele basicamente verifica se a hitbox que entrou faz parte do dono dele se não passa pelo if
	if hitbox.get_parent() != get_parent():
		# adicona a hitbox ao array de hitboxs
		hitbox_em_contato.append(hitbox)
		# chama o comp de vida para tomar dano
		vida.tomar_dano(hitbox.dano)
		
	atualizar_texto_debug([hitbox.dano, " ", hitbox_em_contato])

# quando uma hitbox sai é avisado aqui e depois removido da lista mas acho que pode ser bugado isso aqui talvez precise
# trocar por .erase() no array mas temo que pese
func _na_area_saiu(hitbox : comp_hitbox):
	hitbox_em_contato.pop_back()
	atualizar_texto_debug(hitbox_em_contato)
	pass

# get and setters
# ia servir para quando ficar imortal mas depois serviu para nada mas ta ai se precisar
func _set_monitorar(valor : bool):
	monitoring = valor
	pass

# debug
func atualizar_texto_debug(valor : Array):
	if texto_debug:
		var texto : String = ''
		for x in valor:
			texto = texto + str(x)
		texto_debug.text = texto
