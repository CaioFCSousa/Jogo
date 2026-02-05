extends Node2D

"""
Resumo:
Apartir de dois pontos (alvo1 e alvo2), é calculado o ponto medio e depois
 é aplicado um deslocamneto relativo (offsetx, offsety) ao ponto medio,
depois é aplicado uma suavização 
"""

#organização de configurações agrupados
@export_group("alvos")
# cria dois nodes fantasmas para não dá erro
@export var alvo1 : Node2D = Node2D.new() 
@export var alvo2 : Node2D = Node2D.new()
# quando ativo mostra o icon deformado X com distancia e Y com zoom
@export var exibir_alvo : bool = false 

@export_group("configurações da camêra")
@export var offsetX = 0 # deslocamento relativo no eixo X
@export var offsetY = 0 # deslocamento relativo no eixo Y
@export var suavidade : float = 0.05 # valor de suavização do movimento da camera

# limite de proximidade da camera com jogadores longe
@export_range(0,10,0.01) var zoomLonge = 1.0
# limite de proximidade da camera com jogadores juntos
@export_range(0,10,0.01) var zoomProximo = 2.6
# quanto a camera vai dá zoom baseado na distancia
@export_range(0,10000,50) var aumentoDoZoom = 1250


@onready var Malvo1 = $MakerAlvo1
@onready var Malvo2 = $MakerAlvo2
@onready var Meio = $PontoMedio
@onready var camera = $PontoMedio/Camera2D
@onready var icon = $PontoMedio/Icon
@onready var textoDebug = $PontoMedio/Window/TextEdit


func _ready() -> void:
	if exibir_alvo:
		print(icon.texture.get_width())
	pass

func _process(delta: float) -> void:
	Malvo1.global_position = alvo1.position
	Malvo2.global_position = alvo2.position
	
	var mediaX = (alvo1.global_position.x + alvo2.global_position.x)/2
	var mediaY = (alvo1.global_position.y + alvo2.global_position.y)/2
	var pontoMedio : Vector2 = Vector2(mediaX, mediaY)
	
	# define a posição da camera em relação aos dois pontos
	pontoMedio += Vector2(offsetX, offsetY) # define o deslocamento relativo ao ponto central
	Meio.global_position = pontoMedio.lerp(pontoMedio, suavidade)
	
	var distancia = alvo1.global_position.distance_to(alvo2.global_position)
	var zoom = clamp(aumentoDoZoom/distancia, zoomLonge, zoomProximo)
	
	camera.zoom = Vector2(zoom, zoom)
	
	# print(pontoMedio," ", distancia," ", zoom)
	
	#Debug quando ativa mostra uma janela com uns dados
	if exibir_alvo:
		icon.visible = true
		textoDebug.visible = true
		textoDebug.get_parent().visible = true
		icon.look_at(alvo1.global_position)
		icon.scale = Vector2(distancia/icon.texture.get_width(),zoom)
		textoDebug.text = "distancia: %f\nzoom: %f\nposição alvo 1: %v\nposição alvo 2: %v\nponto medio: %v" % [distancia, zoom, Malvo1.global_position, Malvo2.global_position,pontoMedio]
	else:
		icon.visible =false
		textoDebug.visible = false
		textoDebug.get_parent().visible = false
