extends Window

@onready var texto = $Control/VBoxContainer/Label

func atualizar_texto(valor : String):
	texto.text = valor
