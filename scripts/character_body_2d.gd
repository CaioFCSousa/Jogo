extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var controles : Dictionary = {"dir":"ui_d","esq":"ui_a","cim":"ui_w","bai":"ui_s"}

func _physics_process(delta: float) -> void:
	var direcaoVT := Input.get_vector(str(controles["esq"]), str(controles["dir"]), str(controles["cim"]), str(controles["bai"]))
	# print(direcaoVT)
	# direcaoY
	if direcaoVT:
		velocity.x = direcaoVT[0] * SPEED
		velocity.y = direcaoVT[1] * SPEED
	else:
		velocity.x = move_toward(velocity.x,0,SPEED)
		velocity.y = move_toward(velocity.y,0,SPEED)
	move_and_slide()
