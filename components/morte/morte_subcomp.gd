extends Node
class_name MorteSimples_SubComp

"""
!!!! ESSE COMPONETE FAZ QUE O OBJETO SUMA QUANDO CHEGAR A ZERO !!!!
"""

@export var vida_comp : Vida_Comp

func _ready() -> void:
	if vida_comp == null:
		vida_comp = $".."
	vida_comp.connect("morreu", morrer)

func morrer():
	vida_comp.dono.set_process(false)
	vida_comp.dono.set_physics_process(false)
	vida_comp.dono.queue_free()
	pass
