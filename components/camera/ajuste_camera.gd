extends Node2D

@export_group("Alvos")
@export var alvo1 : Node2D
@export var alvo2 : Node2D

@export_group("Configurações")
@export var suavidade : float = 0.05
@export var altura_extra : float = -75.0 # Ajuste aqui para subir a visão

func _process(_delta: float) -> void:
	# Verifica se os jogadores foram arrastados para o Inspetor
	if not alvo1 or not alvo2:
		return
	
	# 1. Calcula o centro entre os dois jogadores
	var centro = (alvo1.global_position + alvo2.global_position) / 2
	
	# 2. Sobe o ponto de visão (Y negativo sobe)
	centro.y += altura_extra 
	
	# 3. Move este NÓ DE PONTO suavemente até o centro
	# Como a Camera2D é filha deste nó, ela vai junto!
	global_position = global_position.lerp(centro, suavidade)
