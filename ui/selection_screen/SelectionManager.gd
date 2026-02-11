extends CanvasLayer

@export_group("Configurações")
@export var lista_habilidades: Array[AbilityResource]
@export var card_scene: PackedScene

@export_group("Interface")
@export var container_p1: HBoxContainer
@export var container_p2: HBoxContainer

var escolhas_feitas: int = 0

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	layer = 10
	preparar_fase.call_deferred()

func preparar_fase():
	self.show()
	get_tree().paused = true
	escolhas_feitas = 0
	
	for c in [container_p1, container_p2]:
		if c: # Segurança caso o container seja nulo
			for child in c.get_children(): child.queue_free()
	
	gerar_cartas(1, container_p1)
	gerar_cartas(2, container_p2)

func gerar_cartas(p_id: int, container: Control):
	if card_scene == null or container == null: return
	
	var pool = lista_habilidades.duplicate()
	pool.shuffle()
	
	for i in range(min(3, pool.size())):
		var carta = card_scene.instantiate() as CardUI
		container.add_child(carta)
		carta.setup(pool[i])
		carta.selecionada.connect(_ao_escolher_carta.bind(p_id))

func _ao_escolher_carta(habilidade: AbilityResource, p_id: int):
	# Lógica de entrega para o player
	var p_tag = "P" + str(p_id)
	for p in get_tree().get_nodes_in_group("players"):
		if p.get("player_id") == p_tag:
			p.habilidade_atual = habilidade
			break

	# Animação de Movimento
	var tela = get_viewport().get_visible_rect().size
	# Define o alvo: P1 voa para a direita, P2 voa para a esquerda
	var alvo = Vector2(tela.x * 0.75, tela.y * 0.4) if p_id == 1 else Vector2(tela.x * 0.25, tela.y * 0.4)
	
	var container = container_p1 if p_id == 1 else container_p2
	for carta in container.get_children():
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
