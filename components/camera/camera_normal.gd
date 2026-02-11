extends Node2D

"""
script para camera com apenas 1 jogador ou foco
"""

@export_group("configuração da camera")
@export var alvo : Node2D
@export var offset : Vector2
@export var zoom_da_camera : Vector2 = Vector2.ONE
@export_range(0,1,0.01) var suavidade : float = 1
@export_subgroup("configração mouse")
@export var mouse : bool 
@export_range(-100,100,) var scroll = 0.5

@onready var camera = $Camera2D
var posicao = Vector2.ZERO

func _ready() -> void:
	global_position = alvo.global_position
	camera.zoom = zoom_da_camera

func _process(delta: float) -> void:
	if alvo != null:
		posicao = alvo.global_position + offset
		global_position = global_position.lerp(posicao, suavidade)

func _input(event):
	if event is InputEventMouseButton and mouse:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# print("para cima")
			camera.zoom += Vector2(scroll,scroll)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			camera.zoom -= Vector2(scroll,scroll)
			# print("para baixo")
		print(camera.zoom)
