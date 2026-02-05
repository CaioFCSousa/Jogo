extends CharacterBody2D

# --- CONFIGURAÇÕES NO INSPETOR ---
@export_enum("P1", "P2") var player_id: String = "P1"
@export var cor_do_personagem: Color = Color.WHITE # Mude a cor da imagem aqui!

const SPEED = 170.0
const JUMP_VELOCITY = -400.0 
const SLIDE_SPEED = 400.0 

@onready var anim = $AnimatedSprite2D
@onready var fumaca = $Fumaca 

# Variáveis internas para os controles
var acao_esquerda : String
var acao_direita : String
var acao_pulo : String
var acao_slide : String

var estava_no_ar = false
var esta_deslizando = false 

func _ready() -> void:
	# 1. MUDAR A COR DA IMAGEM
	# O modulate pinta o seu AnimatedSprite2D com a cor escolhida
	anim.modulate = cor_do_personagem

	# 2. DEFINIR TECLAS POR JOGADOR
	if player_id == "P1":
		acao_esquerda = "p1_esquerda"
		acao_direita = "p1_direita"
		acao_pulo = "p1_pulo"
		acao_slide = "p1_slide"
	else:
		acao_esquerda = "p2_esquerda"
		acao_direita = "p2_direita"
		acao_pulo = "p2_pulo"
		acao_slide = "p2_slide"

	# 3. CONFIGURAR NODES AUXILIARES
	if fumaca:
		if not fumaca.animation_finished.is_connected(_on_fumaca_animation_finished):
			fumaca.animation_finished.connect(_on_fumaca_animation_finished)
		fumaca.set_as_top_level(true)
	
	if not anim.animation_finished.is_connected(_on_anim_finished):
		anim.animation_finished.connect(_on_anim_finished)

func _physics_process(delta: float) -> void:
	# LÓGICA DE POUSO (FUMAÇA)
	if is_on_floor() and estava_no_ar:
		tocar_fumaca("pouso")
	estava_no_ar = !is_on_floor()

	# GRAVIDADE E ANIMAÇÃO DE QUEDA/PULO
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not esta_deslizando:
			if velocity.y < 0: anim.play("jump")
			else: anim.play("fall")

	# COMANDO DE PULO
	if Input.is_action_just_pressed(acao_pulo) and is_on_floor() and not esta_deslizando:
		velocity.y = JUMP_VELOCITY
		tocar_fumaca("pulo")

	# PULO VARIÁVEL (SOLTAR A TECLA)
	if Input.is_action_just_released(acao_pulo) and velocity.y < 0:
		velocity.y = velocity.y * 0.4 

	# COMANDO DE SLIDE (DESLISE)
	if Input.is_action_just_pressed(acao_slide) and not esta_deslizando and is_on_floor():
		iniciar_slide()

	# MOVIMENTO HORIZONTAL
	if not esta_deslizando:
		var direction = Input.get_axis(acao_esquerda, acao_direita)
		
		# Prioridade de tecla (Evita travar se apertar as duas)
		if direction == 0:
			if Input.is_action_pressed(acao_direita): direction = 1
			elif Input.is_action_pressed(acao_esquerda): direction = -1

		if direction != 0:
			velocity.x = direction * SPEED
			anim.flip_h = (direction < 0)
			if is_on_floor(): anim.play("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor(): anim.play("idle")
	else:
		# Velocidade fixa durante o slide
		velocity.x = (SLIDE_SPEED if not anim.flip_h else -SLIDE_SPEED)

	move_and_slide()

func iniciar_slide():
	esta_deslizando = true
	anim.play("slide")
	tocar_fumaca("pulo")

# Chamado quando a animação de slide termina
func _on_anim_finished():
	if anim.animation == "slide":
		esta_deslizando = false

func tocar_fumaca(nome_anim):
	if fumaca:
		fumaca.global_position = global_position
		fumaca.show()
		fumaca.play(nome_anim)

func _on_fumaca_animation_finished():
	if fumaca: fumaca.hide()
