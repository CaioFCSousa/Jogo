extends CharacterBody2D

const SPEED = 170.0
const JUMP_VELOCITY = -400.0 
const SLIDE_SPEED = 400.0 # Velocidade do deslize

@onready var anim = $AnimatedSprite2D
@onready var fumaca = $Fumaca 

var estava_no_ar = false
var esta_deslizando = false # Nova variável de controle

func _ready() -> void:
	if fumaca:
		if not fumaca.animation_finished.is_connected(_on_fumaca_animation_finished):
			fumaca.animation_finished.connect(_on_fumaca_animation_finished)
		fumaca.set_as_top_level(true)
	
	# Conecta a animação do personagem para saber quando o slide acaba
	anim.animation_finished.connect(_on_anim_finished)

func _physics_process(delta: float) -> void:
	# 1. DETECTAR POUSO
	if is_on_floor() and estava_no_ar:
		tocar_fumaca("pouso")
	estava_no_ar = !is_on_floor()

	# 2. GRAVIDADE
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not esta_deslizando: # Só toca jump/fall se não estiver dando slide no ar
			if velocity.y < 0:
				anim.play("jump")
			else:
				anim.play("fall")

	# 3. PULO
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not esta_deslizando:
		velocity.y = JUMP_VELOCITY
		tocar_fumaca("pulo")

	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = velocity.y * 0.4 

	# 4. SLIDE (SHIFT)
	# Verifica se apertou Shift (ui_shift você deve criar no Input Map ou usar "shift")
	if Input.is_action_just_pressed("ui_shift") and not esta_deslizando and is_on_floor():
		iniciar_slide()

	# 5. MOVIMENTO (BLOQUEADO SE ESTIVER DESLIZANDO)
	if not esta_deslizando:
		var direction = Input.get_axis("ui_left", "ui_right")
		
		# Correção do bug de apertar as duas teclas
		if direction == 0:
			if Input.is_action_pressed("ui_right"): direction = 1
			elif Input.is_action_pressed("ui_left"): direction = -1

		if direction != 0:
			velocity.x = direction * SPEED
			anim.flip_h = (direction < 0)
			if is_on_floor():
				anim.play("walk")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor():
				anim.play("idle")
	else:
		# Se está deslizando, mantém a velocidade constante na direção que estava
		velocity.x = (-SLIDE_SPEED if anim.flip_h else SLIDE_SPEED)

	move_and_slide()

func iniciar_slide():
	esta_deslizando = true
	anim.play("slide") # Certifique-se de ter essa animação!
	tocar_fumaca("pulo") # Reutiliza fumaça para o efeito visual

# Função chamada quando QUALQUER animação do personagem termina
func _on_anim_finished():
	if anim.animation == "slide":
		esta_deslizando = false

func tocar_fumaca(nome_anim):
	if fumaca:
		fumaca.global_position = global_position
		fumaca.show()
		fumaca.play(nome_anim)

func _on_fumaca_animation_finished() -> void:
	if fumaca:
		fumaca.hide()
