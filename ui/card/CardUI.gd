extends Button 
class_name CardUI

signal selecionada(habilidade: AbilityResource)

var habilidade_data: AbilityResource

func _ready():
	# Centraliza o pivô para animações de escala
	pivot_offset = size / 2
	
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func setup(data: AbilityResource):
	if data == null: return
	habilidade_data = data
	
	# Mapeamos qual variável do Resource vai para qual nó da cena
	# Certifique-se que os nomes dos nós na cena são esses (Fundo, Ilustracao, etc)
	_atualizar_no("1", data.atlas_1)
	_atualizar_no("2", data.atlas_2)
	_atualizar_no("3", data.atlas_3)


	if has_node("LabelNome"): 
		$LabelNome.text = data.nome

# Função auxiliar para evitar repetição
func _atualizar_no(nome_no: String, textura: Texture2D):
	var node = find_child(nome_no) as TextureRect
	if node:
		node.texture = textura
		node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node.visible = (textura != null) # Esconde se não tiver imagem
	
	



func _on_pressed():
	if habilidade_data:
		selecionada.emit(habilidade_data)
		disabled = true

func animar_selecao(posicao_alvo: Vector2):
	set_as_top_level(true)
	z_index = 100
	
	var tween = create_tween().set_parallel(true)
	
	# Anima para o centro da tela ou posição do mouse
	tween.tween_property(self, "global_position", posicao_alvo - (size / 2), 0.3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_BACK)

func sumir_carta():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.chain().finished.connect(queue_free)
