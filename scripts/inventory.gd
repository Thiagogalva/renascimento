class_name Inventory
extends Node

## Gerenciador do inventário do jogador com validação estrita de integridade.
## Previne perdas, duplicações e controla capacidades de empilhamento.

signal item_added(item: ItemDefinition, amount: int)
signal item_removed(item: ItemDefinition, amount: int)
signal inventory_updated()

@export var max_slots: int = 8

var slots: Array[ItemSlot] = []

func _ready() -> void:
	_initialize_slots()

func _initialize_slots() -> void:
	slots.clear()
	for i in range(max_slots):
		slots.append(ItemSlot.new())

func add_item(item_def: ItemDefinition, amount: int) -> int:
	if item_def == null or amount <= 0:
		return amount
		
	var remaining: int = amount
	
	# 1. Tenta empilhar em slots que já possuem o mesmo item
	for slot in slots:
		if not slot.is_empty() and slot.item.id == item_def.id:
			var space: int = slot.item.max_stack - slot.quantity
			if space > 0:
				var to_add: int = mini(remaining, space)
				slot.quantity += to_add
				remaining -= to_add
				if remaining <= 0:
					break
					
	# 2. Se sobrou, preenche slots vazios
	if remaining > 0:
		for slot in slots:
			if slot.is_empty():
				var to_add: int = mini(remaining, item_def.max_stack)
				slot.item = item_def
				slot.quantity = to_add
				remaining -= to_add
				if remaining <= 0:
					break
					
	var added: int = amount - remaining
	if added > 0:
		item_added.emit(item_def, added)
		inventory_updated.emit()
		
	return remaining

func remove_item_by_id(item_id: StringName, amount: int) -> bool:
	if amount <= 0 or get_item_count(item_id) < amount:
		return false
		
	var needed: int = amount
	for i in range(slots.size() - 1, -1, -1):
		var slot: ItemSlot = slots[i]
		if not slot.is_empty() and slot.item.id == item_id:
			var to_remove: int = mini(needed, slot.quantity)
			slot.quantity -= to_remove
			needed -= to_remove
			var ref_item: ItemDefinition = slot.item
			if slot.quantity <= 0:
				slot.item = null
				slot.quantity = 0
			item_removed.emit(ref_item, to_remove)
			if needed <= 0:
				break
				
	inventory_updated.emit()
	return true

func get_item_count(item_id: StringName) -> int:
	var total: int = 0
	for slot in slots:
		if not slot.is_empty() and slot.item.id == item_id:
			total += slot.quantity
	return total

func has_item(item_id: StringName, amount: int = 1) -> bool:
	return get_item_count(item_id) >= amount

func is_full() -> bool:
	for slot in slots:
		if slot.is_empty():
			return false
	return true
