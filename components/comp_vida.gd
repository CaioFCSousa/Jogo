extends Node
class_name comp_Vida

"""
componete de vida.
é necessario apenas por isso dentro da entidade que ela terá um sistema de vida apenas isso.
ela receberar uma informação do atacante quanto ela recebeu de dano e calculará quanto tomou de dano,
creio que essa parte podemos até mecher depois para ser algo mais dinamico e reutilizavel.
"""

@export_group("configuração da vida")
@export var vida_Maxima : float = 100.0
@export var vida_Minima : float = 0.0

# creio que depois pode adicionar umas variaveis de vida maxima e minima relativa

@export var vida : float = 100

@export var regeneracao : float = 1
@export var imortal : bool = false

signal sinal_morreu

func tomar_dano(valor : float):
	vida = vida - valor
	print("tomei %f de dano, minha viada agora é %f" % [valor, vida])
	if vida <= vida_Minima:
		sinal_morreu.emit()
