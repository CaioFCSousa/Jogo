extends CharacterBody2D

# --- CONFIGURAÇÕES E ESTADOS ---
@export_enum("P1", "P2") var player_id: String = "P1" # Define se é o jogador 1 ou 2 para mapear controles
@export var cor_do_personagem: Color = Color.WHITE    # Cor base para diferenciar os jogadores visualmente
@export var coyote_duration: float = 0.15             # Tempo extra (em segundos) para pular após cair de uma plataforma
@export var flipar_elementos: Array[Node2D] = []      # Lista de nós que devem virar junto com o personagem (Ex: Hitboxes)

# Máquina de Estados para organizar o comportamento (Parado, Movendo, Pulando, etc.)
enum State { IDLE, MOVE, JUMP, FALL, SLIDE, CLIMB }
var current_state = State.IDLE
var coyote_timer: float = 0.0 # Cronômetro interno do Coyote Time

# --- SISTEMA DE CARTAS ---
var habilidade_atual: AbilityResource = null:
	set(valor):
		habilidade_atual = valor
		if valor != null: aplicar_buffs_passivos(valor) # Aplica melhorias assim que recebe a carta

var em_cooldown: bool = false # Bloqueia o uso da habilidade se estiver em tempo de recarga

# Status Dinâmicos (podem ser alterados por cartas/debuffs)
var speed_atual: float = 170.0
var jump_force_atual: float = -400.0
var modificador_inimigo: float = 1.0 # Reduz velocidade se o inimigo usar debuff
var pode_pular: bool = true
var pode_escalar: bool = false

# Constantes de Base para Reset e Referência
const SPEED_BASE = 170.0
const JUMP_BASE = -400.0
const SLIDE_SPEED = 400.0

@onready var anim = $AnimatedSprite2D
@onready var fumaca = $Fumaca

# Nomes das ações de input (configuradas no Project Settings)
var acao_esquerda: String; var acao_direita: String
var acao_pulo: String; var acao_slide: String
var acao_habilidade: String

func _ready() -> void:
	anim.modulate = cor_do_personagem
	# Define dinamicamente quais teclas esse player usa (ex: P1_esquerda ou P2_esquerda)
	var p = player_id
	acao_esquerda = p + "_esquerda"; acao_direita = p + "_direita"
	acao_pulo = p + "_pulo"; acao_slide = p + "_slide"
	acao_habilidade = p + "_habilidade"
	
	setup_signals()

func _physics_process(delta: float) -> void:
	# 1. Gerenciamento do Coyote Time
	if is_on_floor():
		coyote_timer = coyote_duration # Reset enquanto no chão
	else:
		coyote_timer -= delta # Começa a contagem regressiva ao sair da plataforma
	
	aplicar_gravidade(delta)
	
	# 2. Execução da Lógica do Estado Atual
	var direcao = Input.get_axis(acao_esquerda, acao_direita)
	match current_state:
		State.IDLE: _state_idle()
		State.MOVE: _state_move(direcao)
		State.JUMP: _state_jump(direcao)
		State.FALL: _state_fall(direcao)
		State.SLIDE: _state_slide()
		State.CLIMB: _state_climb()

	# 3. Processamento de Física e Troca de Estados
	move_and_slide()
	_check_state_transitions(direcao)
	
	# 4. Uso de Habilidades Ativas
	if Input.is_action_just_pressed(acao_habilidade) and habilidade_atual and not em_cooldown:
		executar_habilidade()

# --- LÓGICA DOS ESTADOS ---

func _state_idle():
	anim.play("idle")
	velocity.x = move_toward(velocity.x, 0, speed_atual) # Desaceleração suave

func _state_move(dir):
	anim.play("walk")
	velocity.x = dir * (speed_atual * modificador_inimigo)
	atualizar_direcao_visual(dir) # Resolve o problema do Moonwalk

func _state_jump(dir):
	anim.play("jump")
	velocity.x = dir * (speed_atual * modificador_inimigo) # Controle aéreo
	atualizar_direcao_visual(dir)

func _state_fall(dir):
	anim.play("fall")
	velocity.x = dir * (speed_atual * modificador_inimigo)
	atualizar_direcao_visual(dir)

func _state_slide():
	anim.play("slide")
	# Desliza para onde o personagem está olhando
	var direcao_olhar = -1.0 if anim.flip_h else 1.0
	velocity.x = direcao_olhar * SLIDE_SPEED * modificador_inimigo

func _state_climb():
	anim.play("jump")
	velocity.y = -SPEED_BASE # Sobe a parede

# --- FÍSICA E REGRAS DE TRANSIÇÃO ---

