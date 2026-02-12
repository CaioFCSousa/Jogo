extends CharacterBody2D

@onready var colison : Array[RayCast2D] = [$dir, $esq]

func _ready() -> void:
	print(colison[0], colison[1])
