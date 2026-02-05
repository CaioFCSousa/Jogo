extends Node2D

@export_group("Alvos")
@export var alvo1 : Node2D
@export var alvo2 : Node2D
@export var exibir_alvo : bool = false

@export_group("Configurações da Câmera")
@export_range(0, 5, 0.01) var zoomMinimo = 0.5   # O quão longe a câmera vai (jogadores distantes)
@export_range(0, 5, 0.01) var zoomMaximo = 1.2   # O quão perto a câmera vai (jogadores juntos)
@export var suavidade = 0.1                      # Para a câmera não tremer
@export var margem_zoom = 400.0                  # Valor base para o cálculo da distância

@onready var Meio = $PontoMedio
@onready var camera = $PontoMedio/Camera2D
@onready var icon = $PontoMedio/Icon

func _process(delta: float) -> void:
	if not alvo1 or not alvo2: return # Evita erro se um player sumir

	# 1. POSICIONAR NO PONTO MÉDIO
	# Usamos lerp para a câmera seguir os jogadores de forma suave
	var pontoMedio = (alvo1.global_position + alvo2.global_position) / 2
	Meio.global_position = Meio.global_position.lerp(pontoMedio, suavidade)
	
	# 2. CALCULAR DISTÂNCIA
	var distancia = alvo1.global_position.distance_to(alvo2.global_position)
	
	# 3. LÓGICA DE ZOOM
	# Dividimos a margem pela distância para que:
	# Quanto maior a distância -> Menor o número (Zoom Longe)
	# Quanto menor a distância -> Maior o número (Zoom Perto)
	var valor_zoom = clamp(margem_zoom / distancia, zoomMinimo, zoomMaximo)
	
	# Aplicamos o zoom suavemente com lerp para evitar trancos
	var zoom_suave = lerp(camera.zoom.x, valor_zoom, suavidade)
	camera.zoom = Vector2(zoom_suave, zoom_suave)
	
	# 4. DEBBUG (Ícone que estica entre eles)
	if exibir_alvo and icon:
		icon.global_position = Meio.global_position
		icon.look_at(alvo1.global_position)
		icon.scale.x = distancia / icon.texture.get_width()
