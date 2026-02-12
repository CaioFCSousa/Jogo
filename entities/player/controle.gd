extends Resource
class_name controle

@export var cima : InputEventAction
@export var baixo : InputEventAction
@export var direita : InputEventAction
@export var esquerda : InputEventAction 

func teste():
	print("os controles são: %s %s %s %s" % [cima.action, baixo.action, direita.action, esquerda.action])
