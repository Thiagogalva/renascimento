extends Node2D

## Cena de Teste e Validação Isométrica e Interação (BK-005, BK-008, BK-009)
## Valida a grade 2:1, ordenação visual Y-Sort, colisão na base, câmera móvel e sistema de interação.

const TILE_WIDTH: float = 128.0
const TILE_HEIGHT: float = 64.0
const GRID_SIZE: int = 16

const TILE_TEXTURE = preload("res://assets/sprites/iso_ground_tile.svg")
const OBSTACLE_SCENE = preload("res://scenes/entities/test_obstacle.tscn")
const STATUE_SCENE = preload("res://scenes/entities/petrified_statue.tscn")
const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")

@onready var ground_container: Node2D = $Ground
@onready var entities_container: Node2D = $Entities
@onready var info_label: Label = $UI/PanelContainer/MarginContainer/VBoxContainer/InfoLabel
@onready var dialogue_panel: PanelContainer = $UI/DialoguePanel
@onready var dialogue_title: Label = $UI/DialoguePanel/MarginContainer/VBoxContainer/DialogueTitle
@onready var dialogue_text: Label = $UI/DialoguePanel/MarginContainer/VBoxContainer/DialogueText

var player: PlayerController = null
var _last_interaction_target: Interactable = null

func _ready() -> void:
	_generate_isometric_ground()
	_spawn_obstacles()
	_spawn_petrified_statue()
	_spawn_player()
	_create_world_boundaries()

func _process(_delta: float) -> void:
	if player and info_label:
		var pos: Vector2 = player.global_position
		var fps: int = int(Engine.get_frames_per_second())
		var target_info: String = "Nenhum"
		if player.current_target:
			target_info = player.current_target.interaction_title
		info_label.text = "FPS: %d | Posição: (%.1f, %.1f) | Alvo próximo: %s\nControles: [W,A,S,D] mover | [E] interagir / inspecionar" % [fps, pos.x, pos.y, target_info]

func _generate_isometric_ground() -> void:
	for gx in range(GRID_SIZE):
		for gy in range(GRID_SIZE):
			var tile: Sprite2D = Sprite2D.new()
			tile.texture = TILE_TEXTURE
			tile.position = _grid_to_screen(gx, gy)
			tile.centered = true
			ground_container.add_child(tile)

func _spawn_obstacles() -> void:
	var obstacle_grid_positions: Array[Vector2i] = [
		Vector2i(5, 5),
		Vector2i(8, 6),
		Vector2i(6, 9),
		Vector2i(10, 8),
		Vector2i(5, 10),
		Vector2i(9, 11)
	]
	
	for gpos in obstacle_grid_positions:
		var obstacle: Node2D = OBSTACLE_SCENE.instantiate()
		obstacle.position = _grid_to_screen(gpos.x, gpos.y)
		entities_container.add_child(obstacle)

func _spawn_petrified_statue() -> void:
	var statue: Node2D = STATUE_SCENE.instantiate()
	# Posiciona a estátua em destaque no centro-norte da clareira
	statue.position = _grid_to_screen(8, 8)
	entities_container.add_child(statue)

func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	player.position = _grid_to_screen(8, 10)
	entities_container.add_child(player)
	
	var camera: Camera2D = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.zoom = Vector2(1.2, 1.2)
	player.add_child(camera)
	
	player.interaction_triggered.connect(_on_player_interaction_triggered)

func _on_player_interaction_triggered(target: Interactable) -> void:
	if dialogue_panel.visible and _last_interaction_target == target:
		_close_dialogue()
		return
		
	_last_interaction_target = target
	dialogue_title.text = "[ %s ]" % target.interaction_title
	if target.scientific_log_entry != "":
		dialogue_text.text = target.scientific_log_entry
	else:
		dialogue_text.text = "Objeto interativo registrado no sistema."
	dialogue_panel.visible = true

func _close_dialogue() -> void:
	dialogue_panel.visible = false
	_last_interaction_target = null

func _create_world_boundaries() -> void:
	var static_body: StaticBody2D = StaticBody2D.new()
	add_child(static_body)
	
	var top_vertex: Vector2 = _grid_to_screen(0, 0) + Vector2(0, -TILE_HEIGHT * 0.5)
	var right_vertex: Vector2 = _grid_to_screen(GRID_SIZE - 1, 0) + Vector2(TILE_WIDTH * 0.5, 0)
	var bottom_vertex: Vector2 = _grid_to_screen(GRID_SIZE - 1, GRID_SIZE - 1) + Vector2(0, TILE_HEIGHT * 0.5)
	var left_vertex: Vector2 = _grid_to_screen(0, GRID_SIZE - 1) + Vector2(-TILE_WIDTH * 0.5, 0)
	
	var vertices: Array[Vector2] = [top_vertex, right_vertex, bottom_vertex, left_vertex, top_vertex]
	for i in range(vertices.size() - 1):
		var col: CollisionShape2D = CollisionShape2D.new()
		var seg: SegmentShape2D = SegmentShape2D.new()
		seg.a = vertices[i]
		seg.b = vertices[i + 1]
		col.shape = seg
		static_body.add_child(col)

func _grid_to_screen(gx: int, gy: int) -> Vector2:
	var sx: float = (gx - gy) * (TILE_WIDTH * 0.5)
	var sy: float = (gx + gy) * (TILE_HEIGHT * 0.5)
	return Vector2(sx, sy)
