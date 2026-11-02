class_name ExperimentDefinition
extends Resource

## Define um experimento científico controlável no laboratório ou bancadas.
## Especifica materiais, instrumentos, condições termo-químicas e resultados didáticos de sucesso e falha.

## ID técnico estável do experimento. Ex.: "experiment.calcination.limestone"
@export var id: StringName = &""

## Nome visível do experimento.
@export var display_name: String = ""

## Descrição do objetivo do experimento.
@export_multiline var description: String = ""

## Fundamentação científica real do processo (educativa, química/física).
@export_multiline var scientific_principle: String = ""

## Estação de trabalho requerida. Ex.: "structure.station.clay_kiln" (vazio = mãos livres).
@export var station_required: StringName = &""

## Tecnologia prévia necessária para compreender/preparar a reação.
@export var prerequisite_tech_id: StringName = &""

## Materiais consumidos na preparação. Cada item: { "item_id": StringName, "amount": int }
@export var inputs: Array[Dictionary] = []

## Condições físicas exigidas para reação: { "min_heat": int, "duration_seconds": float }
@export var conditions: Dictionary = {}

## Itens gerados em caso de sucesso da reação.
@export var outputs_success: Array[Dictionary] = []

## Resíduos ou subprodutos gerados em caso de falha controlada (ex.: fuligem, escória).
@export var outputs_failure: Array[Dictionary] = []

## Tecnologia que é desbloqueada imediatamente na primeira conclusão bem-sucedida deste experimento.
@export var discovery_unlock_tech: StringName = &""

## Flag de descontinuação segura.
@export var deprecated: bool = false

## Verifica se o inventário possui os materiais e a bancada/tecnologia são adequadas para preparar o experimento.
func can_prepare(inventory: Inventory, current_station_id: StringName, unlocked_techs: Dictionary) -> bool:
	if deprecated:
		return false
		
	# Valida estação
	if station_required != &"" and station_required != current_station_id:
		return false
		
	# Valida pré-requisito de tecnologia
	if prerequisite_tech_id != &"" and not unlocked_techs.has(prerequisite_tech_id):
		return false
		
	# Valida insumos no inventário
	for entry in inputs:
		var item_id: StringName = StringName(entry.get("item_id", ""))
		var amount: int = entry.get("amount", 0)
		if not inventory.has_item(item_id, amount):
			return false
			
	return true

## Avalia se as condições do ambiente (temperatura, tempo de queima, catalisadores) atingiram os parâmetros ótimos.
func evaluate_conditions(actual_conditions: Dictionary) -> bool:
	var required_heat: int = conditions.get("min_heat", 0)
	var actual_heat: int = actual_conditions.get("heat", 0)
	if actual_heat < required_heat:
		return false
		
	var required_duration: float = conditions.get("duration_seconds", 0.0)
	var actual_duration: float = actual_conditions.get("duration", 0.0)
	if actual_duration < required_duration:
		return false
		
	return true
