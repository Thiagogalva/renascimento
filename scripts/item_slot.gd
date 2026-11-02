class_name ItemSlot
extends RefCounted

## Representa a pilha de um item dentro de um slot de inventário.

var item: ItemDefinition = null
var quantity: int = 0

func _init(p_item: ItemDefinition = null, p_quantity: int = 0) -> void:
	item = p_item
	quantity = p_quantity

func is_empty() -> bool:
	return item == null or quantity <= 0

func can_stack_with(other_item: ItemDefinition) -> bool:
	if is_empty():
		return true
	return item.id == other_item.id and quantity < item.max_stack

func get_free_space() -> int:
	if is_empty():
		return 999
	return maxi(0, item.max_stack - quantity)
