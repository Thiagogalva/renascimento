# 08 — Diário de desenvolvimento

Registre fatos verificáveis. Não incluir tokens, senhas, dados privados ou suposições como se fossem fatos.

## 2026-10 — Fundação local

### 2026-11-01 — Persistência, atomicidade e tolerância a falhas do inventário (BK-015)

- **Objetivo:** Garantir a integridade, atomicidade e persistência de dados do inventário sem perdas nem duplicações em cenários válidos ou corrompidos.
- **Branch:** `feature/fase-3-persistencia-inventario`
- **Arquivos modificados:**
  - `scripts/item_slot.gd` — adicionados `clear()`, `serialize()` e verificação de nulidade em `can_stack_with()`.
  - `scripts/inventory.gd` — adicionados `serialize()`, `deserialize()` com validação defensiva, `transfer_item_to()` com atomicidade estrita de transferência, `swap_slots()`, `split_stack()`, `clear()` e `get_total_item_count()`.
  - `docs/03_backlog.md` — BK-015 marcada como Concluída (Fase 3 100% concluída).
- **Arquivos criados:**
  - `tests/test_inventory_persistence.gd` — suíte completa de 37 asserções cobrindo serialização íntegra, tratamento de dados corrompidos (índices negativos, fora do limite, IDs inexistentes, quantidades negativas), limitação defensiva ao `max_stack`, conservação estrita de itens em transbordo/alvo lotado, manipulação de slots e proteções contra parâmetros anômalos.
- **Validações executadas:**
  - `tests/test_inventory_persistence.gd` → **37/37 testes passaram ✅ (Exit Code 0)**.
  - `tests/test_inventory.gd` → **19/19 testes passaram ✅ (Exit Code 0)**.
  - `tests/test_crafting.gd` → **17/17 testes passaram ✅ (Exit Code 0)**.
  - Cena sandbox isométrica (`--quit-after 60`) → **Exit Code 0**.
- **Decisões técnicas:**
  - `transfer_item_to`: transferência atômica com cálculo prévio de capacidade do alvo ou reposição imediata da sobra, garantindo que `total(A) + total(B)` antes da transferência é idêntico a `total(A) + total(B)` depois da transferência.
  - `deserialize`: tolerante a corrupção de save/dados; slots com itens não registrados no catálogo são descartados com aviso seguro, sem falhar o carregamento ou travar a execução. Quantidades excedentes sofrem clamp automático no `max_stack`.

### 2026-11-01 — Fabricação básica implementada (BK-013, BK-014)

- **Objetivo:** Modelar receitas em dados e implementar o sistema de fabricação do jogador com bancada interativa.
- **Branch:** `feature/fase-3-fabricacao`
- **Arquivos criados:**
  - `scripts/recipe_definition.gd` — `class_name RecipeDefinition extends Resource`: id, inputs (Array[Dictionary]), output_item_id, output_amount, required_station_id, craft_time_seconds, deprecated. Métodos `can_craft(inventory)` e `get_missing_inputs(inventory)`.
  - `scripts/crafting_station.gd` — `class_name CraftingStation extends Node`: catálogo de receitas, catálogo de itens (`_item_catalog`), `try_craft()` consome insumos e emite sinais `craft_completed`/`craft_failed`, `get_available_recipes_for()` e `get_craftable_recipes_for()`.
  - `data/items/clay_brick.tres`, `stone_flakes.tres` — novos ItemDefinitions de saída.
  - `data/recipes/clay_brick.tres`, `flint_knapping.tres` — receitas de mãos limpas.
  - `assets/sprites/crafting_bench.svg` — sprite SVG isométrico da bancada.
  - `scenes/entities/crafting_bench.tscn` — bancada: StaticBody2D + Sprite2D + Interactable + CraftingStation.
  - `tests/test_crafting.gd` — 17 asserts cobrindo can_craft, try_craft, consumo, falhas, estação errada, receita depreciada e filtragem.
- **Arquivos modificados:**
  - `scenes/tests/test_isometric_sandbox.gd` — integração completa: spawn da bancada, painel de fabricação lateral com lista de receitas, destaque por disponibilidade e feedback de resultado.
  - `scenes/tests/test_isometric_sandbox.tscn` — adicionado `CraftingPanel` com `RecipeList`, `CraftButton` e `CraftFeedback`.
