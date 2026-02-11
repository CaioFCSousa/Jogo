extends Node
class_name MorteRespawn_SubComp

@export var local_respawn : Node2D
@export var vida_comp : Vida_Comp
@export var tempo : Timer
var dono : CharacterBody2D # no caso esse é corpo do personagem

func _ready() -> void:
	if vida_comp == null:
		vida_comp = $".."
	dono = vida_comp.dono
	vida_comp.connect("morreu", respawnar)
	tempo.connect("timeout", aparecer)

func respawnar():
	print("dono")
	dono.visible = false
	dono.set_physics_process(false)
	dono.set_collision_mask_value(2, false)
	tempo.start()
	pass

func aparecer():
	dono.set_physics_process(true)
	vida_comp.curar_toda_vida()
	dono.set_collision_mask_value(2, true)
	dono.visible = true
	dono.position = local_respawn.position
