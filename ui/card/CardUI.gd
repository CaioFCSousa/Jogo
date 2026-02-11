@tool
extends Button
class_name CardUI

signal selecionada(habilidade: AbilityResource)

var habilidade_data: AbilityResource
var tween_flutuar: Tween
var tween_hover: Tween

@onready var visual_container: Control = $Visual 

func _ready():
	if Engine.is_editor_hint(): return
	
	flat = true 
	pivot_offset = size / 2
	
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	await get_tree().create_timer(randf_range(0, 0.5)).timeout
	iniciar_flutuacao()

func setup(data: AbilityResource):
	habilidade_data = data
	if has_node("LabelNome"): $LabelNome.text = data.nome
	
	for child in visual_container.get_children(): child.queue_free()
	
	var bounding_box = Vector2.ZERO
	for camada in data.camadas_custom:
		if camada == null or camada.textura == null: continue
		
		var tr = TextureRect.new()
		tr.texture = camada.textura
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.size = camada.tamanho
		tr.position = camada.posicao
		tr.scale = camada.escala
		tr.rotation_degrees = camada.rotate_degrees
		tr.pivot_offset = camada.tamanho / 2
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual_container.add_child(tr)

		var alcance_x = camada.posicao.x + (camada.tamanho.x * camada.escala.x)
		var alcance_y = camada.posicao.y + (camada.tamanho.y * camada.escala.y)
		if alcance_x > bounding_box.x: bounding_box.x = alcance_x
		if alcance_y > bounding_box.y: bounding_box.y = alcance_y

	if bounding_box != Vector2.ZERO:
		custom_minimum_size = bounding_box
		size = bounding_box
		visual_container.size = bounding_box
		pivot_offset = bounding_box / 2
		update_minimum_size()

# --- ANIMAÇÕES ---


func animar_selecao(alvo: Vector2):
	if tween_flutuar: tween_flutuar.kill()
	if tween_hover: tween_hover.kill()
	

	var pos_inicial = global_position

	set_as_top_level(true)
	global_position = pos_inicial
	

	var tw = create_tween().set_parallel(true)
	tw.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	

	tw.tween_property(self, "global_position", alvo - (size / 2), 0.6)
	
	# Aumenta um pouco e dá um brilho
	tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5).set_trans(Tween.TRANS_BACK)

	

	tw.set_parallel(false)
	tw.tween_interval(0.5)

func iniciar_flutuacao():
	if tween_flutuar: tween_flutuar.kill()
	tween_flutuar = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_flutuar.tween_property(visual_container, "position:y", -8, 1.5)
	tween_flutuar.tween_property(visual_container, "position:y", 0, 1.5)

func _on_mouse_entered():
	if disabled: return
	if tween_flutuar: tween_flutuar.pause()
	if tween_hover: tween_hover.kill()
	
	tween_hover = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween_hover.tween_property(visual_container, "position:y", -30, 0.25)
	z_index = 10

func _on_mouse_exited():
	if disabled: return
	if tween_hover: tween_hover.kill()
	
	tween_hover = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween_hover.tween_property(visual_container, "position:y", 0, 0.25)
	
	tween_hover.tween_callback(func():
		z_index = 0
		if tween_flutuar: tween_flutuar.play()
	)

func _on_pressed():
	if Engine.is_editor_hint(): return
	disabled = true
	selecionada.emit(habilidade_data)

func sumir_carta():
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.chain().finished.connect(queue_free)
