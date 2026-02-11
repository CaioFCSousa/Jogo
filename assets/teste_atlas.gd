extends  Sprite2D

var posi : Vector2 
var espaco : Vector2
@export var texturaa : AtlasTexture


func _ready() -> void:
	espaco = texturaa.get_size()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		posi = Input.get_vector("ui_left","ui_right","ui_up","ui_down") * espaco + posi
		posi = Vector2( clamp(posi.x,0,100), clamp(posi.y,0,100))
		texturaa.region = Rect2(posi, espaco)
		print(texturaa.region)

	
