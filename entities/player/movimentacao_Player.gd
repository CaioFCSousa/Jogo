extends CharacterBody2D

# --- CONFIGURAÇÕES ---
@export_enum("P1", "P2") var player_id: String = "P1"
@export var cor_do_personagem: Color = Color.WHITE

# --- SISTEMA DE CARTAS ---
var habilidade_atual: AbilityResource = null:
	set(valor):
		habilidade_atual = valor
		if valor != null:
			aplicar_buffs_passivos(valor)

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

var esta_deslizando = false
var estava_no_ar = false # Necessário para a fumaça de pouso

func _ready() -> void:
	anim.modulate = cor_do_personagem
	var p = player_id
	acao_esquerda = p + "_esquerda"; acao_direita = p + "_direita"
	acao_pulo = p + "_pulo"; acao_slide = p + "_slide"
	acao_habilidade = p + "_habilidade"
	
	if fumaca:
		if not fumaca.animation_finished.is_connected(_on_fumaca_animation_finished):
			fumaca.animation_finished.connect(_on_fumaca_animation_finished)
		fumaca.set_as_top_level(true)
	
	if not anim.animation_finished.is_connected(_on_anim_finished):
		anim.animation_finished.connect(_on_anim_finished)

func _physics_process(delta: float) -> void:
	# 1. LÓGICA DE POUSO (Fumaça ao cair no chão)
	if is_on_floor() and estava_no_ar:
		tocar_fumaca("pouso")
	estava_no_ar = !is_on_floor()

	# 2. GRAVIDADE
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# 3. MOVIMENTO E GIRO DO SPRITE
	var direcao = Input.get_axis(acao_esquerda, acao_direita)
	
	if not esta_deslizando:
		velocity.x = direcao * (speed_atual * modificador_inimigo)
		
		if direcao != 0:
			anim.flip_h = direcao < 0
		
		# Animações de Ar e Chão
		if is_on_floor():
			if direcao != 0: anim.play("walk")
			else: anim.play("idle")
		else:
			anim.play("jump" if velocity.y < 0 else "fall")
	else:
		# Lógica de velocidade fixa durante o Slide
		var direcao_olhar = -1.0 if anim.flip_h else 1.0
		velocity.x = direcao_olhar * SLIDE_SPEED * modificador_inimigo

	# 4. COMANDO DE PULO
	if Input.is_action_just_pressed(acao_pulo) and is_on_floor() and pode_pular and not esta_deslizando:
		velocity.y = jump_force_atual
		tocar_fumaca("pulo")

	# 5. COMANDO DE SLIDE (Verifica se a tecla foi premida)
	if Input.is_action_just_pressed(acao_slide) and is_on_floor() and not esta_deslizando:
		iniciar_slide()

	# 6. ESCALADA
	if pode_escalar and is_on_wall() and Input.is_action_pressed(acao_pulo):
		velocity.y = -SPEED_BASE

	# 7. USO DE HABILIDADE
	if Input.is_action_just_pressed(acao_habilidade):
		if habilidade_atual and not em_cooldown:
			executar_habilidade()

	move_and_slide()

# --- MECÂNICAS ESPECÍFICAS ---

func iniciar_slide():
	esta_deslizando = true
	anim.play("slide")
	# Se quiser fumaça no início do slide:
	tocar_fumaca("pulo") 

func aplicar_buffs_passivos(data: AbilityResource):
	speed_atual = SPEED_BASE * data.multiplicador_velocidade
	jump_force_atual = JUMP_BASE * data.multiplicador_pulo
	pode_escalar = data.concede_escalada

func executar_habilidade():
	if habilidade_atual.modo_uso == "PASSIVA": return
	var inimigos = get_tree().get_nodes_in_group("players")
	for inimigo in inimigos:
		if inimigo != self:
			inimigo.receber_debuff(habilidade_atual)
	iniciar_cooldown(habilidade_atual.cooldown)

func iniciar_cooldown(tempo: float):
	em_cooldown = true
	await get_tree().create_timer(tempo).timeout
	em_cooldown = false

func receber_debuff(data: AbilityResource):
	modificador_inimigo = data.debuff_velocidade
	pode_pular = !data.bloqueia_pulo
	anim.modulate = data.cor_interface
	await get_tree().create_timer(data.duracao_debuff).timeout
	modificador_inimigo = 1.0
	pode_pular = true
	anim.modulate = cor_do_personagem

# --- ANIMAÇÕES E SINAIS ---

func _on_anim_finished():
	if anim.animation == "slide":
		esta_deslizando = false

func tocar_fumaca(anim_nome):
	if fumaca:
		fumaca.global_position = global_position
		fumaca.show()
		fumaca.play(anim_nome)

func _on_fumaca_animation_finished():
	if fumaca:
		fumaca.hide()