- **Validações executadas:**
  - `--editor --headless --quit` → exit 0 (CraftingStation e RecipeDefinition registradas; crafting_bench.svg importado)
  - `--headless --quit-after 60` → exit 0, sem erros de script
  - `--headless --script tests/test_crafting.gd` → **17/17 testes passaram ✅**
- **Decisões técnicas:**
  - `RecipeDefinition extends Resource` para serialização `.tres` sem lógica de cena.
  - `CraftingStation` injeta `_item_catalog` via `register_item()` — sem autoload global; resolvível por cena.
  - Receita `deprecated = true` é barrada em tempo de execução sem remover o ID do histórico.
  - Painel de fabricação fecha ao interagir novamente com a bancada (toggle) e fecha o painel de diálogo.

### 2026-11-01 — Inventário e Coleta implementados (BK-011, BK-012)

- **Objetivo:** Modelar item/pilha e implementar o sistema de inventário do jogador com coleta de itens no mundo.
- **Branch:** `feature/fase-3-inventario`
- **Arquivos criados:**
  - `scripts/item_definition.gd` — `class_name ItemDefinition extends Resource`, 8 exports (id, display_name, description, category, icon, max_stack, weight, is_quest_item)
  - `scripts/item_slot.gd` — `class_name ItemSlot extends RefCounted`, representa uma pilha com `quantity` e `item`
  - `scripts/inventory.gd` — `class_name Inventory extends Node`, lógica de empilhamento e remoção, sinais `item_added`, `item_removed`, `inventory_updated`
  - `scripts/collectible_item.gd` — `class_name CollectibleItem extends Node2D`, integra `Interactable` com `Inventory`, suporte a coleta parcial
  - `assets/sprites/item_flint.svg`, `item_clay.svg`, `item_saltpeter.svg` — ícones SVG dos primeiros itens (sílex, argila, salitre)
  - `data/items/flint.tres`, `clay.tres`, `saltpeter.tres` — recursos `.tres` com `ItemDefinition`
  - `scenes/entities/collectible_item.tscn` — cena de item coletável (Node2D + Sprite2D + Interactable)
  - `tests/test_inventory.gd` — 19 asserts cobrindo add_item, empilhamento, overflow, remove, has_item, is_full
- **Arquivos modificados:**
  - `scripts/player_controller.gd` — adicionado `@onready var inventory: Inventory = $Inventory`
  - `scenes/entities/player.tscn` — adicionado nó filho `Inventory` (max_slots = 8)
  - `scenes/tests/test_isometric_sandbox.gd` — spawn de 6 coletáveis, hotbar dinâmica de 8 slots
  - `scenes/tests/test_isometric_sandbox.tscn` — adicionado `HotbarPanel`
- **Validações executadas:**
  - `--editor --headless --quit` → exit 0 (classes globais registradas: CollectibleItem, PlayerController, Inventory, ItemDefinition, ItemSlot)
  - `--headless --quit-after 60` → exit 0, sem erros de script
  - `--headless --script tests/test_inventory.gd` → **19/19 testes passaram ✅**
- **Decisões técnicas:**
  - `Inventory extends Node` (não Resource) para poder usar sinais e `_ready()` sem instância manual.
  - `ItemSlot extends RefCounted` (não Node) para manter inventário leve — sem nó na árvore por slot.
  - Coleta parcial suportada: se inventário cheio a metade, o item de chão retém o restante e atualiza o título.
  - Lambda GDScript não captura `int` mutável por referência; solução adotada: mover contadores para `Array[int]` de instância.


- Godot 4 instalado no Windows e o usuário confirmou que o projeto abre.
- Projeto de trabalho: `C:\Projetos\Renascimento`.
- Git instalado; versão observada anteriormente: `2.55.0.windows.5`.
- Commit inicial: `7aa9d06 chore: initialize Renascimento Godot project`.
- Pastas criadas: `scenes/`, `scripts/`, `assets/`, `data/`, `docs/`, `tests/`.
- A cópia local foi criada a partir da pasta no OneDrive; a pasta antiga deve ser mantida como backup até confirmar sincronização e versionamento remoto.
- O `git status` mostrou um arquivo não rastreado com nome estranho (`cimento Godot project...`). A remoção foi orientada, mas o resultado final precisa ser confirmado.
- Direção definida: Claude Code remoto trabalhando a partir de versões no Git; GitHub será o repositório remoto. A criação/publicação do repositório remoto ainda precisa ser confirmada.

