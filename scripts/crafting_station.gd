class_name CraftingStation
extends Node

## Sistema de fabricação: valida insumos no inventário do jogador,
## consome os itens de entrada e entrega o produto de saída.
## Intencionalmente sem lógica de UI — comunica resultados via sinais.

signal craft_started(recipe: RecipeDefinition)
signal craft_completed(recipe: RecipeDefinition, output_item: ItemDefinition, amount: int)
signal craft_failed(recipe: RecipeDefinition, reason: String)

## Catálogo de receitas disponíveis nesta estação.
@export var available_recipes: Array[RecipeDefinition] = []

## ID desta estação (deve corresponder ao required_station_id das receitas que aceita).
## Vazio = bancada genérica / mãos limpas.
@export var station_id: StringName = &""

## Catálogo global de ItemDefinitions para resolver output_item_id → ItemDefinition.
## Injete via código antes de chamar try_craft().
var _item_catalog: Dictionary = {}  # StringName → ItemDefinition


## Registra um ItemDefinition no catálogo interno desta estação.
func register_item(item_def: ItemDefinition) -> void:
	_item_catalog[item_def.id] = item_def


## Tenta executar uma receita para o inventário informado.
## Retorna true se a fabricação foi concluída com sucesso.
func try_craft(recipe: RecipeDefinition, inventory: Inventory) -> bool:
	if recipe == null or inventory == null:
		return false

	if recipe.deprecated:
		craft_failed.emit(recipe, "Receita descontinuada.")
		return false

	# Valida estação
	if recipe.required_station_id != &"" and recipe.required_station_id != station_id:
		craft_failed.emit(recipe, "Estação incorreta. Necessário: %s" % str(recipe.required_station_id))
		return false

	# Valida insumos
	if not recipe.can_craft(inventory):
		var missing: String = recipe.get_missing_inputs(inventory)
		craft_failed.emit(recipe, "Insumos insuficientes: %s" % missing)
		return false

	# Resolve item de saída
	if not _item_catalog.has(recipe.output_item_id):
		craft_failed.emit(recipe, "Item de saída desconhecido: %s" % str(recipe.output_item_id))
		return false

	var output_item: ItemDefinition = _item_catalog[recipe.output_item_id]

	# Consome insumos
	for entry in recipe.inputs:
		var item_id: StringName = StringName(entry.get("item_id", ""))
		var amount: int = entry.get("amount", 0)
		inventory.remove_item_by_id(item_id, amount)

	# Entrega produto
	var leftover: int = inventory.add_item(output_item, recipe.output_amount)

	craft_started.emit(recipe)
	craft_completed.emit(recipe, output_item, recipe.output_amount - leftover)

	if leftover > 0:
		push_warning("CraftingStation: inventário cheio, %d unidade(s) de '%s' perdidas." % [leftover, str(output_item.id)])

	return true


## Retorna todas as receitas que a estação aceita e que o inventário pode executar agora.
func get_available_recipes_for(inventory: Inventory) -> Array[RecipeDefinition]:
	var result: Array[RecipeDefinition] = []
	for recipe in available_recipes:
		if recipe.deprecated:
			continue
		if recipe.required_station_id != &"" and recipe.required_station_id != station_id:
			continue
		result.append(recipe)
	return result


## Retorna receitas que o inventário pode fabricar agora (subconjunto das disponíveis).
func get_craftable_recipes_for(inventory: Inventory) -> Array[RecipeDefinition]:
	var result: Array[RecipeDefinition] = []
	for recipe in get_available_recipes_for(inventory):
		if recipe.can_craft(inventory):
			result.append(recipe)
	return result
