extends SceneTree

## Teste unitário headless de ciência, tecnologia e experimentos (BK-016, BK-017, BK-018, BK-020)
## Execução: Godot --headless --script tests/test_science_progression.gd

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
	print("=== TEST SCIENCE PROGRESSION & EXPERIMENTS (FASE 4) ===")
	
	# ──────────────────────────────────────────────────
	# 1. Carregamento dos Recursos
	# ──────────────────────────────────────────────────
	var item_calcium: ItemDefinition = load("res://data/items/calcium_carbonate.tres")
	var item_quicklime: ItemDefinition = load("res://data/items/quicklime.tres")
	var item_soot: ItemDefinition = load("res://data/items/soot_ash.tres")

	var tech_fire: TechDefinition = load("res://data/tech/primitive_fire.tres")
	var tech_calcination: TechDefinition = load("res://data/tech/calcination.tres")
	var exp_calcination: ExperimentDefinition = load("res://data/experiments/calcination_limestone.tres")

	var item_catalog: Dictionary = {
		item_calcium.id: item_calcium,
		item_quicklime.id: item_quicklime,
		item_soot.id: item_soot
	}

	# ──────────────────────────────────────────────────
	# 2. Setup dos Nós
	# ──────────────────────────────────────────────────
	var inventory: Inventory = Inventory.new()
	inventory.max_slots = 6
	get_root().add_child(inventory)

	var journal: ScienceJournal = ScienceJournal.new()
	journal.register_tech(tech_fire)
	journal.register_tech(tech_calcination)
	journal.register_experiment(exp_calcination)
	get_root().add_child(journal)

	await process_frame

	# ──────────────────────────────────────────────────
	# T01 — BK-016: Árvore Tecnológica e Pré-requisitos
	# ──────────────────────────────────────────────────
	# Inicialmente, tech_calcination não pode ser desbloqueada porque falta tech_fire e o experimento
	_assert_false("T01 — tech_calcination bloqueada sem pré-requisitos", tech_calcination.can_unlock(journal.unlocked_technologies, journal.completed_experiments))
	
	var missing = tech_calcination.get_missing_prerequisites(journal.unlocked_technologies, journal.completed_experiments)
	_assert_eq("T01 — detectou 2 pré-requisitos faltantes", missing.size(), 2)

	# Concede tecnologia primitiva de fogo
	journal.grant_initial_technology(tech_fire)
	_assert_true("T01 — tech_fire está ativa no caderno", journal.is_technology_unlocked(tech_fire.id))
	
	# Ainda falta o experimento
	missing = tech_calcination.get_missing_prerequisites(journal.unlocked_technologies, journal.completed_experiments)
	_assert_eq("T01 — agora falta apenas 1 requisito (experimento)", missing.size(), 1)
	_assert_false("T01 — ainda bloqueada sem o experimento", tech_calcination.can_unlock(journal.unlocked_technologies, journal.completed_experiments))

	# ──────────────────────────────────────────────────
	# T02 — BK-017: Preparação do Experimento (Validações de Insumos e Estação)
	# ──────────────────────────────────────────────────
	# Tenta preparar sem insumos no inventário
	_assert_false("T02 — can_prepare falha sem carbonato de cálcio", exp_calcination.can_prepare(inventory, &"structure.station.crafting_bench", journal.unlocked_technologies))

	# Adiciona insumo insuficiente (precisa de 2)
	inventory.add_item(item_calcium, 1)
	_assert_false("T02 — can_prepare falha com quantidade insuficiente (1/2)", exp_calcination.can_prepare(inventory, &"structure.station.crafting_bench", journal.unlocked_technologies))

	# Completa insumo
	inventory.add_item(item_calcium, 1) # agora tem 2
	_assert_true("T02 — can_prepare aprova na bancada correta com 2 carbonatos", exp_calcination.can_prepare(inventory, &"structure.station.crafting_bench", journal.unlocked_technologies))

	# Rejeita se a bancada for incompatível
	_assert_false("T02 — can_prepare rejeita se estiver na estação errada", exp_calcination.can_prepare(inventory, &"structure.station.wrong_bench", journal.unlocked_technologies))

	# ──────────────────────────────────────────────────
	# T03 — BK-018 & BK-020: Execução com Falha Térmica Controlada (Subproduto didático)
	# ──────────────────────────────────────────────────
	# Condições insuficientes: min_heat é 600, fornecemos apenas 300
	var low_heat_conditions: Dictionary = { "heat": 300, "duration": 5.0 }
	var fail_result: Dictionary = journal.execute_experiment(
		exp_calcination,
		inventory,
		&"structure.station.crafting_bench",
		low_heat_conditions,
		item_catalog
	)

	_assert_false("T03 — experimento falhou devido a calor insuficiente", fail_result["success"])
	_assert_eq("T03 — consumiu os 2 carbonatos de cálcio (0 restante)", inventory.get_item_count(item_calcium.id), 0)
	_assert_eq("T03 — gerou resíduo de fuligem/cinzas (1 un)", inventory.get_item_count(item_soot.id), 1)
	_assert_false("T03 — calcinação NÃO foi desbloqueada na falha", journal.is_technology_unlocked(tech_calcination.id))
	_assert_eq("T03 — contagem de conclusão permanece 0", journal.get_experiment_completion_count(exp_calcination.id), 0)

	# ──────────────────────────────────────────────────
	# T04 — BK-019 & BK-020: Execução com Sucesso Ótimo (Descoberta & Desbloqueio)
	# ──────────────────────────────────────────────────
	# Reabastece inventário com 2 carbonatos
	inventory.add_item(item_calcium, 2)
	
	# Condições ótimas: calor 750 (>= 600) e duração 4.0s (>= 3.0s)
	var optimal_conditions: Dictionary = { "heat": 750, "duration": 4.0 }
	var success_result: Dictionary = journal.execute_experiment(
		exp_calcination,
		inventory,
		&"structure.station.crafting_bench",
		optimal_conditions,
		item_catalog
	)

	_assert_true("T04 — experimento obteve sucesso térmico", success_result["success"])
	_assert_eq("T04 — carbonato de cálcio foi consumido", inventory.get_item_count(item_calcium.id), 0)
	_assert_eq("T04 — cal virgem (óxido de cálcio) foi sintetizada (2 un)", inventory.get_item_count(item_quicklime.id), 2)
	_assert_eq("T04 — experimento registrado com 1 conclusão", journal.get_experiment_completion_count(exp_calcination.id), 1)
	_assert_true("T04 — tech.chemistry.calcination foi desbloqueada automaticamente!", journal.is_technology_unlocked(tech_calcination.id))

	# ──────────────────────────────────────────────────
	# T05 — BK-018: Persistência do Caderno Científico (Save/Load)
	# ──────────────────────────────────────────────────
	var serialized_journal: Dictionary = journal.serialize()
	_assert_true("T05 — serialização contém unlocked_technologies", serialized_journal.has("unlocked_technologies"))
	_assert_true("T05 — serialização contém completed_experiments", serialized_journal.has("completed_experiments"))
	
	# Novo caderno limpo
	var loaded_journal: ScienceJournal = ScienceJournal.new()
	get_root().add_child(loaded_journal)
	var load_ok: bool = loaded_journal.deserialize(serialized_journal)
	
	_assert_true("T05 — deserialize retornou true", load_ok)
	_assert_true("T05 — novo caderno preservou tech_fire", loaded_journal.is_technology_unlocked(tech_fire.id))
	_assert_true("T05 — novo caderno preservou tech_calcination", loaded_journal.is_technology_unlocked(tech_calcination.id))
	_assert_eq("T05 — novo caderno preservou histórico do experimento (1 conclusão)", loaded_journal.get_experiment_completion_count(exp_calcination.id), 1)

	# ──────────────────────────────────────────────────
	# Resultado Final
	# ──────────────────────────────────────────────────
	print("")
	print("Resultado: %d/%d testes passaram" % [_results[0], _results[0] + _results[1]])
	if _results[1] == 0:
		print("TODOS OS TESTES DE CIÊNCIA E EXPERIMENTOS PASSARAM ✅")
		quit(0)
	else:
		print("FALHAS ENCONTRADAS ❌")
		quit(1)
