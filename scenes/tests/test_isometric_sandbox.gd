extends Node2D

## Cena de Teste e Validação Isométrica — Fase 1, 2, 3 e 3b (Fabricação)
## Valida: grade 2:1, Y-Sort, interação, inventário com coleta e fabricação básica.

const TILE_WIDTH: float = 128.0
const TILE_HEIGHT: float = 64.0
const GRID_SIZE: int = 16

const TILE_TEXTURE = preload("res://assets/sprites/iso_ground_tile.svg")
const OBSTACLE_SCENE = preload("res://scenes/entities/test_obstacle.tscn")
const STATUE_SCENE = preload("res://scenes/entities/petrified_statue.tscn")
const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")
const COLLECTIBLE_SCENE = preload("res://scenes/entities/collectible_item.tscn")
const BENCH_SCENE = preload("res://scenes/entities/crafting_bench.tscn")

const ITEM_FLINT = preload("res://data/items/flint.tres")
const ITEM_CLAY = preload("res://data/items/clay.tres")
const ITEM_SALTPETER = preload("res://data/items/saltpeter.tres")
const ITEM_CLAY_BRICK = preload("res://data/items/clay_brick.tres")
const ITEM_STONE_FLAKES = preload("res://data/items/stone_flakes.tres")

const RECIPE_CLAY_BRICK = preload("res://data/recipes/clay_brick.tres")
const RECIPE_FLINT_KNAPPING = preload("res://data/recipes/flint_knapping.tres")

@onready var ground_container: Node2D = $Ground
@onready var entities_container: Node2D = $Entities
@onready var info_label: Label = $UI/PanelContainer/MarginContainer/VBoxContainer/InfoLabel
@onready var dialogue_panel: PanelContainer = $UI/DialoguePanel
@onready var dialogue_title: Label = $UI/DialoguePanel/MarginContainer/VBoxContainer/DialogueTitle
@onready var dialogue_text: Label = $UI/DialoguePanel/MarginContainer/VBoxContainer/DialogueText
@onready var slots_hbox: HBoxContainer = $UI/HotbarPanel/MarginContainer/SlotsHBox
@onready var crafting_panel: PanelContainer = $UI/CraftingPanel
@onready var crafting_title: Label = $UI/CraftingPanel/MarginContainer/VBoxContainer/CraftingTitle
@onready var recipe_list: VBoxContainer = $UI/CraftingPanel/MarginContainer/VBoxContainer/RecipeList
@onready var craft_button: Button = $UI/CraftingPanel/MarginContainer/VBoxContainer/CraftButton
@onready var craft_feedback: Label = $UI/CraftingPanel/MarginContainer/VBoxContainer/CraftFeedback

var player: PlayerController = null
var _last_interaction_target: Interactable = null
var _slot_ui_elements: Array[Dictionary] = []

# Estado da bancada ativa
var _active_station: CraftingStation = null
var _selected_recipe_index: int = -1
var _recipe_labels: Array[Label] = []


func _ready() -> void:
	_generate_isometric_ground()
	_spawn_obstacles()
	_spawn_petrified_statue()
	_spawn_collectibles()
	_spawn_crafting_bench()
	_spawn_player()
	_create_world_boundaries()
	_setup_hotbar_ui()
	craft_button.pressed.connect(_on_craft_button_pressed)


func _process(_delta: float) -> void:
	if player and info_label:
		var pos: Vector2 = player.global_position
		var fps: int = int(Engine.get_frames_per_second())
		var target_info: String = "Nenhum"
		if player.current_target:
			target_info = player.current_target.interaction_title

		var inv_count: int = 0
		if player.inventory:
			for s in player.inventory.slots:
				if not s.is_empty():
					inv_count += 1

		info_label.text = "FPS: %d | Posição: (%.1f, %.1f) | Mochila: %d/%d slots\nAlvo próximo: %s | [E] Interagir/Coletar/Fabricar" % [
			fps, pos.x, pos.y, inv_count, player.inventory.max_slots if player.inventory else 8, target_info
		]

	# Actualiza destaque das receitas se o painel estiver aberto
	if crafting_panel.visible and _active_station and player and player.inventory:
		_refresh_recipe_highlights()


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
	statue.position = _grid_to_screen(8, 8)
	entities_container.add_child(statue)


