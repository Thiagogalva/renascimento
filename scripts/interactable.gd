class_name Interactable
extends Area2D

## Componente base reutilizável para objetos interativos no mundo do jogo.
## Gerencia detecção de proximidade, prompt visual flutuante e disparo de evento de interação.

signal focused()
signal unfocused()
signal interacted(initiator: Node2D)

@export var interaction_title: String = "Inspecionar"
@export var interaction_key_prompt: String = "E"
@export var interaction_id: StringName = &"generic"
@export_multiline var scientific_log_entry: String = ""

@export var prompt_vertical_offset: float = -65.0

var is_focused: bool = false
var _prompt_container: Node2D = null
var _prompt_label: Label = null

func _ready() -> void:
	# Define a camada física de interação (Camada 2 por convenção)
	collision_layer = 2
	collision_mask = 0
	_setup_floating_prompt()

func _setup_floating_prompt() -> void:
	_prompt_container = Node2D.new()
	_prompt_container.position = Vector2(0, prompt_vertical_offset)
	_prompt_container.visible = false
	_prompt_container.z_index = 10
	add_child(_prompt_container)
	
	var panel: PanelContainer = PanelContainer.new()
	panel.anchors_preset = Control.PRESET_CENTER
	panel.custom_minimum_size = Vector2(80, 24)
	
	_prompt_label = Label.new()
	_prompt_label.text = "[%s] %s" % [interaction_key_prompt, interaction_title]
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prompt_label.add_theme_font_size_override("font_size", 11)
	
	panel.add_child(_prompt_label)
	_prompt_container.add_child(panel)

func set_focused(value: bool) -> void:
	if is_focused == value:
		return
	is_focused = value
	
	if _prompt_container:
		_prompt_container.visible = is_focused
		
	if is_focused:
		focused.emit()
	else:
		unfocused.emit()

func trigger_interaction(initiator: Node2D) -> void:
	interacted.emit(initiator)
