class_name Inventory
extends Node

## Gerenciador do inventário do jogador e recipientes com validação estrita de integridade.
## Previne perdas, duplicações e assegura atomicidade em operações de transferência e persistência.

signal item_added(item: ItemDefinition, amount: int)
signal item_removed(item: ItemDefinition, amount: int)
signal inventory_updated()

@export var max_slots: int = 8

var slots: Array[ItemSlot] = []

func _ready() -> void:
	if slots.is_empty():
		_initialize_slots()

func _initialize_slots() -> void:
	slots.clear()
	for i in range(max_slots):
		slots.append(ItemSlot.new())

func clear() -> void:
	for slot in slots:
		slot.clear()
	inventory_updated.emit()

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
				slot.clear()
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

func get_total_item_count() -> int:
	var total: int = 0
	for slot in slots:
		if not slot.is_empty():
			total += slot.quantity
	return total

func has_item(item_id: StringName, amount: int = 1) -> bool:
	if amount <= 0:
		return true
	return get_item_count(item_id) >= amount

func is_full() -> bool:
	for slot in slots:
		if slot.is_empty():
			return false
	return true

func is_valid_slot_index(index: int) -> bool:
	return index >= 0 and index < slots.size()

## Troca o conteúdo de dois slots de posição de forma segura.
func swap_slots(from_idx: int, to_idx: int) -> bool:
	if not is_valid_slot_index(from_idx) or not is_valid_slot_index(to_idx):
		return false
	if from_idx == to_idx:
		return true
		
	var temp_slot: ItemSlot = slots[from_idx]
	slots[from_idx] = slots[to_idx]
	slots[to_idx] = temp_slot
	inventory_updated.emit()
	return true

## Divide ou move quantidade de um slot para outro.
func split_stack(from_idx: int, to_idx: int, amount: int) -> bool:
	if not is_valid_slot_index(from_idx) or not is_valid_slot_index(to_idx):
		return false
	if from_idx == to_idx or amount <= 0:
		return false
		
	var src: ItemSlot = slots[from_idx]
	if src.is_empty() or src.quantity < amount:
		return false
		
	var dest: ItemSlot = slots[to_idx]
	if dest.is_empty():
		dest.item = src.item
		dest.quantity = amount
		src.quantity -= amount
		if src.quantity <= 0:
			src.clear()
		inventory_updated.emit()
		return true
	elif dest.item.id == src.item.id:
		var space: int = dest.item.max_stack - dest.quantity
		if space <= 0:
			return false
		var to_move: int = mini(amount, space)
		dest.quantity += to_move
		src.quantity -= to_move
		if src.quantity <= 0:
			src.clear()
		inventory_updated.emit()
		return true
		
	return false

## Transfere atomicamente uma quantidade de um item para outro inventário.
## Garante conservação estrita: nenhum item é perdido ou duplicado se o alvo estiver cheio.
## Retorna a quantidade transferida.
func transfer_item_to(target_inv: Inventory, item_id: StringName, amount: int) -> int:
	if target_inv == null or target_inv == self or amount <= 0:
		return 0
		
	var available: int = get_item_count(item_id)
	if available <= 0:
		return 0
		
	var to_transfer: int = mini(amount, available)
	
	# Encontra a definição do item a partir do primeiro slot encontrado
	var item_def: ItemDefinition = null
	for slot in slots:
		if not slot.is_empty() and slot.item.id == item_id:
			item_def = slot.item
			break
			
	if item_def == null:
		return 0
		
	# Tenta adicionar no inventário alvo
	var leftover: int = target_inv.add_item(item_def, to_transfer)
	var transferred: int = to_transfer - leftover
	
	# Remove exatamente a quantidade que coube no alvo
	if transferred > 0:
		remove_item_by_id(item_id, transferred)
		
	return transferred

## Serializa o estado dos slots para armazenamento em save/dicionário.
func serialize() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(slots.size()):
		var slot: ItemSlot = slots[i]
		if not slot.is_empty():
			result.append({
				"slot": i,
				"item_id": str(slot.item.id),
				"quantity": slot.quantity
			})
	return result

## Desserializa e restaura o inventário a partir de dados brutos com validação defensiva.
## Descarta slots corrompidos ou com IDs não catalogados com segurança, sem corromper a árvore.
func deserialize(data: Variant, item_catalog: Dictionary) -> bool:
	if not (data is Array):
		return false
		
	clear()
	
	for entry in data:
		if not (entry is Dictionary):
			continue
			
		var slot_idx: int = entry.get("slot", -1)
		var item_id_str: String = entry.get("item_id", "")
		var qty: int = entry.get("quantity", 0)
		
		if not is_valid_slot_index(slot_idx) or qty <= 0 or item_id_str == "":
			continue
			
		var item_id: StringName = StringName(item_id_str)
		if not item_catalog.has(item_id):
			push_warning("Inventory.deserialize: item_id '%s' não encontrado no catálogo. Slot ignorado para segurança." % item_id_str)
			continue
			
		var item_def: ItemDefinition = item_catalog[item_id]
		var safe_qty: int = mini(qty, item_def.max_stack)
		
		slots[slot_idx].item = item_def
		slots[slot_idx].quantity = safe_qty
		
	inventory_updated.emit()
	return true