func _spawn_collectibles() -> void:
	var items_to_spawn: Array[Dictionary] = [
		{ "resource": ITEM_FLINT, "amount": 2, "pos": Vector2i(7, 6) },
		{ "resource": ITEM_FLINT, "amount": 1, "pos": Vector2i(9, 7) },
		{ "resource": ITEM_CLAY, "amount": 3, "pos": Vector2i(10, 6) },
		{ "resource": ITEM_CLAY, "amount": 2, "pos": Vector2i(11, 8) },
		{ "resource": ITEM_SALTPETER, "amount": 1, "pos": Vector2i(6, 8) },
		{ "resource": ITEM_SALTPETER, "amount": 2, "pos": Vector2i(10, 10) }
	]
	for spawn_data in items_to_spawn:
		var col_node: CollectibleItem = COLLECTIBLE_SCENE.instantiate()
		col_node.item_resource = spawn_data["resource"]
		col_node.amount = spawn_data["amount"]
		var gpos: Vector2i = spawn_data["pos"]
		col_node.position = _grid_to_screen(gpos.x, gpos.y)
		entities_container.add_child(col_node)


func _spawn_crafting_bench() -> void:
	var bench: Node2D = BENCH_SCENE.instantiate()
	bench.position = _grid_to_screen(7, 10)
	entities_container.add_child(bench)

	# Configura o CraftingStation com receitas e catálogo de itens
	var station: CraftingStation = bench.get_node("CraftingStation")
	station.available_recipes = [RECIPE_CLAY_BRICK, RECIPE_FLINT_KNAPPING]
	station.register_item(ITEM_CLAY_BRICK)
	station.register_item(ITEM_STONE_FLAKES)
	station.craft_completed.connect(_on_craft_completed)
	station.craft_failed.connect(_on_craft_failed)

	# Liga o Interactable da bancada para abrir o painel de fabricação
	var interactable: Interactable = bench.get_node("Interactable")
	interactable.interacted.connect(_on_bench_interacted.bind(station))


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
	if player.inventory:
		player.inventory.inventory_updated.connect(_update_hotbar)


func _setup_hotbar_ui() -> void:
	_slot_ui_elements.clear()
	for child in slots_hbox.get_children():
		child.queue_free()

	var max_slots: int = 8
	if player and player.inventory:
		max_slots = player.inventory.max_slots

	for i in range(max_slots):
		var slot_panel: PanelContainer = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(46, 46)

		var icon_rect: TextureRect = TextureRect.new()
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(36, 36)
		slot_panel.add_child(icon_rect)

		var qty_label: Label = Label.new()
		qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		qty_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		qty_label.add_theme_font_size_override("font_size", 11)
		slot_panel.add_child(qty_label)

		slots_hbox.add_child(slot_panel)
		_slot_ui_elements.append({
			"panel": slot_panel,
			"icon": icon_rect,
			"label": qty_label
		})

	_update_hotbar()


func _update_hotbar() -> void:
	if not player or not player.inventory:
		return

	var slots_data: Array[ItemSlot] = player.inventory.slots
	for i in range(_slot_ui_elements.size()):
		var ui_dict: Dictionary = _slot_ui_elements[i]
		var icon_rect: TextureRect = ui_dict["icon"]
		var label: Label = ui_dict["label"]

		if i < slots_data.size():
			var slot: ItemSlot = slots_data[i]
			if not slot.is_empty():
				icon_rect.texture = slot.item.icon
				label.text = str(slot.quantity) if slot.quantity > 1 else ""
			else:
				icon_rect.texture = null
				label.text = ""
		else:
			icon_rect.texture = null
			label.text = ""

	# Atualiza realce das receitas se painel de fabricação estiver aberto
	if crafting_panel.visible:
		_refresh_recipe_highlights()


# ──────────────────────────────────────────────
# Fabricação
# ──────────────────────────────────────────────

func _on_bench_interacted(_initiator: Node2D, station: CraftingStation) -> void:
	# Alterna o painel de fabricação
	if crafting_panel.visible and _active_station == station:
		_close_crafting_panel()
		return

	_active_station = station
	_open_crafting_panel(station)


