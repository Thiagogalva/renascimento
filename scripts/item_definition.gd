class_name ItemDefinition
extends Resource

## Definição técnica de um item serializável no Godot (.tres).
## Desacoplada de lógica de apresentação e alinhada à especificação BK-003 / BK-011.

enum Category {
	RAW,
	CHEMICAL,
	TOOL,
	COMPOUND,
	CONSUMABLE
}

@export var id: StringName = &"item.raw.flint"
@export var display_name: String = "Sílex"
@export_multiline var description: String = "Pedra silicosa dura e cristalina. Produz faíscas eficientes ao atrito mecânico."
@export var category: Category = Category.RAW
@export var icon: Texture2D = null
@export var max_stack: int = 50
@export var weight: float = 0.5
@export var is_quest_item: bool = false
@export var is_pvp_lootable: bool = true
