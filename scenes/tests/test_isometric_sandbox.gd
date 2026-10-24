extends Node2D

## Cena de Teste e Validação Isométrica (BK-005)
## Valida a grade 2:1, ordenação visual Y-Sort, colisão na base e câmera móvel.

const TILE_WIDTH: float = 128.0
const TILE_HEIGHT: float = 64.0
const GRID_SIZE: int = 16

const TILE_TEXTURE = preload("res://assets/sprites/iso_ground_tile.svg")
const OBSTACLE_SCENE = preload("res://scenes/entities/test_obstacle.tscn")
const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")

@onready var ground_container: Node2D = $Ground
@onready var entities_container: Node2D = $Entities
@onready var info_label: Label = $UI/PanelContainer/MarginContainer/VBoxContainer/InfoLabel

var player: PlayerController = null

func _ready() -> void:
	_generate_isometric_ground()
	_spawn_obstacles()
	_spawn_player()
	_create_world_boundaries()

func _process(_delta: float) -> void:
	if player and info_label:
		var pos: Vector2 = player.global_position
		var fps: int = int(Engine.get_frames_per_second())
		info_label.text = "FPS: %d | Posição: (%.1f, %.1f) | Y-Sort: Ativo\nControles: W, A, S, D ou Setas" % [fps, pos.x, pos.y]

func _generate_isometric_ground() -> void:
	for gx in range(GRID_SIZE):
		for gy in range(GRID_SIZE):
			var tile: Sprite2D = Sprite2D.new()
			tile.texture = TILE_TEXTURE
			tile.position = _grid_to_screen(gx, gy)
			tile.centered = true
			ground_container.add_child(tile)

func _spawn_obstacles() -> void:
	# Posições de pilares estrategicamente distribuídas na grade para testar sobreposição
	var obstacle_grid_positions: Array[Vector2i] = [
		Vector2i(6, 6),
		Vector2i(8, 7),
		Vector2i(7, 9),
		Vector2i(9, 9),
		Vector2i(10, 8),
		Vector2i(5, 9),
		Vector2i(8, 11)
	]
	
	for gpos in obstacle_grid_positions:
		var obstacle: Node2D = OBSTACLE_SCENE.instantiate()
		obstacle.position = _grid_to_screen(gpos.x, gpos.y)
		entities_container.add_child(obstacle)

func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	# Inicia o jogador no centro da ilha isométrica
	player.position = _grid_to_screen(GRID_SIZE / 2, GRID_SIZE / 2)
	entities_container.add_child(player)
	
	# Anexa câmera inteligente ao jogador
	var camera: Camera2D = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.zoom = Vector2(1.2, 1.2)
	player.add_child(camera)

func _create_world_boundaries() -> void:
	# Cria 4 paredes delimitadoras em losango ao redor da grade 2:1
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
