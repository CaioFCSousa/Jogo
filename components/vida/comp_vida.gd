extends Node
class_name Vida_Comp

"""
07/02
componete de vida.
é necessario apenas por isso dentro da entidade que ela terá um sistema de vida apenas isso.
ela receberar uma informação do atacante quanto ela recebeu de dano e calculará quanto tomou de dano,
creio que essa parte podemos até mecher depois para ser algo mais dinamico e reutilizavel.

09/02
alguns comportamentos acho que podemos apenas adicionar como filho dentro do componete de vida,
tipo regeneraçao de vida vai ser um 'subcomponete' que vai ser ativo toda vez que vida mudar ou
tomar dano
"""

@export var dono : CharacterBody2D 
# vida que vai começar
@export var vida : float = 100

# max e min que a vida pode antigir
@export var vida_Maxima : float = 100.0
@export var vida_Minima : float = 0.0

@export var regeneracao : bool = false
@export var taxa_regen_segs : float = 1

@export var imortal : bool = false

var t : float = 0 # variavel de tempo para o process

# sinais que indicam se morreu e tomou dano para outros componetes saberem
signal morreu
signal tomei_dano
signal vida_mudou

func tomar_dano(valor : float):
	# se o valor do dano for negativo será atribuido 0 a ele
	if valor < 0:
		valor = 0
	
	# se estiver imortal nn toma dano
	if !imortal:
		_set_vida(vida - valor)
		tomei_dano.emit()
		
		#debug
		print("tomei %f de dano, minha vida agora é %f" % [valor, vida])
	else:
		#debug
		print("imortal")
	
	# indica aos outros que morreu
	if vida <= vida_Minima:
		morreu.emit()
		print("morri")
	vida_mudou.emit()

# função de curar a vida
func curar_toda_vida():
	_set_vida(vida_Maxima)

# get and setters
func _set_vida(valor : float):
	if vida != valor:
		vida = clamp(valor, vida_Minima, vida_Maxima)
		vida_mudou.emit()

func _get_vida() -> float:
	return vida

func _set_imortal(valor : bool):
	if valor != imortal:
		imortal = valor

func _get_imortal()->bool:
	return imortal
