class_name PlayerController
extends CharacterBody2D

## Controlador de movimentação do jogador para perspectiva isométrica 2D.
## Projetado para movimentação responsiva e ordenação de profundidade Y-Sort.

@export var move_speed: float = 200.0
@export var isometric_aspect_ratio: float = 0.5

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	var raw_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if raw_input != Vector2.ZERO:
		# Em projeção isométrica 2:1, a componente vertical tem metade da escala do plano cartesiano
		var move_dir: Vector2 = Vector2(raw_input.x, raw_input.y * isometric_aspect_ratio).normalized()
		velocity = move_dir * move_speed
		
		# Inversão visual horizontal de acordo com o sentido de deslocamento
		if sprite:
			if raw_input.x < 0:
				sprite.flip_h = true
			elif raw_input.x > 0:
				sprite.flip_h = false
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * 8.0 * delta)
		
	move_and_slide()
