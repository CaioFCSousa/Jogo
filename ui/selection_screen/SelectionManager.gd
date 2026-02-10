extends CanvasLayer

@export var lista_de_todas_as_cartas: Array[AbilityResource]
@export var card_ui_scene: PackedScene

var escolhas_feitas = 0

@onready var container_p1 = $HBoxP1
@onready var container_p2 = $HBoxP2

func _ready():
	randomize() 
	process_mode = PROCESS_MODE_ALWAYS 
	layer = 10 
	preparar_fase.call_deferred()

func preparar_fase():
	self.show()
	get_tree().paused = true
	escolhas_feitas = 0
	
	for c in container_p1.get_children(): c.queue_free()
	for c in container_p2.get_children(): c.queue_free()
	
	gerar_cartas_para_player(1, container_p1)
	gerar_cartas_para_player(2, container_p2)

func gerar_cartas_para_player(p_id: int, container: Control):
	if lista_de_todas_as_cartas.size() < 3:
		push_error("Adicione pelo menos 3 habilidades no Inspetor!")
		return

	var sorteio = lista_de_todas_as_cartas.duplicate()
	sorteio.shuffle()
	
	for i in range(3):
		var nova_carta = card_ui_scene.instantiate() as CardUI
		container.add_child(nova_carta)
		
		if nova_carta:
			nova_carta.setup(sorteio[i])
			nova_carta.selecionada.connect(_ao_jogador_escolher.bind(p_id))

func _ao_jogador_escolher(habilidade: AbilityResource, p_id: int):
	# 1. Definir variáveis básicas
	var container = container_p1 if p_id == 1 else container_p2
	var tamanho_tela = get_viewport().get_visible_rect().size
	var id_procurado = "P" + str(p_id)
	
	# 2. Entregar a habilidade para o Player no grupo 'players'
	var players = get_tree().get_nodes_in_group("players")
	var encontrou_player = false
	
	for p in players:
		if p.get("player_id") == id_procurado:
			p.habilidade_atual = habilidade
			encontrou_player = true
			print("SUCESSO: Carta ", habilidade.nome, " entregue para ", id_procurado)
			break 

	if not encontrou_player:
		print("ERRO: O SelectionManager não encontrou o jogador: ", id_procurado, " no grupo 'players'!")

	# 3. Calcular ponto alvo para a animação da carta
	var ponto_alvo = Vector2.ZERO
	if p_id == 1:
		ponto_alvo = Vector2(tamanho_tela.x * 0.70, tamanho_tela.y * 0.35)
	else:
		ponto_alvo = Vector2(tamanho_tela.x * 0.25, tamanho_tela.y * 0.35)

	# 4. Animar as cartas (A escolhida voa, as outras somem)
	for carta in container.get_children():
		if carta is CardUI:
			if carta.habilidade_data == habilidade:
				carta.animar_selecao(ponto_alvo)
			else:
				carta.sumir_carta()

	# 5. Contabilizar escolhas para fechar o menu
	escolhas_feitas += 1
	if escolhas_feitas >= 2:
		esperar_e_comecar()

func esperar_e_comecar():
	await get_tree().create_timer(1.4).timeout
	comecar_corrida()

func comecar_corrida():
	get_tree().paused = false
	self.hide()
