class_name CollectibleItem
extends Node2D

## Representa um recurso ou item coletável posicionado no chão do mundo isométrico.

signal collected(item_def: ItemDefinition, amount: int)

@export var item_resource: ItemDefinition = null
@export var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	if item_resource:
		if sprite and item_resource.icon:
			sprite.texture = item_resource.icon
		if interactable:
			interactable.interaction_title = "Coletar %s (+%d)" % [item_resource.display_name, amount]
			interactable.interaction_id = item_resource.id
			interactable.scientific_log_entry = "[Coleta de Recursos] %s: %s" % [item_resource.display_name, item_resource.description]
			interactable.interacted.connect(_on_interacted)

func _on_interacted(initiator: Node2D) -> void:
	if initiator is PlayerController:
		var inv: Inventory = initiator.inventory
		if inv:
			var leftover: int = inv.add_item(item_resource, amount)
			if leftover == 0:
				collected.emit(item_resource, amount)
				queue_free()
			elif leftover < amount:
				var gathered: int = amount - leftover
				amount = leftover
				interactable.interaction_title = "Coletar %s (+%d)" % [item_resource.display_name, amount]
				collected.emit(item_resource, gathered)