### 2026-10-24 — Baseline confirmada (BK-001) e Convenções estabelecidas (BK-002)

- **Objetivo:** Confirmar a versão do motor, validar integridade do repositório remoto/local (BK-001) e formalizar a estrutura e convenções técnicas de código (BK-002).
- **Branch/commit:** `feature/fase-1-fundacao`
- **Arquivos alterados:**
  - `docs/07_riscos_e_pendencias.md`
  - `docs/04_criterios_de_aceitacao.md`
  - `docs/03_backlog.md`
  - `docs/02_especificacao_tecnica.md`
  - `docs/08_diario_de_desenvolvimento.md`
  - Arquivos `.gitkeep` em `assets/`, `data/`, `scenes/`, `scripts/`, `tests/`
- **Validações executadas:**
  - `Godot_v4.7.2-stable_win64_console.exe --version` retornou `4.7.2.stable.official.ed1daf0bf`.
  - `git status` e `git log -1 --oneline` confirmaram árvore limpa sobre commit `b4d27bb`.
  - `git ls-remote` confirmou sincronização do repositório remoto `https://github.com/Thiagogalva/renascimento.git`.
  - Critérios de aceitação AT-001 a AT-009 validados.
- **Resultado:** BK-001 e BK-002 concluídos com sucesso.
- **Decisões aprovadas:** Nenhuma decisão alterada; DEC-001 confirmada com Godot 4.7.2.
- **Pendências:** Iniciar BK-003 (IDs estáveis e catálogo de modelos de dados conceituais).

### 2026-10-24 — IDs estáveis e modelos conceituais de dados (BK-003)

- **Objetivo:** Estabelecer arquitetura técnica de IDs, namespaces por domínio, campos conceituais mínimos para entidades, políticas de migração/depreciação e catálogo conceitual provisório para o primeiro protótipo.
- **Branch/commit:** `feature/fase-1-fundacao`
- **Arquivos alterados:**
  - `docs/02_especificacao_tecnica.md`
  - `docs/03_backlog.md`
  - `docs/04_criterios_de_aceitacao.md`
  - `docs/08_diario_de_desenvolvimento.md`
- **Validações executadas:**
  - Critérios de aceitação AT-010 a AT-014 validados.
  - Verificada conformidade estrita de unicidade, desacoplamento semântico (`display_name_key`) e política de depreciação/fallback seguro.
- **Resultado:** BK-003 concluído com sucesso sem introdução prematura de scripts de gameplay.
- **Decisões aprovadas:** Nenhuma decisão violada; DEC-008 e DEC-009 respeitadas nos campos dos modelos conceituais.
- **Pendências:** Concluído. Iniciar BK-004 e BK-005.

### 2026-10-24 — Cenas-base, inputs e planejamento da cena isométrica (BK-004 e BK-005)

- **Objetivo:** Projetar o mapa conceitual de cenas (separando apresentação e domínio), mapear ações semânticas de input para PC e Android, avaliar renderers (Forward+ vs Compatibility) e definir as especificações técnicas da cena de teste isométrica (grid 2:1, Y-Sort, colisão na base e câmera).
- **Branch/commit:** `feature/fase-1-fundacao`
- **Arquivos alterados:**
  - `docs/02_especificacao_tecnica.md`
  - `docs/03_backlog.md`
  - `docs/04_criterios_de_aceitacao.md`
  - `docs/08_diario_de_desenvolvimento.md`
- **Validações executadas:**
  - Critérios de aceitação AT-015 a AT-021 validados.
  - Verificada separação de responsabilidades (HUD independente, World sem regras de inventário).
  - Verificado que `project.godot` não sofreu alterações não autorizadas (`AT-017`).
- **Pendências:** Concluído. Iniciar implementação prática da cena isométrica.

### 2026-10-24 — Implementação da cena de teste isométrica e movimentação (BK-006 e BK-007)

