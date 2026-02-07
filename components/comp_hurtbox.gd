extends Area2D
class_name comp_hurtbox

@export_group("configurações de area recebe dano")
@export var comp_vida : comp_Vida

signal dano_recebido(dano : float)

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox : comp_hitbox) -> void:
	print(hitbox)
	if hitbox != null:
		print("tomei dano (hurtbox) ",hitbox.dano)
		comp_vida.tomar_dano(hitbox.dano)
		pass
	