func _open_crafting_panel(station: CraftingStation) -> void:
	crafting_panel.visible = true
	dialogue_panel.visible = false
	crafting_title.text = "[ %s ]" % station.station_id

	# Limpa a lista anterior
	for child in recipe_list.get_children():
		child.queue_free()
	_recipe_labels.clear()
	_selected_recipe_index = -1
	craft_button.disabled = true
	craft_feedback.text = ""

	# Cria um label por receita
	var recipes: Array[RecipeDefinition] = station.get_available_recipes_for(
		player.inventory if player else Inventory.new()
	)

	for i in range(recipes.size()):
		var recipe: RecipeDefinition = recipes[i]
		var lbl: Label = Label.new()
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		recipe_list.add_child(lbl)
		_recipe_labels.append(lbl)

		# Seleciona receita ao clicar
		var idx: int = i
		lbl.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed:
				_select_recipe(idx)
		)

	_refresh_recipe_highlights()


func _select_recipe(index: int) -> void:
	_selected_recipe_index = index
	craft_feedback.text = ""
	_refresh_recipe_highlights()


func _refresh_recipe_highlights() -> void:
	if not _active_station or not player or not player.inventory:
		return

	var recipes: Array[RecipeDefinition] = _active_station.get_available_recipes_for(player.inventory)

	for i in range(_recipe_labels.size()):
		if i >= recipes.size():
			break
		var recipe: RecipeDefinition = recipes[i]
		var can: bool = recipe.can_craft(player.inventory)
		var lbl: Label = _recipe_labels[i]

		var inputs_text: String = ""
		for entry in recipe.inputs:
			var iid: StringName = StringName(entry.get("item_id", ""))
			var need: int = entry.get("amount", 0)
			var have: int = player.inventory.get_item_count(iid)
			inputs_text += "  • %s: %d/%d\n" % [str(iid).replace("item.raw.", ""), have, need]

		lbl.text = "[%s] %s (+%d)\n%s" % [
			"✓" if can else "✗",
			recipe.display_name,
			recipe.output_amount,
			inputs_text.rstrip("\n")
		]

		if i == _selected_recipe_index:
			lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		elif can:
			lbl.add_theme_color_override("font_color", Color(0.85, 1.0, 0.85))
		else:
			lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))

	# Habilita botão só se a receita selecionada puder ser fabricada
	var can_craft_selected: bool = false
	if _selected_recipe_index >= 0 and _selected_recipe_index < recipes.size():
		can_craft_selected = recipes[_selected_recipe_index].can_craft(player.inventory)
	craft_button.disabled = not can_craft_selected


func _on_craft_button_pressed() -> void:
	if not _active_station or not player or not player.inventory:
		return
	var recipes: Array[RecipeDefinition] = _active_station.get_available_recipes_for(player.inventory)
	if _selected_recipe_index < 0 or _selected_recipe_index >= recipes.size():
		return
	_active_station.try_craft(recipes[_selected_recipe_index], player.inventory)


func _on_craft_completed(recipe: RecipeDefinition, _output_item: ItemDefinition, amount: int) -> void:
	craft_feedback.text = "✓ Fabricado: %s ×%d" % [recipe.display_name, amount]
	craft_feedback.add_theme_color_override("font_color", Color(0.6, 0.95, 0.6))
	_refresh_recipe_highlights()


func _on_craft_failed(recipe: RecipeDefinition, reason: String) -> void:
	craft_feedback.text = "✗ %s: %s" % [recipe.display_name, reason]
	craft_feedback.add_theme_color_override("font_color", Color(0.95, 0.5, 0.5))


func _close_crafting_panel() -> void:
	crafting_panel.visible = false
	_active_station = null
	_selected_recipe_index = -1


# ──────────────────────────────────────────────
# Interação genérica (log científico)
# ──────────────────────────────────────────────

func _on_player_interaction_triggered(target: Interactable) -> void:
	# Se for a bancada, ignora — o sinal da bancada cuida do painel de fabricação
	if target.interaction_id == &"structure.station.crafting_bench":
		return

	if dialogue_panel.visible and _last_interaction_target == target:
		_close_dialogue()
		return

	_last_interaction_target = target
	dialogue_title.text = "[ %s ]" % target.interaction_title
	if target.scientific_log_entry != "":
		dialogue_text.text = target.scientific_log_entry
	else:
		dialogue_text.text = "Ação de interação concluída."
	dialogue_panel.visible = true
	crafting_panel.visible = false


func _close_dialogue() -> void:
	dialogue_panel.visible = false
	_last_interaction_target = null


# ──────────────────────────────────────────────
# Mundo
# ──────────────────────────────────────────────

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
