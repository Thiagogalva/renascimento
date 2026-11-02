class_name PlayerController
extends CharacterBody2D

## Controlador do jogador com movimentação isométrica 2:1 e detector de interação.

signal interaction_triggered(target: Interactable)

@export var move_speed: float = 200.0
@export var isometric_aspect_ratio: float = 0.5

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_detector: Area2D = $InteractionDetector
@onready var inventory: Inventory = $Inventory

var nearby_interactables: Array[Interactable] = []
var current_target: Interactable = null

func _ready() -> void:
	if interaction_detector:
		interaction_detector.area_entered.connect(_on_interaction_area_entered)
		interaction_detector.area_exited.connect(_on_interaction_area_exited)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_update_nearest_interactable()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if current_target != null:
			current_target.trigger_interaction(self)
			interaction_triggered.emit(current_target)

func _handle_movement(delta: float) -> void:
	var raw_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if raw_input != Vector2.ZERO:
		var move_dir: Vector2 = Vector2(raw_input.x, raw_input.y * isometric_aspect_ratio).normalized()
		velocity = move_dir * move_speed
		
		if sprite:
			if raw_input.x < 0:
				sprite.flip_h = true
			elif raw_input.x > 0:
				sprite.flip_h = false
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * 8.0 * delta)
		
	move_and_slide()

func _update_nearest_interactable() -> void:
	if nearby_interactables.is_empty():
		_set_current_target(null)
		return
		
	var nearest: Interactable = null
	var shortest_dist_sq: float = INF
	var player_pos: Vector2 = global_position
	
	for item in nearby_interactables:
		if not is_instance_valid(item):
			continue
		var dist_sq: float = player_pos.distance_squared_to(item.global_position)
		if dist_sq < shortest_dist_sq:
			shortest_dist_sq = dist_sq
			nearest = item
			
	_set_current_target(nearest)

func _set_current_target(new_target: Interactable) -> void:
	if current_target == new_target:
		return
		
	if current_target != null and is_instance_valid(current_target):
		current_target.set_focused(false)
		
	current_target = new_target
	
	if current_target != null and is_instance_valid(current_target):
		current_target.set_focused(true)

func _on_interaction_area_entered(area: Area2D) -> void:
	if area is Interactable:
		if not nearby_interactables.has(area):
			nearby_interactables.append(area)

func _on_interaction_area_exited(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactables.erase(area)
		if current_target == area:
			_set_current_target(null)
