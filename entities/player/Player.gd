extends CharacterBody2D

# --- CONFIGURAÇÕES E ESTADOS ---
@export_enum("P1", "P2") var player_id: String = "P1"
@export var cor_do_personagem: Color = Color.WHITE
@export var coyote_duration: float = 0.15
@export var flipar_elementos: Array[Node2D] = []

enum State { IDLE, MOVE, JUMP, FALL, SLIDE, CLIMB }
var current_state = State.IDLE
var coyote_timer: float = 0.0
var esta_congelado: bool = false

# --- SISTEMA DE CARTAS ---
var habilidade_atual: AbilityResource = null:
	set(valor):
		habilidade_atual = valor
		if valor != null: aplicar_buffs_passivos(valor)

var em_cooldown: bool = false

# Status Dinâmicos
var speed_atual: float = 170.0
var jump_force_atual: float = -400.0
var modificador_inimigo: float = 1.0
var pode_pular: bool = true
var pode_escalar: bool = false

const SPEED_BASE = 170.0
const JUMP_BASE = -400.0
const SLIDE_SPEED = 400.0

@onready var anim = $AnimatedSprite2D
@onready var fumaca = $Fumaca

var acao_esquerda: String; var acao_direita: String
var acao_pulo: String; var acao_slide: String
var acao_habilidade: String

func _ready() -> void:
	anim.modulate = cor_do_personagem
	var p = player_id
	acao_esquerda = p + "_esquerda"; acao_direita = p + "_direita"
	acao_pulo = p + "_pulo"; acao_slide = p + "_slide"
	acao_habilidade = p + "_habilidade"
	setup_signals()

func _physics_process(delta: float) -> void:
	# 1. Gerenciamento de tempo
	if is_on_floor():
		coyote_timer = coyote_duration
	else:
		coyote_timer -= delta
	
	aplicar_gravidade(delta)
	
	# 2. Direção e Trava de Gelo
	var direcao = Input.get_axis(acao_esquerda, acao_direita)
	
	if esta_congelado:
		direcao = 0
		if is_on_floor(): velocity.x = 0 # Garante parada total no chão

	# 3. Execução do Estado
	match current_state:
		State.IDLE: _state_idle()
		State.MOVE: _state_move(direcao)
		State.JUMP: _state_jump(direcao)
		State.FALL: _state_fall(direcao)
		State.SLIDE: _state_slide()
		State.CLIMB: _state_climb()

	move_and_slide()
	_check_state_transitions(direcao)
	
	# 4. Uso de Habilidades
	if Input.is_action_just_pressed(acao_habilidade) and habilidade_atual and not em_cooldown and not esta_congelado:
		executar_habilidade()

# --- LÓGICA DOS ESTADOS ---

func _state_idle():
	anim.play("idle")
	velocity.x = move_toward(velocity.x, 0, speed_atual)

func _state_move(dir):
	anim.play("walk")
	velocity.x = dir * (speed_atual * modificador_inimigo)
	atualizar_direcao_visual(dir)

func _state_jump(dir):
	anim.play("jump")
	velocity.x = dir * (speed_atual * modificador_inimigo)
	atualizar_direcao_visual(dir)

func _state_fall(dir):
	anim.play("fall")
	velocity.x = dir * (speed_atual * modificador_inimigo)
	atualizar_direcao_visual(dir)

func _state_slide():
	anim.play("slide")
	var direcao_olhar = -1.0 if anim.flip_h else 1.0
	velocity.x = direcao_olhar * SLIDE_SPEED * modificador_inimigo

func _state_climb():
	anim.play("jump")
	velocity.y = -SPEED_BASE

# --- FÍSICA E TRANSIÇÕES ---

