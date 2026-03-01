extends HBoxContainer
class_name Barra_de_vida

@export var vida_max : int = 5
@export var vida_atual : int
@export var textura_vidaCheia : Texture2D
@export var textura_vidaVazia : Texture2D
@export var valor_separacao : int = 1
var coracoes : Array[TextureRect]
var quantidade_suportada : int
var vida_passada : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vida_atual = clamp(vida_atual,0,vida_max)
	vida_passada = vida_atual
	quantidade_suportada = size.x / textura_vidaCheia.get_width()
	print("%s %s %s %s" % [quantidade_suportada, textura_vidaCheia.get_width(), size.x, quantidade_suportada * textura_vidaCheia.get_width() < size.x])
	if quantidade_suportada * (textura_vidaCheia.get_width()+valor_separacao) > size.x:
		print("tamanho da barra pequena demais! ajuste para o tamanho: %d*(%d+%d)=%d" % [vida_max,textura_vidaCheia.get_width(),valor_separacao,vida_max *(valor_separacao + textura_vidaCheia.get_width())])
	
	for cora in get_children():
		coracoes.append(cora)
	
	if coracoes.size() < vida_atual:
		for x in range(coracoes.size(),vida_atual):
			# print("adciconando mais um coração ", coracoes.size())
			var novo_coracao = TextureRect.new()
			novo_coracao.texture = textura_vidaCheia
			novo_coracao.name = coracoes[0].name +" "+ str(x)
			coracoes.append(novo_coracao)
			add_child(novo_coracao)
		pass
	
	atualizar()
	pass # Replace with function body.

func atualizar():
	print("vida atual: %d\nvida passada: %d\ndif: %d" % [vida_atual, vida_passada , vida_atual-vida_passada])
	var dif = clamp(vida_max - vida_atual,0 ,vida_max)
	
	if vida_atual - vida_passada >= 1:
		print("ui")
		for x in vida_atual:
			print(coracoes[x])
			coracoes[x].texture = textura_vidaCheia
		pass
	else:
		for x in dif:
			coracoes[-(x+1)].texture = textura_vidaVazia
			pass
	
	vida_passada = vida_atual


func _on_button_button_down() -> void:
	vida_atual -= 1
	vida_atual = clamp(vida_atual, 0, vida_max)
	atualizar()
	pass # Replace with function body.


func _on_button_2_button_down() -> void:
	vida_atual += 1
	vida_atual = clamp(vida_atual, 0, vida_max)
	atualizar()
	pass # Replace with function body.
