extends CanvasLayer

@export_group("Configurações")
@export var lista_habilidades: Array[AbilityResource]
@export var card_scene: PackedScene

@export_group("Interface")
@export var container_p1: HBoxContainer
@export var container_p2: HBoxContainer
# Arraste suas molduras (NinePatchRect) para cá no Inspetor
@export var moldura_p1: NinePatchRect
@export var moldura_p2: NinePatchRect

var escolhas_feitas: int = 0

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	layer = 10
	preparar_fase.call_deferred()

func preparar_fase():
	self.show()
	get_tree().paused = true
	escolhas_feitas = 0
	
	for container in [container_p1, container_p2]:
		if container:
			container.add_theme_constant_override("separation", -30)
			container.alignment = BoxContainer.ALIGNMENT_CENTER
			for c in container.get_children(): 
				c.queue_free()
	
	gerar_cartas_para_player(1, container_p1)
	gerar_cartas_para_player(2, container_p2)
	
	# Aguarda um frame para o Godot calcular os tamanhos e então ajusta o quadro
	await get_tree().process_frame
	ajustar_quadros_ao_tamanho()

func ajustar_quadros_ao_tamanho():
	# Faz a moldura ficar um pouco maior que o container das cartas (margem de 40px)
	if moldura_p1 and container_p1:
		moldura_p1.size = container_p1.size + Vector2(55, 100)
		moldura_p1.position = container_p1.position - Vector2(20, 50)
		
	if moldura_p2 and container_p2:
		moldura_p2.size = container_p2.size + Vector2(55, 100)
		moldura_p2.position = container_p2.position - Vector2(20, 50)

func gerar_cartas_para_player(p_id: int, container: Control):
	if card_scene == null or container == null: return
	
	var pool = lista_habilidades.duplicate()
	pool.shuffle()
	
	for i in range(min(3, pool.size())):
		var carta = card_scene.instantiate() as CardUI
		container.add_child(carta)
		carta.setup(pool[i])
		carta.selecionada.connect(_ao_escolher_carta.bind(p_id))

func _ao_escolher_carta(habilidade: AbilityResource, p_id: int):
	print("Jogador ", p_id, " escolheu a carta: ", habilidade.nome)
	# Esconde a moldura quando o jogador escolhe
	var moldura_alvo = moldura_p1 if p_id == 1 else moldura_p2
	var tw = create_tween()
	tw.tween_property(moldura_alvo, "modulate:a", 0.0, 0.3)
	
	var container_alvo = container_p1 if p_id == 1 else container_p2
	var p_tag = "P" + str(p_id)
	
	for p in get_tree().get_nodes_in_group("players"):
		if p.get("player_id") == p_tag:
			p.habilidade_atual = habilidade
			print("DEBUG: Habilidade ", habilidade.nome, " entregue ao ", p_tag) # <-- ADICIONE ISSO
			break

	var tela = get_viewport().get_visible_rect().size
	var alvo = Vector2(tela.x *  0.25, tela.y * 0.4) if p_id == 1 else Vector2(tela.x * 0.75, tela.y * 0.4)
	
	for carta in container_alvo.get_children():
		if carta is CardUI:
			if carta.habilidade_data == habilidade: 
				carta.animar_selecao(alvo)
			else: 
				carta.sumir_carta()

	escolhas_feitas += 1
	if escolhas_feitas >= 2: finalizar_fase()

func finalizar_fase():
	await get_tree().create_timer(1.5).timeout
	get_tree().paused = false
	self.hide()
