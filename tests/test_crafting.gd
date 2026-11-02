extends SceneTree

## Teste unitário headless do sistema de Fabricação (BK-013, BK-014)
## Execução: Godot --headless --script tests/test_crafting.gd

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
	print("=== TEST CRAFTING ===")

	# ──────────────────────────────────────────────────
	# Montagem: itens sintéticos
	# ──────────────────────────────────────────────────
	var clay: ItemDefinition = ItemDefinition.new()
	clay.id = &"item.raw.clay"
	clay.display_name = "Argila"
	clay.max_stack = 20

	var flint: ItemDefinition = ItemDefinition.new()
	flint.id = &"item.raw.flint"
	flint.display_name = "Sílex"
	flint.max_stack = 10

	var clay_brick: ItemDefinition = ItemDefinition.new()
	clay_brick.id = &"item.raw.clay_brick"
	clay_brick.display_name = "Tijolo de Argila"
	clay_brick.max_stack = 20

	var stone_flakes: ItemDefinition = ItemDefinition.new()
	stone_flakes.id = &"item.raw.stone_flakes"
	stone_flakes.display_name = "Lascas de Pedra"
	stone_flakes.max_stack = 30

	# ──────────────────────────────────────────────────
	# Montagem: receitas sintéticas
	# ──────────────────────────────────────────────────
	var recipe_brick: RecipeDefinition = RecipeDefinition.new()
	recipe_brick.id = &"recipe.basic.clay_brick"
	recipe_brick.display_name = "Tijolo de Argila"
	recipe_brick.required_station_id = &""
	recipe_brick.inputs = [{ "item_id": &"item.raw.clay", "amount": 3 }]
	recipe_brick.output_item_id = &"item.raw.clay_brick"
	recipe_brick.output_amount = 1

	var recipe_flint: RecipeDefinition = RecipeDefinition.new()
	recipe_flint.id = &"recipe.basic.flint_knapping"
	recipe_flint.display_name = "Lascar Sílex"
	recipe_flint.required_station_id = &""
	recipe_flint.inputs = [{ "item_id": &"item.raw.flint", "amount": 2 }]
	recipe_flint.output_item_id = &"item.raw.stone_flakes"
	recipe_flint.output_amount = 3

	var recipe_kiln: RecipeDefinition = RecipeDefinition.new()
	recipe_kiln.id = &"recipe.kiln.test"
	recipe_kiln.display_name = "Receita de Forno"
	recipe_kiln.required_station_id = &"structure.station.clay_kiln"
	recipe_kiln.inputs = [{ "item_id": &"item.raw.clay", "amount": 1 }]
	recipe_kiln.output_item_id = &"item.raw.clay_brick"
	recipe_kiln.output_amount = 2

	var recipe_deprecated: RecipeDefinition = RecipeDefinition.new()
	recipe_deprecated.id = &"recipe.old.deprecated"
	recipe_deprecated.display_name = "Receita Antiga"
	recipe_deprecated.required_station_id = &""
	recipe_deprecated.inputs = [{ "item_id": &"item.raw.clay", "amount": 1 }]
	recipe_deprecated.output_item_id = &"item.raw.clay_brick"
	recipe_deprecated.output_amount = 1
	recipe_deprecated.deprecated = true

	# ──────────────────────────────────────────────────
	# Montagem: inventário e estação
	# ──────────────────────────────────────────────────
	var inv: Inventory = Inventory.new()
	inv.max_slots = 8
	get_root().add_child(inv)

	var station: CraftingStation = CraftingStation.new()
	station.station_id = &""
	station.available_recipes = [recipe_brick, recipe_flint, recipe_kiln, recipe_deprecated]
	station.register_item(clay_brick)
	station.register_item(stone_flakes)
	get_root().add_child(station)

	await process_frame

	# ──────────────────────────────────────────────────
	# T01 — can_craft: insumos insuficientes
	# ──────────────────────────────────────────────────
	_assert_false("T01 — can_craft sem insumos", recipe_brick.can_craft(inv))

	# ──────────────────────────────────────────────────
	# T02 — can_craft: insumos parciais
	# ──────────────────────────────────────────────────
	inv.add_item(clay, 2)  # precisa de 3
	_assert_false("T02 — can_craft com insumos parciais", recipe_brick.can_craft(inv))

	# ──────────────────────────────────────────────────
	# T03 — can_craft: insumos suficientes
	# ──────────────────────────────────────────────────
	inv.add_item(clay, 1)  # agora tem 3
	_assert_true("T03 — can_craft com 3 argilas", recipe_brick.can_craft(inv))

	# ──────────────────────────────────────────────────
	# T04 — try_craft: executa fabricação e consome insumos
	# ──────────────────────────────────────────────────
	var ok: bool = station.try_craft(recipe_brick, inv)
	_assert_true("T04 — try_craft retorna true", ok)
	_assert_eq("T04 — argila consumida (0 restante)", inv.get_item_count(&"item.raw.clay"), 0)
	_assert_eq("T04 — tijolo adicionado (1)", inv.get_item_count(&"item.raw.clay_brick"), 1)

	# ──────────────────────────────────────────────────
	# T05 — try_craft: falha por insumos insuficientes
	# ──────────────────────────────────────────────────
	var ok_fail: bool = station.try_craft(recipe_brick, inv)
	_assert_false("T05 — try_craft falha sem insumos", ok_fail)
	_assert_eq("T05 — tijolo não duplicado", inv.get_item_count(&"item.raw.clay_brick"), 1)

	# ──────────────────────────────────────────────────
	# T06 — receita exige estação diferente → falha
	# ──────────────────────────────────────────────────
	inv.add_item(clay, 1)
	var ok_wrong_station: bool = station.try_craft(recipe_kiln, inv)
	_assert_false("T06 — falha com estação errada", ok_wrong_station)
	_assert_eq("T06 — clay não consumida", inv.get_item_count(&"item.raw.clay"), 1)

	# ──────────────────────────────────────────────────
	# T07 — receita depreciada → falha
	# ──────────────────────────────────────────────────
	var ok_deprecated: bool = station.try_craft(recipe_deprecated, inv)
	_assert_false("T07 — receita depreciada retorna false", ok_deprecated)

	# ──────────────────────────────────────────────────
	# T08 — lascar sílex: 2 flints → 3 stone_flakes
	# ──────────────────────────────────────────────────
	inv.add_item(flint, 2)
	var ok_flint: bool = station.try_craft(recipe_flint, inv)
	_assert_true("T08 — lascar sílex sucesso", ok_flint)
	_assert_eq("T08 — flint consumido (0)", inv.get_item_count(&"item.raw.flint"), 0)
	_assert_eq("T08 — 3 stone_flakes gerados", inv.get_item_count(&"item.raw.stone_flakes"), 3)

	# ──────────────────────────────────────────────────
	# T09 — get_available_recipes_for filtra depreciadas e de outra estação
	# ──────────────────────────────────────────────────
	var available: Array[RecipeDefinition] = station.get_available_recipes_for(inv)
	_assert_eq("T09 — apenas 2 receitas disponíveis (excluindo kiln e deprecated)", available.size(), 2)

	# ──────────────────────────────────────────────────
	# T10 — get_craftable_recipes_for filtra pelo inventário atual
	# ──────────────────────────────────────────────────
	# Inventário: 1 clay, 1 clay_brick, 3 stone_flakes, 0 flint
	# clay_brick precisa 3 clay → não pode; flint_knapping precisa 2 flint → não pode
	var craftable: Array[RecipeDefinition] = station.get_craftable_recipes_for(inv)
	_assert_eq("T10 — nenhuma receita fabricável sem insumos suficientes", craftable.size(), 0)

	inv.add_item(clay, 3)
	craftable = station.get_craftable_recipes_for(inv)
	_assert_eq("T10 — 1 receita fabricável (clay_brick) com 3 argilas", craftable.size(), 1)

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
