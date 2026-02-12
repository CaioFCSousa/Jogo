extends Area2D
class_name comp_hurtbox

# debug
var texto_debug : Label 

@export var vida : Vida_Comp
# futura implementação irá somar todo o dano além de verificar quem tem prioridade baseado na chegada
var hitbox_em_contato : Array[Area2D] # Mudamos temporariamente para Area2D para evitar travar o script se a classe sumir

signal dano_recebido(dano : float)

func _ready() -> void:
	# automaticamante puxa um texto de debugg se nn tiver ele simplemente ignora esse passo
	if find_child("texto_debug"):
		texto_debug = $texto_debug
	
	# conecta alguns simais (Sintaxe Godot 4)
	area_entered.connect(_na_area_entrada)
	area_exited.connect(_na_area_saiu)

func _dano_total() -> float:
	var valor : float = 0.0
	for hitbox in hitbox_em_contato:
		if hitbox.has_method("get_dano"): # Verificação de segurança opcional
			valor += hitbox.dano
		elif "dano" in hitbox: # Verifica se a variável existe
			valor += hitbox.dano
	return valor

# função que verifica quem é hitbox e só aceita se for diferente // pelo visto só é verificado caso seja do tipo hitbox
func _na_area_entrada(area: Area2D) -> void:
	# Verificando se a área que entrou é do tipo hitbox
	if area.is_class("Area2D") and area.get_script() and area.get_script().get_global_name() == &"comp_hitbox" or area is comp_hitbox:
		var hitbox = area
		# esqueci como esse if funciona mas ele basicamente verifica se a hitbox que entrou faz parte do dono dele se não passa pelo if
		if hitbox.get_parent() != get_parent():
			# adicona a hitbox ao array de hitboxs
			if not hitbox_em_contato.has(hitbox):
				hitbox_em_contato.append(hitbox)
		
		# Movido para dentro do if para garantir que 'hitbox' exista antes de acessar .dano
		atualizar_texto_debug([hitbox.dano, " ", hitbox_em_contato.size()])

# quando uma hitbox sai é avisado aqui e depois removido da lista mas acho que pode ser bugado isso aqui talvez precise
# trocar por .erase() no array mas temo que pese
func _na_area_saiu(area: Area2D):
	# Usamos a verificação genérica para evitar erros de compilação
	if area in hitbox_em_contato:
		# Trocado pop_back por erase para remover a hitbox exata que saiu. 
		# Não pesa tanto e evita bugs de remover o inimigo errado da lista!
		hitbox_em_contato.erase(area)
		atualizar_texto_debug(hitbox_em_contato)

# get and setters
# ia servir para quando ficar imortal mas depois serviu para nada mas ta ai se precisar
func _set_monitorar(valor : bool):
	monitoring = valor

# debug
func atualizar_texto_debug(valor : Array):
	if texto_debug:
		var texto : String = ''
		for x in valor:
			texto = texto + str(x)
		texto_debug.text = texto
