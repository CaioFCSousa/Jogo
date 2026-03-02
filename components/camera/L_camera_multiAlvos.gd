extends Camera2D

"""
Resumo:
Apartir de dois pontos (alvo1 e alvo2), é calculado o ponto medio e depois
 é aplicado um deslocamneto relativo (offsetx, offsety) ao ponto medio,
depois é aplicado uma suavização 
"""

#organização de configurações agrupados
@export_group("alvos")
@export var alvo : Array[Node2D]

@export_group("configurações da camêra")
@export var offsetX = 0 # deslocamento relativo no eixo X
@export var offsetY = 0 # deslocamento relativo no eixo Y
@export var suavidade : float = 0.05 # valor de suavização do movimento da camera

# limite de proximidade da camera com jogadores longe
@export_range(0,10,0.01) var zoomLonge = 0.2
# limite de proximidade da camera com jogadores juntos
@export_range(0,10,0.01) var zoomProximo = 3.0
# quanto a camera vai dá zoom baseado na distancia
@export_range(0,10000,50) var aumentoDoZoom = 500

@onready var textoDebug = $janela_debug

func _ready() -> void:
	if !alvo:
		# se nenhum alvo for pré setado ele busca os players
		alvo = buscar_players()
var t = 0
var pontoMedio : Vector2
func _process(delta: float) -> void:
	t += delta
	# depois passar essas coisas para funções fica mais facil de fazer manuteção
	var mediaX = 0
	var mediaY = 0
	for alvos_l in alvo: # nn sei um nome melhor para essa variavel
		mediaX += alvos_l.global_position.x
		mediaY += alvos_l.global_position.y
	
	# define a posição da camera em relação aos dois pontos
	pontoMedio = Vector2(mediaX, mediaY)/alvo.size()

	# aplica o deslocamaneto ao ponto medio
	pontoMedio += Vector2(offsetX,offsetY)
	# estou na duvida qual seria o mais apropriado a mecher a cena como toda ou apenas a camera
	global_position = pontoMedio
	var mais_distante = 0
	for i in alvo:
		var verificao = i.global_position.distance_to(pontoMedio)
		if verificao > mais_distante:
			mais_distante = verificao
	
	var zoomC = clamp(aumentoDoZoom/mais_distante, zoomLonge,zoomProximo)
	
	self.zoom = Vector2(zoomC, zoomC)
	# suavidade ta bugado por enquanto
	global_position = lerp(global_position, pontoMedio, 1)
	textoDebug.atualizar_texto("posição: %v\nmais distante: %f\n" % [pontoMedio, mais_distante])

func buscar_players() -> Array[Node2D]:
	var lista_player : Array[Node2D] = []
	for x in get_parent().get_children():
		if x.is_in_group("player"):
			lista_player.append(x)
	return lista_player
