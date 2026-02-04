extends Node2D
@export_group("alvos")
@export var alvo1 : Node2D = Node2D.new()
@export var alvo2 : Node2D = Node2D.new()
@export var exibir_alvo : bool = false

@export_group("configurações da camêra")
@export_range(0,10,0.01) var zoomLonge = 0.5
@export_range(0,10,0.01) var zoomProximo = 1.2
@export_range(0,10000,50) var aumentoDoZoom = 250

@onready var Malvo1 = $MakerAlvo1
@onready var Malvo2 = $MakerAlvo2
@onready var Meio = $PontoMedio
@onready var camera = $PontoMedio/Camera2D
@onready var icon = $PontoMedio/Icon
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if exibir_alvo:
		print(icon.texture.get_width())
		pass
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Malvo1.global_position = alvo1.position
	Malvo2.global_position = alvo2.position
	var mediaX = (alvo1.global_position.x + alvo2.global_position.x)/2
	var mediaY = (alvo1.global_position.y + alvo2.global_position.y)/2
	var pontoMedio : Vector2 = Vector2(mediaX, mediaY)
	
	Meio.global_position = pontoMedio
	
	var distancia = alvo1.global_position.distance_to(alvo2.global_position)
	var zoom = clamp(aumentoDoZoom/distancia, zoomLonge, zoomProximo)
	# var zoom = clamp(500/distancia, 0.5, 1.2)
	
	camera.zoom = Vector2(zoom, zoom)
	# print(pontoMedio," ", distancia," ", zoom)
	if exibir_alvo:
		icon.look_at(alvo1.global_position)
		icon.scale = Vector2(distancia/icon.texture.get_width(),zoom)
	pass
