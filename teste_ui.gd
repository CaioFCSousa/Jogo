extends Control

@export var barra_vida : HBoxContainer
var coracao_base : TextureRect
@export var coracao_cheio : Texture2D
@export var coracao_vazio : Texture2D

var 

@export var vida_max : int
@export var vida : int

func _ready() -> void:
	coracao_base = barra_vida.get_child(0)
	for i in range(vida_max):
		
	pass
