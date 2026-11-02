class_name RecipeDefinition
extends Resource

## Define uma receita de fabricação: insumos necessários, produto gerado,
## estação exigida e tempo de execução.
## Todos os itens são referenciados por ID estável (StringName), nunca por nome exibido.

## ID técnico único desta receita. Ex.: "recipe.basic.clay_brick"
@export var id: StringName = &""

## Nome exibido ao jogador (pode ser traduzido livremente sem alterar o ID).
@export var display_name: String = ""

## Descrição curta do processo (texto didático/científico para o jogador).
@export var description: String = ""

## ID da estação necessária. Vazio = mãos limpas / sem bancada.
## Ex.: "structure.station.clay_kiln"
@export var required_station_id: StringName = &""

## Insumos consumidos. Cada entrada: { "item_id": StringName, "amount": int }
@export var inputs: Array[Dictionary] = []

## Item produzido ao final da receita.
@export var output_item_id: StringName = &""

## Quantidade do item produzido.
@export var output_amount: int = 1

## Tempo de fabricação em segundos (0 = instantâneo).
@export var craft_time_seconds: float = 0.0

## Se verdadeiro, receita desativada (depreciação sem remoção de ID).
@export var deprecated: bool = false


## Verifica se o inventário fornecido contém todos os insumos necessários.
func can_craft(inventory: Inventory) -> bool:
	if deprecated:
		return false
	for entry in inputs:
		var item_id: StringName = StringName(entry.get("item_id", ""))
		var amount: int = entry.get("amount", 0)
		if not inventory.has_item(item_id, amount):
			return false
	return true


## Retorna uma String legível dos insumos faltantes dado um inventário.
func get_missing_inputs(inventory: Inventory) -> String:
	var missing: Array[String] = []
	for entry in inputs:
		var item_id: StringName = StringName(entry.get("item_id", ""))
		var required: int = entry.get("amount", 0)
		var have: int = inventory.get_item_count(item_id)
		if have < required:
			missing.append("%s (%d/%d)" % [str(item_id), have, required])
	return ", ".join(missing)
