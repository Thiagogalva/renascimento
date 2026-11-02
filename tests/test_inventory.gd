extends SceneTree

## Teste unitário headless do sistema de Inventário (BK-011, BK-012)
## Execução: Godot --headless --script tests/test_inventory.gd

# Contadores em Array para que a lambda os capture por referência
var _results: Array[int] = [0, 0]  # [passed, failed]

func _assert_eq(label: String, got: Variant, expected: Variant) -> void:
	if got == expected:
		print("  ✅ PASS: ", label)
		_results[0] += 1
	else:
		print("  ❌ FAIL: ", label, " — esperado: ", expected, "  obtido: ", got)
		_results[1] += 1

func _init() -> void:
	print("=== TEST INVENTORY ===")

	# ──────────────────────────────────────────────────
	# Montagem: cria ItemDefinitions sintéticos
	# ──────────────────────────────────────────────────
	var item_def: ItemDefinition = ItemDefinition.new()
	item_def.id = &"item.test_stone"
	item_def.display_name = "Pedra de Teste"
	item_def.max_stack = 5

	var item_b: ItemDefinition = ItemDefinition.new()
	item_b.id = &"item.test_wood"
	item_b.display_name = "Madeira de Teste"
	item_b.max_stack = 10

	# Cria o Inventory como Node isolado
	var inv: Inventory = Inventory.new()
	inv.max_slots = 4
	get_root().add_child(inv)  # aciona _ready() que inicializa os slots
	await process_frame

	# ──────────────────────────────────────────────────
	# T01 — Inventário começa vazio
	# ──────────────────────────────────────────────────
	_assert_eq("T01 — slots inicializados", inv.slots.size(), 4)
	_assert_eq("T01 — contagem inicial do item", inv.get_item_count(&"item.test_stone"), 0)

	# ──────────────────────────────────────────────────
	# T02 — add_item empilha no mesmo slot
	# ──────────────────────────────────────────────────
	var leftover: int = inv.add_item(item_def, 3)
	_assert_eq("T02 — sem leftover ao adicionar 3", leftover, 0)
	_assert_eq("T02 — contagem é 3", inv.get_item_count(&"item.test_stone"), 3)

	# ──────────────────────────────────────────────────
	# T03 — empilhamento: completa a pilha (max_stack = 5)
	# ──────────────────────────────────────────────────
	leftover = inv.add_item(item_def, 2)
	_assert_eq("T03 — sem leftover ao completar pilha", leftover, 0)
	_assert_eq("T03 — contagem é 5", inv.get_item_count(&"item.test_stone"), 5)

	var occupied: int = 0
	for slot in inv.slots:
		if not slot.is_empty():
			occupied += 1
	_assert_eq("T03 — apenas 1 slot ocupado", occupied, 1)

	# ──────────────────────────────────────────────────
	# T04 — pilha cheia abre novo slot
	# ──────────────────────────────────────────────────
	leftover = inv.add_item(item_def, 3)
	_assert_eq("T04 — sem leftover (overflow para novo slot)", leftover, 0)
	_assert_eq("T04 — contagem total é 8", inv.get_item_count(&"item.test_stone"), 8)

	occupied = 0
	for slot in inv.slots:
		if not slot.is_empty():
			occupied += 1
	_assert_eq("T04 — dois slots ocupados", occupied, 2)

	# ──────────────────────────────────────────────────
	# T05 — remove_item_by_id parcial
	# ──────────────────────────────────────────────────
	var removed: bool = inv.remove_item_by_id(&"item.test_stone", 5)
	_assert_eq("T05 — remove retorna true", removed, true)
	_assert_eq("T05 — contagem é 3 após remoção", inv.get_item_count(&"item.test_stone"), 3)

	# ──────────────────────────────────────────────────
	# T06 — remove mais do que existe → false
	# ──────────────────────────────────────────────────
	var removed_fail: bool = inv.remove_item_by_id(&"item.test_stone", 99)
	_assert_eq("T06 — remove excessivo retorna false", removed_fail, false)
	_assert_eq("T06 — contagem inalterada", inv.get_item_count(&"item.test_stone"), 3)

	# ──────────────────────────────────────────────────
	# T07 — has_item
	# ──────────────────────────────────────────────────
	_assert_eq("T07 — has_item(3) true", inv.has_item(&"item.test_stone", 3), true)
	_assert_eq("T07 — has_item(4) false", inv.has_item(&"item.test_stone", 4), false)

	# ──────────────────────────────────────────────────
	# T08 — inventário cheio
	# Remove as pedras restantes, depois preenche todos os 4 slots com item_b
	# ──────────────────────────────────────────────────
	inv.remove_item_by_id(&"item.test_stone", 3)  # limpa slot(s) de pedra
	_assert_eq("T08 — inventário limpo antes do teste de full", inv.get_item_count(&"item.test_stone"), 0)

	# 4 slots × max_stack 10 = 40 itens para lotar tudo
	inv.add_item(item_b, 40)
	_assert_eq("T08 — is_full() quando cheio", inv.is_full(), true)

	leftover = inv.add_item(item_b, 5)
	_assert_eq("T08 — leftover = 5 quando cheio", leftover, 5)

	# ──────────────────────────────────────────────────
	# Resultado final
	# ──────────────────────────────────────────────────
	print("")
	print("Resultado: %d/%d testes passaram" % [_results[0], _results[0] + _results[1]])
	if _results[1] == 0:
		print("TODOS OS TESTES PASSARAM ✅")
		quit(0)
	else:
		print("FALHAS ENCONTRADAS ❌")
		quit(1)
