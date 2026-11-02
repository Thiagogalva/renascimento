class_name TechDefinition
extends Resource

## Define uma tecnologia ou avanço científico na árvore de conhecimento.
## Utiliza IDs estáveis (StringName) para dependências e desbloqueios.

enum TechCategory {
	PRIMITIVE,
	CHEMISTRY,
	METALLURGY,
	BIOLOGY,
	ENGINEERING
}

## ID técnico estável da tecnologia. Ex.: "tech.chemistry.calcination"
@export var id: StringName = &""

## Nome visível para o jogador.
@export var display_name: String = ""

## Descrição pedagógica e científica do ramo de conhecimento.
@export_multiline var description: String = ""

## Categoria da árvore de ciência.
@export var category: TechCategory = TechCategory.PRIMITIVE

## Tecnologias pré-requisito (todas devem estar dominadas).
@export var prerequisite_tech_ids: Array[StringName] = []

## Experimentos que precisam ter sido concluídos com sucesso para consolidar a descoberta.
@export var required_experiment_ids: Array[StringName] = []

## IDs de receitas de fabricação desbloqueadas por esta tecnologia.
@export var unlocked_recipes: Array[StringName] = []

## IDs de estruturas ou bancadas desbloqueadas por esta tecnologia.
@export var unlocked_structures: Array[StringName] = []

## Flag de descontinuação segura sem quebrar saves legados.
@export var deprecated: bool = false

## Verifica se os pré-requisitos tecnológicos e experimentais foram atendidos.
func can_unlock(unlocked_techs: Dictionary, completed_experiments: Dictionary) -> bool:
	if deprecated:
		return false
		
	# Valida tecnologias anteriores
	for prereq_id in prerequisite_tech_ids:
		if not unlocked_techs.has(prereq_id) or not unlocked_techs[prereq_id]:
			return false
			
	# Valida experimentos necessários
	for exp_id in required_experiment_ids:
		if not completed_experiments.has(exp_id) or completed_experiments[exp_id] <= 0:
			return false
			
	return true

## Retorna lista em texto com os requisitos ainda pendentes para desbloqueio.
func get_missing_prerequisites(unlocked_techs: Dictionary, completed_experiments: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for prereq_id in prerequisite_tech_ids:
		if not unlocked_techs.has(prereq_id) or not unlocked_techs[prereq_id]:
			missing.append("Tecnologia: %s" % str(prereq_id))
			
	for exp_id in required_experiment_ids:
		if not completed_experiments.has(exp_id) or completed_experiments[exp_id] <= 0:
			missing.append("Experimento: %s" % str(exp_id))
			
	return missing
