extends SceneTree

func _init() -> void:
	print("--- INICIANDO TESTE AUTOMATIZADO DE INTERAÇÃO (BK-009) ---")
	
	var player_scene: PackedScene = load("res://scenes/entities/player.tscn")
	var statue_scene: PackedScene = load("res://scenes/entities/petrified_statue.tscn")
	
	if not player_scene or not statue_scene:
		printerr("FALHA: Não foi possível carregar as cenas para teste.")
		quit(1)
		return
		
	var root_node: Node2D = Node2D.new()
	root.add_child(root_node)
	
	var player: PlayerController = player_scene.instantiate()
	var statue: Node2D = statue_scene.instantiate()
	
	root_node.add_child(statue)
	root_node.add_child(player)
	
	# Posiciona estátua em (100, 100) e jogador próximo em (110, 100)
	statue.global_position = Vector2(100, 100)
	player.global_position = Vector2(110, 100)
	
	var statue_interactable: Interactable = statue.get_node("Interactable") as Interactable
	if not statue_interactable:
		printerr("FALHA: Componente Interactable não encontrado na estátua.")
		quit(1)
		return
		
	# Simula detecção de área
	player.nearby_interactables.append(statue_interactable)
	player._update_nearest_interactable()
	
	if player.current_target != statue_interactable:
		printerr("FALHA: current_target não corresponde ao interactable mais próximo.")
		quit(1)
		return
	print("[PASS] Detecção de alvo mais próximo validada com sucesso.")
	
	if not statue_interactable.is_focused:
		printerr("FALHA: interactable não entrou no estado focused.")
		quit(1)
		return
	print("[PASS] Estado focused e ativação de prompt flutuante validados.")
	
	var result: Array = [false]
	statue_interactable.interacted.connect(func(_initiator): result[0] = true)
	
	statue_interactable.trigger_interaction(player)
	
	if not result[0]:
		printerr("FALHA: Sinal interacted não foi emitido.")
		quit(1)
		return
	print("[PASS] Emissão e captura de evento de interação validadas com sucesso.")
	
	print("--- TODOS OS TESTES DE INTERAÇÃO PASSARAM COM SUCESSO! ---")
	root_node.queue_free()
	quit(0)
