class_name ScienceJournal
extends Node

## Gerencia o caderno de anotações e descobertas científicas do jogador.
## Rastreia tecnologias desbloqueadas, histórico de experimentos realizados e catalogação de materiais.
## Persistente e versionável (BK-018).

signal technology_unlocked(tech: TechDefinition)
signal experiment_completed(experiment: ExperimentDefinition, is_first_time: bool, success: bool)
signal material_discovered(item_id: StringName)
signal journal_updated()

## Dicionário de tecnologias desbloqueadas: { StringName: bool }
var unlocked_technologies: Dictionary = {}

## Dicionário de experimentos concluídos e número de execuções: { StringName: int }
var completed_experiments: Dictionary = {}

## Dicionário de materiais químicos/minerais já examinados pelo jogador: { StringName: bool }
var discovered_materials: Dictionary = {}

## Catálogo de tecnologias para lookup durante desserialização ou validação
var tech_catalog: Dictionary = {}

## Catálogo de experimentos
var experiment_catalog: Dictionary = {}

func register_tech(tech: TechDefinition) -> void:
	if tech and tech.id != &"":
		tech_catalog[tech.id] = tech

func register_experiment(exp_def: ExperimentDefinition) -> void:
	if exp_def and exp_def.id != &"":
		experiment_catalog[exp_def.id] = exp_def

## Desbloqueia uma tecnologia caso todos os seus pré-requisitos tenham sido satisfeitos.
func unlock_technology(tech: TechDefinition) -> bool:
	if tech == null or tech.deprecated:
		return false
		
	if is_technology_unlocked(tech.id):
		return true
		
	if not tech.can_unlock(unlocked_technologies, completed_experiments):
		return false
		
	unlocked_technologies[tech.id] = true
	technology_unlocked.emit(tech)
	journal_updated.emit()
	return true

## Força o desbloqueio de uma tecnologia inicial/primitiva (ex.: tecnologias de ponto de partida).
func grant_initial_technology(tech: TechDefinition) -> void:
	if tech == null:
		return
	unlocked_technologies[tech.id] = true
	technology_unlocked.emit(tech)
	journal_updated.emit()

## Registra a catalogação de um material examinado.
func discover_material(item_id: StringName) -> void:
	if item_id == &"" or discovered_materials.has(item_id):
		return
	discovered_materials[item_id] = true
	material_discovered.emit(item_id)
	journal_updated.emit()

func is_technology_unlocked(tech_id: StringName) -> bool:
	return unlocked_technologies.get(tech_id, false)

func is_experiment_completed(experiment_id: StringName) -> bool:
	return completed_experiments.get(experiment_id, 0) > 0

func get_experiment_completion_count(experiment_id: StringName) -> int:
	return completed_experiments.get(experiment_id, 0)

## Executa um experimento consumindo insumos e gerando resultados (sucesso ou falha controlada).
## Se tiver sucesso e for a primeira vez, desbloqueia a tecnologia vinculada automaticamente.
func execute_experiment(
	experiment: ExperimentDefinition,
	inventory: Inventory,
	current_station_id: StringName,
	actual_conditions: Dictionary,
	item_catalog: Dictionary
) -> Dictionary:
	var result: Dictionary = {
		"success": false,
		"reason": "",
		"unlocked_tech": null,
		"items_produced": []
	}
	
	if experiment == null or inventory == null:
		result["reason"] = "Referência nula a experimento ou inventário."
		return result
		
	if experiment.deprecated:
		result["reason"] = "Experimento descontinuado."
		return result
		
	# Valida se pode preparar
	if not experiment.can_prepare(inventory, current_station_id, unlocked_technologies):
		result["reason"] = "Condições prévias ou insumos insuficientes."
		return result
		
	# Consome os insumos do inventário
	for entry in experiment.inputs:
		var item_id: StringName = StringName(entry.get("item_id", ""))
		var amount: int = entry.get("amount", 0)
		inventory.remove_item_by_id(item_id, amount)
		
	# Avalia condições físico-químicas
	var conditions_met: bool = experiment.evaluate_conditions(actual_conditions)
	var outputs: Array[Dictionary] = experiment.outputs_success if conditions_met else experiment.outputs_failure
	
	# Entrega produtos (de sucesso ou falha)
	for entry in outputs:
		var item_id: StringName = StringName(entry.get("item_id", ""))
		var amount: int = entry.get("amount", 0)
		if item_catalog.has(item_id):
			var item_def: ItemDefinition = item_catalog[item_id]
			var leftover: int = inventory.add_item(item_def, amount)
			result["items_produced"].append({ "item_id": item_id, "amount": amount - leftover })
			discover_material(item_id)
			
	if conditions_met:
		result["success"] = true
		var is_first_time: bool = not is_experiment_completed(experiment.id)
		completed_experiments[experiment.id] = get_experiment_completion_count(experiment.id) + 1
		
		# Se desbloqueia tecnologia na primeira conclusão
		if is_first_time and experiment.discovery_unlock_tech != &"":
			var tech_id: StringName = experiment.discovery_unlock_tech
			if tech_catalog.has(tech_id):
				var target_tech: TechDefinition = tech_catalog[tech_id]
				unlock_technology(target_tech)
				result["unlocked_tech"] = target_tech
				
		experiment_completed.emit(experiment, is_first_time, true)
	else:
		result["success"] = false
		result["reason"] = "Condições de reação não atingidas (temperatura ou tempo insuficientes)."
		experiment_completed.emit(experiment, false, false)
		
	journal_updated.emit()
	return result

## Serializa todo o progresso científico para o save da campanha.
func serialize() -> Dictionary:
	var techs_array: Array[String] = []
	for tech_id in unlocked_technologies.keys():
		if unlocked_technologies[tech_id]:
			techs_array.append(str(tech_id))
			
	var exps_dict: Dictionary = {}
	for exp_id in completed_experiments.keys():
		exps_dict[str(exp_id)] = completed_experiments[exp_id]
		
	var materials_array: Array[String] = []
	for mat_id in discovered_materials.keys():
		if discovered_materials[mat_id]:
			materials_array.append(str(mat_id))
			
	return {
		"unlocked_technologies": techs_array,
		"completed_experiments": exps_dict,
		"discovered_materials": materials_array
	}

## Restaura o progresso com validação defensiva contra IDs desconhecidos.
func deserialize(data: Variant) -> bool:
	if not (data is Dictionary):
		return false
		
	unlocked_technologies.clear()
	completed_experiments.clear()
	discovered_materials.clear()
	
	var raw_techs = data.get("unlocked_technologies", [])
	if raw_techs is Array:
		for tech_str in raw_techs:
			if tech_str is String and tech_str != "":
				unlocked_technologies[StringName(tech_str)] = true
				
	var raw_exps = data.get("completed_experiments", {})
	if raw_exps is Dictionary:
		for exp_str in raw_exps.keys():
			var count: int = int(raw_exps[exp_str])
			if count > 0:
				completed_experiments[StringName(exp_str)] = count
				
	var raw_materials = data.get("discovered_materials", [])
	if raw_materials is Array:
		for mat_str in raw_materials:
			if mat_str is String and mat_str != "":
				discovered_materials[StringName(mat_str)] = true
				
	journal_updated.emit()
	return true