func _check_state_transitions(dir):
	# 1. Detectar POUSO (Antes de mudar os estados de ar para chão)
	# Se acabamos de tocar o chão e vínhamos de uma queda ou pulo
	if is_on_floor() and (current_state == State.FALL or current_state == State.JUMP):
		tocar_fumaca("pouso") 
	
	# 2. Gatilho de Pulo (Coyote Time)
	if Input.is_action_just_pressed(acao_pulo) and pode_pular and coyote_timer > 0:
		if current_state != State.SLIDE:
			velocity.y = jump_force_atual
			current_state = State.JUMP
			tocar_fumaca("pulo")
			coyote_timer = 0
			return

	# 3. Transições de Chão
	if is_on_floor():
		if Input.is_action_just_pressed(acao_slide) and current_state != State.SLIDE:
			current_state = State.SLIDE
			tocar_fumaca("pulo") # Usando fumaça de pulo para o slide também
		elif current_state != State.SLIDE:
			current_state = State.MOVE if dir != 0 else State.IDLE
	
	# 4. Transições de Ar
	else:
		if pode_escalar and is_on_wall() and Input.is_action_pressed(acao_pulo):
			current_state = State.CLIMB
		elif velocity.y > 0 and current_state != State.CLIMB:
			current_state = State.FALL

	if is_on_floor():
		# Transições no chão
		if Input.is_action_just_pressed(acao_slide) and current_state != State.SLIDE:
			current_state = State.SLIDE
			tocar_fumaca("pulo")
		elif current_state != State.SLIDE:
			current_state = State.MOVE if dir != 0 else State.IDLE
	else:
		# Transições no ar
		if pode_escalar and is_on_wall() and Input.is_action_pressed(acao_pulo):
			current_state = State.CLIMB
		elif velocity.y > 0 and current_state != State.CLIMB:
			current_state = State.FALL

	# Efeito visual de pouso
	if is_on_floor() and (current_state == State.FALL or current_state == State.JUMP):
		tocar_fumaca("pouso")

func aplicar_gravidade(delta):
	if not is_on_floor() and current_state != State.CLIMB:
		var grav = get_gravity()
		# "Peso" extra ao cair para um pulo mais satisfatório
		if velocity.y > 0: grav *= 1.5 
		# Pulo variável: se soltar o botão rápido, o pulo é mais baixo
		if velocity.y < 0 and not Input.is_action_pressed(acao_pulo):
			grav *= 2.0
		velocity += grav * delta

func atualizar_direcao_visual(direcao: float):
	if direcao == 0: return
	
	# Vira o sprite principal
	if anim:
		anim.flip_h = direcao < 0
	
	# Vira elementos extras (Hitboxes, Markers, etc)
	for no in flipar_elementos:
		if no == null or no == anim: continue 
		
		if no is AnimatedSprite2D or no is Sprite2D:
			no.flip_h = direcao < 0
		else:
			# Usa escala negativa para virar objetos que não são sprites
			no.scale.x = abs(no.scale.x) * direcao

# --- CARTAS E INTERAÇÃO ---

func aplicar_buffs_passivos(data: AbilityResource):
	# Ajusta os status base do personagem conforme a carta escolhida
	speed_atual = SPEED_BASE * data.multiplicador_velocidade
	jump_force_atual = JUMP_BASE * data.multiplicador_pulo
	pode_escalar = data.concede_escalada

func executar_habilidade():
	if habilidade_atual.modo_uso == "PASSIVA": return
	# Envia o efeito da habilidade para todos os outros jogadores (inimigos)
	for inimigo in get_tree().get_nodes_in_group("players"):
		if inimigo != self: inimigo.receber_debuff(habilidade_atual)
	iniciar_cooldown(habilidade_atual.cooldown)

func receber_debuff(data: AbilityResource):
	# Aplica os efeitos negativos recebidos de outro jogador
	modificador_inimigo = data.debuff_velocidade
	pode_pular = !data.bloqueia_pulo
	
	# Feedback visual (muda de cor enquanto sob efeito)
	var tween = create_tween()
	tween.tween_property(anim, "modulate", data.cor_interface, 0.2)
	
	await get_tree().create_timer(data.duracao_debuff).timeout
	
	# Retorna ao normal após o fim do efeito
	var tween_back = create_tween()
	tween_back.tween_property(anim, "modulate", cor_do_personagem, 0.2)
	modificador_inimigo = 1.0
	pode_pular = true

func iniciar_cooldown(tempo: float):
	em_cooldown = true
	await get_tree().create_timer(tempo).timeout
	em_cooldown = false

# --- SINAIS E VISUAIS ---

func setup_signals():
	if fumaca:
		if not fumaca.animation_finished.is_connected(_on_fumaca_finished):
			fumaca.animation_finished.connect(_on_fumaca_finished)
		# A fumaça fica solta no mundo (não segue o player após criada)
		fumaca.set_as_top_level(true)
	anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished():
	# Retorna ao estado normal após terminar o slide
	if current_state == State.SLIDE:
		current_state = State.IDLE

func _on_fumaca_finished():
	fumaca.hide()

func tocar_fumaca(anim_nome):
	if fumaca:
		# Para a animação atual e reseta para o frame 0
		fumaca.stop() 
		fumaca.global_position = global_position
		fumaca.show()
		fumaca.play(anim_nome)