func _check_state_transitions(dir):
	# Efeito de pouso
	if is_on_floor() and (current_state == State.FALL or current_state == State.JUMP):
		tocar_fumaca("pouso")

	# Transições se estiver no CHÃO
	if is_on_floor():
		if Input.is_action_just_pressed(acao_slide) and current_state != State.SLIDE and not esta_congelado:
			current_state = State.SLIDE
			tocar_fumaca("pulo")
		elif Input.is_action_just_pressed(acao_pulo) and pode_pular and not esta_congelado:
			velocity.y = jump_force_atual
			current_state = State.JUMP
			tocar_fumaca("pulo")
			coyote_timer = 0
		elif current_state != State.SLIDE:
			current_state = State.MOVE if dir != 0 else State.IDLE
	
	# Transições se estiver no AR
	else:
		# Pulo Coyote
		if Input.is_action_just_pressed(acao_pulo) and pode_pular and coyote_timer > 0 and not esta_congelado:
			velocity.y = jump_force_atual
			current_state = State.JUMP
			tocar_fumaca("pulo")
			coyote_timer = 0
		elif pode_escalar and is_on_wall() and Input.is_action_pressed(acao_pulo) and not esta_congelado:
			current_state = State.CLIMB
		elif velocity.y > 0 and current_state != State.CLIMB:
			current_state = State.FALL

func aplicar_gravidade(delta):
	if not is_on_floor() and current_state != State.CLIMB:
		var grav = get_gravity()
		if velocity.y > 0: grav *= 1.5 
		if velocity.y < 0 and not Input.is_action_pressed(acao_pulo):
			grav *= 2.0
		velocity += grav * delta

func atualizar_direcao_visual(direcao: float):
	if direcao == 0 or esta_congelado: return
	if anim: anim.flip_h = direcao < 0
	for no in flipar_elementos:
		if no == null or no == anim: continue 
		if no is AnimatedSprite2D or no is Sprite2D: no.flip_h = direcao < 0
		else: no.scale.x = abs(no.scale.x) * (1 if direcao > 0 else -1)

# --- CARTAS E INTERAÇÃO ---

func aplicar_buffs_passivos(data: AbilityResource):
	speed_atual = SPEED_BASE * data.multiplicador_velocidade
	jump_force_atual = JUMP_BASE * data.multiplicador_pulo
	pode_escalar = data.concede_escalada

func executar_habilidade():
	if habilidade_atual.modo_uso == "PASSIVA": return
	for inimigo in get_tree().get_nodes_in_group("players"):
		if inimigo != self: inimigo.receber_debuff(habilidade_atual)
	iniciar_cooldown(habilidade_atual.cooldown)

func receber_debuff(data: AbilityResource):
	if data.congela_inimigo:
		esta_congelado = true
		velocity = Vector2.ZERO
		current_state = State.IDLE # Cancela qualquer movimento atual (slide/move)
	
	modificador_inimigo = data.debuff_velocidade
	pode_pular = !data.bloqueia_pulo
	
	var tween = create_tween()
	tween.tween_property(anim, "modulate", data.cor_interface, 0.2)
	
	await get_tree().create_timer(data.duracao_debuff).timeout
	
	var tween_back = create_tween()
	tween_back.tween_property(anim, "modulate", cor_do_personagem, 0.2)
	
	esta_congelado = false
	modificador_inimigo = 1.0
	pode_pular = true

func iniciar_cooldown(tempo: float):
	em_cooldown = true
	await get_tree().create_timer(tempo).timeout
	em_cooldown = false

# --- CALLBACKS E VISUAIS ---

func setup_signals():
	if fumaca:
		if not fumaca.animation_finished.is_connected(_on_fumaca_finished):
			fumaca.animation_finished.connect(_on_fumaca_finished)
		fumaca.set_as_top_level(true)
	if not anim.animation_finished.is_connected(_on_anim_finished):
		anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished():
	if current_state == State.SLIDE:
		current_state = State.IDLE

func _on_fumaca_finished():
	fumaca.hide()

func tocar_fumaca(anim_nome):
	if fumaca:
		fumaca.stop() 
		fumaca.global_position = global_position
		fumaca.show()
		fumaca.play(anim_nome)
