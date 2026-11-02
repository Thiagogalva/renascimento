extends SceneTree

## Teste unitário headless de persistência, atomicidade e tolerância a falhas do Inventário (BK-015)
## Execução: Godot --headless --script tests/test_inventory_persistence.gd

var _results: Array[int] = [0, 0]  # [passed, failed]

func _assert_eq(label: String, got: Variant, expected: Variant) -> void:
	if got == expected:
		print("  ✅ PASS: ", label)
		_results[0] += 1
	else:
		print("  ❌ FAIL: ", label, " — esperado: ", expected, "  obtido: ", got)
		_results[1] += 1

func _assert_true(label: String, value: bool) -> void:
	_assert_eq(label, value, true)

func _assert_false(label: String, value: bool) -> void:
	_assert_eq(label, value, false)

func _init() -> void:
	print("=== TEST INVENTORY PERSISTENCE & FAULT TOLERANCE (BK-015) ===")
	
	# ──────────────────────────────────────────────────
	# Definições sintéticas de itens para teste
	# ──────────────────────────────────────────────────
	var clay: ItemDefinition = ItemDefinition.new()
	clay.id = &"item.raw.clay"
	clay.display_name = "Argila"
	clay.max_stack = 20

	var flint: ItemDefinition = ItemDefinition.new()
	flint.id = &"item.raw.flint"
	flint.display_name = "Sílex"
	flint.max_stack = 10

	var brick: ItemDefinition = ItemDefinition.new()
	brick.id = &"item.raw.clay_brick"
	brick.display_name = "Tijolo de Argila"
	brick.max_stack = 15

	var catalog: Dictionary = {
		clay.id: clay,
		flint.id: flint,
		brick.id: brick
	}

	# Inventários de teste
	var inv_a: Inventory = Inventory.new()
	inv_a.max_slots = 4
	get_root().add_child(inv_a)

	var inv_b: Inventory = Inventory.new()
	inv_b.max_slots = 3
	get_root().add_child(inv_b)

	await process_frame

	# ──────────────────────────────────────────────────
	# T01 — Serialização e Desserialização Íntegras
	# ──────────────────────────────────────────────────
	inv_a.add_item(clay, 15)
	inv_a.add_item(flint, 5)
	var serialized: Array[Dictionary] = inv_a.serialize()
	
	_assert_eq("T01 — 2 slots gravados na serialização", serialized.size(), 2)
	_assert_eq("T01 — slot 0 é clay com 15 un", serialized[0]["quantity"], 15)
	_assert_eq("T01 — slot 1 é flint com 5 un", serialized[1]["quantity"], 5)

	# Desserializa em inv_b
	var load_ok: bool = inv_b.deserialize(serialized, catalog)
	_assert_true("T01 — deserialize retorna true", load_ok)
	_assert_eq("T01 — inv_b restaurou 15 clay", inv_b.get_item_count(clay.id), 15)
	_assert_eq("T01 — inv_b restaurou 5 flint", inv_b.get_item_count(flint.id), 5)
	_assert_eq("T01 — total de itens no inv_b é 20", inv_b.get_total_item_count(), 20)

	# ──────────────────────────────────────────────────
	# T02 — Tolerância a Dados Corrompidos / Malformados
	# ──────────────────────────────────────────────────
	var corrupt_data: Array = [
		{ "slot": -1, "item_id": "item.raw.clay", "quantity": 10 },        # slot negativo
		{ "slot": 99, "item_id": "item.raw.clay", "quantity": 10 },        # slot fora do limite
		{ "slot": 0, "item_id": "", "quantity": 10 },                      # item_id vazio
		{ "slot": 1, "item_id": "item.raw.flint", "quantity": -5 },        # quantidade negativa
		{ "slot": 2, "item_id": "item.inexistente.hack", "quantity": 5 },  # item não registrado no catálogo
		"string_invalida_na_lista",                                        # elemento que não é dicionário
		{ "slot": 0, "item_id": "item.raw.clay", "quantity": 12 }          # entrada válida
	]
	
	var corrupt_ok: bool = inv_b.deserialize(corrupt_data, catalog)
	_assert_true("T02 — deserialize com dados corrompidos completa com segurança", corrupt_ok)
	_assert_eq("T02 — apenas a entrada válida foi aplicada (12 clay)", inv_b.get_item_count(clay.id), 12)
	_assert_eq("T02 — total de itens após carga defensiva é 12", inv_b.get_total_item_count(), 12)

	# ──────────────────────────────────────────────────
	# T03 — Limitação (Clamp) a max_stack em Dados Externos
	# ──────────────────────────────────────────────────
	var overflow_data: Array = [
		{ "slot": 0, "item_id": "item.raw.flint", "quantity": 999 } # flint max_stack é 10
	]
	inv_b.deserialize(overflow_data, catalog)
	_assert_eq("T03 — quantidade foi limitada ao max_stack (10)", inv_b.get_item_count(flint.id), 10)

	# ──────────────────────────────────────────────────
	# T04 — Atomicidade de Transferência: Sucesso Total
	# ──────────────────────────────────────────────────
	inv_a.clear()
	inv_b.clear()
	inv_a.add_item(clay, 8)
	
	var initial_total: int = inv_a.get_total_item_count() + inv_b.get_total_item_count()
	var transferred: int = inv_a.transfer_item_to(inv_b, clay.id, 5)
	var final_total: int = inv_a.get_total_item_count() + inv_b.get_total_item_count()
	
	_assert_eq("T04 — transfer_item_to transferiu 5 unidades", transferred, 5)
	_assert_eq("T04 — inv_a ficou com 3 clay", inv_a.get_item_count(clay.id), 3)
	_assert_eq("T04 — inv_b recebeu 5 clay", inv_b.get_item_count(clay.id), 5)
	_assert_eq("T04 — conservação de massa estrita (total antes == total depois)", final_total, initial_total)

	# ──────────────────────────────────────────────────
	# T05 — Atomicidade de Transferência: Transbordo / Sucesso Parcial
	# inv_b tem max_slots = 3. Vamos enchê-lo quase todo.
	# ──────────────────────────────────────────────────
	inv_b.clear()
	inv_b.add_item(flint, 10) # slot 0 cheio
	inv_b.add_item(brick, 15) # slot 1 cheio
	inv_b.add_item(clay, 18)  # slot 2 tem espaço para apenas +2 clay (max_stack = 20)
	_assert_true("T05 — inv_b está com todos os slots ocupados", inv_b.is_full())

	inv_a.clear()
	inv_a.add_item(clay, 10) # inv_a tem 10 clay

	var sum_before: int = inv_a.get_total_item_count() + inv_b.get_total_item_count()
	var partial_transfer: int = inv_a.transfer_item_to(inv_b, clay.id, 7) # tenta transferir 7, mas só cabem 2
	var sum_after: int = inv_a.get_total_item_count() + inv_b.get_total_item_count()

	_assert_eq("T05 — apenas 2 unidades foram aceitas pelo alvo", partial_transfer, 2)
	_assert_eq("T05 — inv_a reteve as 8 unidades restantes", inv_a.get_item_count(clay.id), 8)
	_assert_eq("T05 — inv_b agora tem 20 clay (lotado)", inv_b.get_item_count(clay.id), 20)
	_assert_eq("T05 — zero itens perdidos ou duplicados em transbordo", sum_after, sum_before)

	# ──────────────────────────────────────────────────
	# T06 — Transferência quando o Destino está Totalmente Lotado
	# ──────────────────────────────────────────────────
	sum_before = inv_a.get_total_item_count() + inv_b.get_total_item_count()
	var blocked_transfer: int = inv_a.transfer_item_to(inv_b, clay.id, 5)
	sum_after = inv_a.get_total_item_count() + inv_b.get_total_item_count()

	_assert_eq("T06 — 0 itens transferidos quando destino está cheio", blocked_transfer, 0)
	_assert_eq("T06 — inv_a manteve todas as suas 8 unidades", inv_a.get_item_count(clay.id), 8)
	_assert_eq("T06 — conservação intacta sem alteração", sum_after, sum_before)

	# ──────────────────────────────────────────────────
	# T07 — Movimentação de Slots: Swap e Split
	# ──────────────────────────────────────────────────
	inv_a.clear()
	inv_a.add_item(clay, 10) # slot 0: 10 clay
	inv_a.add_item(flint, 4) # slot 1: 4 flint
	
	var swap_ok: bool = inv_a.swap_slots(0, 1)
	_assert_true("T07 — swap_slots retorna true", swap_ok)
	_assert_eq("T07 — slot 0 agora tem flint", inv_a.slots[0].item.id, flint.id)
	_assert_eq("T07 — slot 1 agora tem clay", inv_a.slots[1].item.id, clay.id)

	# Split para slot vazio (slot 2 está vazio)
	var split_ok: bool = inv_a.split_stack(1, 2, 4) # move 4 clay do slot 1 para o slot 2
	_assert_true("T07 — split_stack para slot vazio retorna true", split_ok)
	_assert_eq("T07 — slot 1 restou com 6 clay", inv_a.slots[1].quantity, 6)
	_assert_eq("T07 — slot 2 recebeu 4 clay", inv_a.slots[2].quantity, 4)
	_assert_eq("T07 — total de clay no inventário permanece 10", inv_a.get_item_count(clay.id), 10)

	# Split excessivo (tentar tirar mais do que tem)
	var split_fail: bool = inv_a.split_stack(2, 3, 99)
	_assert_false("T07 — split com quantidade excessiva falha", split_fail)
	_assert_eq("T07 — slot 2 inalterado com 4", inv_a.slots[2].quantity, 4)

	# ──────────────────────────────────────────────────
	# T08 — Proteção contra Parâmetros Inválidos / Negativos
	# ──────────────────────────────────────────────────
	var neg_add: int = inv_a.add_item(clay, -5)
	_assert_eq("T08 — add_item negativo retorna a sobra intacta e é ignorado", neg_add, -5)
	_assert_eq("T08 — total de clay permanece 10", inv_a.get_item_count(clay.id), 10)

	var neg_remove: bool = inv_a.remove_item_by_id(clay.id, -2)
	_assert_false("T08 — remove_item_by_id negativo retorna false", neg_remove)
	_assert_eq("T08 — total de clay permanece 10", inv_a.get_item_count(clay.id), 10)

	var invalid_swap: bool = inv_a.swap_slots(-1, 2)
	_assert_false("T08 — swap_slots com índice negativo é rejeitado", invalid_swap)

	# ──────────────────────────────────────────────────
	# Resultado Final
	# ──────────────────────────────────────────────────
	print("")
	print("Resultado: %d/%d testes passaram" % [_results[0], _results[0] + _results[1]])
	if _results[1] == 0:
		print("TODOS OS TESTES DE PERSISTÊNCIA E TOLERÂNCIA PASSARAM ✅")
		quit(0)
	else:
		print("FALHAS ENCONTRADAS ❌")
		quit(1)
