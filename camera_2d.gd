extends Camera2D

# Export permite que você ajuste o valor direto no Inspetor do Godot
@export var suavizacao: float = 0.1
@export var nivel_zoom: Vector2 = Vector2(3.0, 3.0) 

func _ready() -> void:
	# Define o zoom logo que o jogo começa
	# Valores maiores que 1.0 aproximam a imagem (ex: 3.0 é bem perto)
	# Valores menores que 1.0 afastam a imagem (ex: 0.5)
	set_zoom(nivel_zoom)
	
	# Ativa a suavização nativa da câmera para um movimento mais fluido
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0