- **Objetivo:** Criar e validar o primeiro protótipo funcional de cena isométrica: assets em SVG, player com física `CharacterBody2D`, câmera com suavização, obstáculos com colisão na base e ordenação de profundidade Y-Sort ativa.
- **Branch/commit:** `feature/fase-2-cena-isometrica`
- **Arquivos alterados:**
  - `project.godot` (configuração de `run/main_scene` e mapeamento de inputs `move_left`, `move_right`, `move_up`, `move_down`, `interact`)
  - `assets/sprites/iso_ground_tile.svg` e `.import` (tile isométrico 2:1)
  - `assets/sprites/obstacle_pillar.svg` e `.import` (pilar de ruína estático)
  - `assets/sprites/player_placeholder.svg` e `.import` (personagem sobrevivente)
  - `scripts/player_controller.gd` (controlador de física isométrica 2:1)
  - `scenes/entities/player.tscn` (cena do jogador com colisor de pés e Y-Sort)
  - `scenes/entities/test_obstacle.tscn` (cena de pilar com colisor na base)
  - `scenes/tests/test_isometric_sandbox.tscn` e `.gd` (cena completa do sandbox isométrico)
  - `docs/03_backlog.md` (BK-006 e BK-007 marcadas como Concluídas)
  - `docs/08_diario_de_desenvolvimento.md`
- **Validações executadas:**
  - Importação de assets executada pelo editor Godot 4.7.2 em modo headless (`--editor --headless --quit`).
  - Execução e carregamento da cena principal validados via Godot CLI (`--headless --quit` e teste de 60 frames com `--quit-after 60`), retornando código 0 sem nenhum erro ou aviso.
  - Grade isométrica 2:1 (128x64px), Y-Sort dinâmico e colisores de pés validados.
- **Pendências:** Concluído. Iniciar implementação do sistema de interação.

### 2026-10-24 — Sistema de interação e estátua petrificada (BK-008 e BK-009)

- **Objetivo:** Projetar e implementar o subsistema de interação desacoplado: componente `Interactable` com detecção de proximidade, prompt flutuante automático sobre alvos, priorização pelo alvo mais próximo no jogador e feedback de inspeção científica no HUD.
- **Branch/commit:** `feature/fase-2-cena-isometrica`
- **Arquivos alterados:**
  - `scripts/interactable.gd` (componente reutilizável de interação)
  - `scripts/player_controller.gd` (adicionada lógica de detecção de área e priorização de alvo)
  - `scenes/entities/player.tscn` (adicionado `InteractionDetector` com shape circular de 52px)
  - `assets/sprites/petrified_statue.svg` e `.import` (sprite vetorial da estátua petrificada com musgo)
  - `scenes/entities/petrified_statue.tscn` (entidade com física de base e componente de inspeção de estátua)
  - `scenes/entities/test_obstacle.tscn` (adicionado componente de inspeção de calcário)
  - `scenes/tests/test_isometric_sandbox.tscn` e `.gd` (painel inferior de diálogo científico e integração)
  - `tests/test_interaction.gd` (teste automatizado headless validando detecção, foco e evento)
  - `docs/03_backlog.md` (BK-008 e BK-009 marcadas como Concluídas)
  - `docs/08_diario_de_desenvolvimento.md`
- **Validações executadas:**
  - Teste unitário headless executado via `Godot_v4.7.2 -s res://tests/test_interaction.gd`: detecção de alvo mais próximo, ativação de prompt e sinal de interação aprovados com sucesso.
  - Execução e carregamento da cena de teste em headless (`--quit-after 60`): código de saída 0 sem warnings ou erros.
- **Resultado:** BK-008 e BK-009 concluídas com sucesso. O jogador agora pode se aproximar de pilares de ruína ou da estátua petrificada, visualizar o indicador flutuante `[E] Inspecionar` e acionar o log científico.
- **Decisões aprovadas:** DEC-011 e DEC-012 cumpridas com o primeiro objeto investigativo do loop científico.
- **Pendências:** BK-010 (validação de controles táteis para Android) ou avanço para a Fase 3 (Inventário e Coleta).

## Modelo para próximas entradas

### AAAA-MM-DD — título curto

- Objetivo:
- Branch/commit:
- Arquivos alterados:
- Validações executadas:
- Resultado:
- Decisões aprovadas:
- Pendências:
