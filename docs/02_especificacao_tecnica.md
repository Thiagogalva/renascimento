# 02 — Especificação técnica inicial

## 1. Stack

- Godot 4.x.
- GDScript.
- Alvos: PC e Android.
- Perspectiva: 2D isométrica.
- Git para versionamento; GitHub para colaboração e integração remota.
- O renderer Compatibility é candidato para facilitar compatibilidade; não alterar a configuração existente sem conferir o projeto e justificar.

## 2. Princípios de arquitetura

1. **Dados separados da lógica:** itens, receitas, recursos, tecnologias, NPCs e tarefas devem evoluir para definições de dados.
2. **IDs estáveis:** save files, referências de missão e rede não devem depender de nome exibido, posição em lista ou caminho de nó.
3. **Separação de responsabilidades:** apresentação, regras do jogo, persistência e rede não devem ficar concentradas em um único script.
4. **Autoridade de campanha:** no multiplayer, o host valida operações que alteram estado compartilhado.
5. **Persistência versionada:** arquivos de campanha devem possuir versão de esquema e caminho de migração documentado antes de se tornarem dependência de conteúdo.
6. **Pequenos incrementos:** validar cada subsistema antes de integrar outro.
7. **Compatibilidade de plataforma:** considerar tela sensível ao toque, escalabilidade da UI, memória e performance desde o planejamento, sem otimização prematura.
8. **Testabilidade:** regras importantes devem poder ser testadas sem depender exclusivamente de interação visual.

## 3. Estrutura de pastas e convenções

A estrutura do projeto é desenhada para desacoplar dados, lógica e apresentação, permitindo crescimento escalável sem dependências frágeis:

### 3.1. Propósito de cada pasta

- **`assets/`** — Arquivos brutos e importados de mídia (sprites, texturas, modelos, efeitos sonoros, músicas e fontes). Subpastas recomendadas conforme surgirem ativos: `assets/sprites/`, `assets/audio/`, `assets/fonts/`, `assets/ui/`.
- **`data/`** — Definições puras de dados em formato de recursos Godot (`.tres`) ou tabelas (`.json`), como catálogo de itens, tecnologias, experimentos e propriedades físicas/químicas. Nunca misturar com cenas ou lógica de apresentação.
- **`docs/`** — Documentação viva do projeto em Markdown (arquitetura, decisões, backlog, critérios de aceitação e diário).
- **`scenes/`** — Cenas do Godot (`.tscn`). Organizadas por contexto de responsabilidade:
  - `scenes/ui/`: Interfaces de usuário, HUD, menus, popups e diálogos.
  - `scenes/world/`: Mapas, chunks, biomas, grid isométrica e gerenciadores de ambiente.
  - `scenes/entities/`: Personagens (jogador, sobreviventes, NPCs), estátuas e objetos interativos.
  - `scenes/components/`: Nós e subcenas reutilizáveis (ex.: áreas de interação, barras de status).
- **`scripts/`** — Scripts GDScript (`.gd`) que representam utilitários globais, autoloads/singletons, classes-base, sistemas puros de dados e regras de negócio sem acoplamento a um nó específico.
- **`tests/`** — Scripts e cenas de teste automatizado (testes unitários e cenários de integração/regras de validação).

### 3.2. Convenções de nomenclatura e estilo

- **Arquivos e Pastas:** sempre em `snake_case` em minúsculas, sem caracteres especiais ou espaços (ex.: `player_movement.gd`, `inventory_slot.tscn`, `iron_ore.tres`).
- **Nomes de Nós na Árvore de Cenas:** `PascalCase` descritivo (ex.: `PlayerCamera`, `InteractionDetector`, `CollisionShape2D`).
- **Nomes de Classes (`class_name`):** `PascalCase` (ex.: `class_name ItemDefinition`, `class_name ExperimentManager`).
- **Constantes e Enums:** `UPPER_SNAKE_CASE` (ex.: `MAX_STACK_SIZE`, `enum InteractionType { GATHER, EXAMINE, CRAFT }`).
- **Variáveis e Funções:** `snake_case` (ex.: `current_health`, `func calculate_reaction_time() -> float:`).
- **Membros e Funções Privadas/Internas:** prefixadas com underscore `_` (ex.: `var _internal_state: int`, `func _validate_slot() -> bool:`).
- **Sinais (Signals):** `snake_case`, sempre no pretérito ou indicativo de conclusão do evento (ex.: `signal item_added(item_id, amount)`, `signal experiment_completed(result)`).
- **Tipagem Estática:** Obrigatória no GDScript 2.0 para variáveis, parâmetros e retornos de função, reduzindo bugs em runtime e facilitando refatoração.

## 4. IDs estáveis e modelos de dados conceituais

Para garantir integridade de saves, sincronização em rede e escalabilidade sem dependência de strings localizadas ou índices de array, todo o conteúdo do jogo é governado por regras estritas de identidade técnica.

### 4.1. Regras fundamentais de IDs

1. **Unicidade Absoluta:** Cada ID técnico deve ser único em todo o escopo do projeto.
2. **Imutabilidade Permanente:** Uma vez publicado ou gravado em um arquivo de campanha, o ID técnico nunca é renomeado ou reutilizado para outra entidade.
3. **Desacoplamento de Apresentação:** Textos exibidos ao jogador (`display_name`, títulos, descrições e traduções) podem ser alterados livremente sem afetar o ID técnico subjacente.
4. **Formato Sintático:** Caracteres minúsculos ASCII `[a-z0-9_]` organizados hierarquicamente por pontos (`.`). Não usar acentos, espaços, hífens ou caracteres especiais.

### 4.2. Padrão de Namespaces por Domínio

| Domínio | Padrão do Namespace | Exemplo Conceitual |
|---|---|---|
| **Itens (matérias-primas)** | `item.raw.<nome>` | `item.raw.clay`, `item.raw.flint`, `item.raw.saltpeter` |
| **Itens (química e reagentes)** | `item.chemical.<nome>` | `item.chemical.distilled_alcohol`, `item.chemical.nitric_acid` |
| **Itens (ferramentas e recipientes)** | `item.tool.<nome>` | `item.tool.clay_crucible`, `item.tool.stone_mortar` |
| **Itens (compostos especiais)** | `item.compound.<nome>` | `item.compound.revival_formula` |
| **Recursos de Ambiente** | `resource.<categoria>.<nome>` | `resource.deposit.saltpeter`, `resource.water.river_spring` |
| **Tecnologias e Conhecimento** | `tech.<ramo>.<nome>` | `tech.chemistry.calcination`, `tech.biology.revival_solution` |
| **Experimentos Científicos** | `experiment.<processo>.<nome>` | `experiment.distillation.alcohol`, `experiment.synthesis.nitric_acid` |
| **NPCs e Sobreviventes** | `npc.<papel>.<nome>` | `npc.craftsman.tatsuo`, `npc.scout.maya` |
| **Tarefas de Comunidade** | `task.<tipo>.<nome>` | `task.gather.river_clay`, `task.craft.charcoal` |
| **Estruturas e Bancadas** | `structure.<tipo>.<nome>` | `structure.station.alembic_still`, `structure.kiln.clay_furnace` |
| **Missões e Marcos** | `quest.<arco>.<nome>` | `quest.prologue.first_spark`, `quest.revival.awaken_craftsman` |
| **Campanhas e Sessões** | `campaign.<uuid>` | `campaign.c4a1b8e9_7dec_41d0_a765_00a0c91e6bf6` |

### 4.3. Modelos Conceituais Mínimos (Especificação de Campos)

Cada categoria possui uma especificação mínima obrigatória para evitar campos nulos e garantir integridade:

* **Item (`ItemDefinition`):**
  - `id: StringName` (ID técnico único).
  - `display_name_key: String` (chave de localização para o nome visível).
  - `description_key: String` (chave de localização da descrição).
  - `category: enum ItemCategory` (`RAW`, `CHEMICAL`, `TOOL`, `COMPOUND`, `CONSUMABLE`).
  - `max_stack: int` (tamanho máximo de pilha no inventário).
  - `weight: float` (peso unitário).
  - `is_quest_item: bool` (se verdadeiro, imune a descarte acidental).
  - `is_pvp_lootable: bool` (se falso, nunca entra no saque de derrota PvP, conforme RV-06).

* **Recurso Coletável de Ambiente (`WorldResourceDefinition`):**
  - `id: StringName`.
  - `yield_item_id: StringName` (ID do item gerado na coleta).
  - `yield_quantity_range: Vector2i` (quantidade mínima e máxima).
  - `required_tool_category: StringName` (categoria de ferramenta exigida ou vazio para mãos limpas).
  - `hardness_tier: int` (nível mínimo de ferramenta exigido).
  - `respawn_time_seconds: float` (tempo para reaparecer no mundo, ou 0 se for depósito finito).

* **Tecnologia (`TechDefinition`):**
  - `id: StringName`.
  - `prerequisite_tech_ids: Array[StringName]` (tecnologias que precisam ser dominadas antes).
  - `required_experiment_ids: Array[StringName]` (experimentos que precisam ter sido concluídos).
  - `unlocked_recipes: Array[StringName]` (novas receitas desbloqueadas).
  - `unlocked_structures: Array[StringName]` (novas estruturas desbloqueadas).

* **Experimento Científico (`ExperimentDefinition`):**
  - `id: StringName`.
  - `station_required: StringName` (estrutura necessária, ex.: `structure.station.alembic_still`).
  - `inputs: Array[Dictionary]` (lista de `{ "item_id": StringName, "amount": int }`).
  - `conditions: Dictionary` (fatores ambientais ou de processo: `{ "min_heat": int, "duration_seconds": float }`).
  - `outputs_success: Array[Dictionary]` (itens resultantes em caso de sucesso).
  - `outputs_failure: Array[Dictionary]` (subprodutos ou resíduos didáticos em caso de falha).
  - `discovery_unlock_tech: StringName` (tecnologia desbloqueada na primeira conclusão com sucesso).

* **NPC / Sobrevivente (`NPCDefinition`):**
  - `id: StringName`.
  - `character_name: String` (nome próprio).
  - `initial_state: enum NPCState` (`PETRIFIED`, `AWAKENED`, `ASSIGNED`, `RESTING`).
  - `specialty_skills: Dictionary` (perfil de aptidões, ex.: `{ "crafting": 3, "gathering": 1 }`).
  - `revival_compound_id: StringName` (composto químico necessário para despetrificar).

* **Tarefa Atribuível (`TaskDefinition`):**
  - `id: StringName`.
  - `required_skill: StringName` (habilidade do NPC necessária).
  - `duration_seconds: float` (tempo base para conclusão do ciclo da tarefa).
  - `inputs: Array[Dictionary]` (insumos consumidos da despensa/baú do acampamento).
  - `outputs: Array[Dictionary]` (recursos produzidos ao concluir).

* **Estrutura / Bancada (`StructureDefinition`):**
  - `id: StringName`.
  - `build_cost: Array[Dictionary]` (materiais exigidos para construção).
  - `footprint: Vector2i` (dimensão ocupada na grade isométrica).
  - `interaction_type: enum InteractionType` (`CRAFT`, `EXPERIMENT`, `STORAGE`, `REST`).
  - `pvp_immune: bool = true` (estruturas são imunes a dano de PvP, conforme DEC-009 e RV-08).

### 4.4. Política de Descontinuação e Migração de IDs

Para garantir que atualizações do jogo nunca quebrem saves existentes:
1. **Regra de Não-Exclusão:** IDs técnicos existentes nunca são removidos das tabelas históricas do jogo, mesmo se deixarem de surgir naturalmente no mundo.
2. **Depreciação (`deprecated: true`):** Quando um item ou processo for reformulado ou descontinuado, sua definição recebe a marcação de depreciação.
3. **Mapeamento de Migração:** O sistema de save mantém um dicionário de migração de versões:
   - Exemplo: `id_migration_map = { "item.raw.crude_clay": "item.raw.clay" }`.
4. **Tratamento de Fallback Seguro:** Caso um save referencie um ID que não exista na versão atual do jogo, o carregador converte o dado para um objeto substituto seguro (`item.fallback.unknown_relic`) mantendo metadados originais para evitar corrupção ou travamento.

### 4.5. Catálogo Conceitual Provisório (Primeiro Protótipo)

*Nota: Os exemplos abaixo são parâmetros conceituais provisórios destinados a validar o ciclo do primeiro protótipo, pendentes de aprovação final do usuário (AT-013).*

* **Itens e Reagentes:**
  - `item.raw.flint` — Pederneira/Sílex para faíscas e corte primitivo.
  - `item.raw.clay` — Argila para moldagem de refratários e recipientes.
  - `item.raw.saltpeter` — Salitre (nitrato de potássio bruto) coletado em depósitos orgânicos/cavernas.
  - `item.raw.calcium_carbonate` — Conchas marinhas ou rocha calcária triturada.
  - `item.raw.wild_berries` — Bagas silvestres açucaradas para fermentação inicial.
  - `item.chemical.fermented_must` — Mosto fermentado contendo álcool bruto.
  - `item.chemical.distilled_alcohol` — Etanol concentrado obtido por destilação.
  - `item.chemical.nitric_acid` — Ácido nítrico puro extraído de salitre e reagentes.
  - `item.compound.revival_formula` — Solução milagrosa de despetrificação.
  - `item.tool.clay_crucible` — Cadinho cerâmico resistente a altas temperaturas.
  - `item.tool.alembic_tube` — Tubo de condensação de cerâmica.
* **Recursos de Ambiente:**
  - `resource.deposit.clay_bed` — Jazida de argila úmida na margem do rio.
  - `resource.deposit.limestone` — Afloramento de calcário.
  - `resource.flora.berry_bush` — Arbusto silvestre com frutos sazonais.
  - `resource.water.fresh_stream` — Fonte de água doce limpa.
* **Estruturas:**
  - `structure.station.clay_kiln` — Forno de barro para queima de cerâmica e calcinação.
  - `structure.station.alembic_still` — Alambique rudimentar para destilação fracionada de álcool.
  - `structure.monument.petrified_survivor` — Estátua petrificada do artesão encontrada na ruína.
* **Experimentos:**
  - `experiment.synthesis.distilled_alcohol` — Purificação de álcool por calor brando e condensação.
  - `experiment.synthesis.nitric_acid` — Reação de salitre com ácido sulfúrico/calcinação para obtenção de ácido nítrico.
  - `experiment.synthesis.revival_compound` — Equilíbrio estequiométrico preciso entre etanol e ácido nítrico.
* **NPC e Tarefa:**
  - `npc.craftsman.tatsuo` — Primeiro sobrevivente recuperável (habilidade: marcenaria e cerâmica avançada).
  - `task.gather.clay_deposits` — Tarefa atribuível ao sobrevivente para coleta contínua de argila.

## 5. Salvamento e carregamento

O sistema de save futuro deve registrar, no mínimo, versão do formato, ID da campanha, estado de mundo necessário, inventários, construções, estado dos NPCs/tarefas e estado de progressão científica. O esquema definitivo precisa ser aprovado antes da implementação.

Regras previstas:
- Validar integridade e versão antes de carregar.
- Não sobrescrever save válido com dados inválidos.
- Falhas devem produzir mensagem clara e manter o arquivo original.
- Migrações de versão devem ser explícitas e testáveis.
- O estado oficial da campanha é controlado pelo host durante multiplayer.
- Ao sair o host, a campanha pausa; não há progressão offline.
- Transferência manual de host usa arquivo válido de campanha. Não prometer compatibilidade de saves entre versões até que seja testada.

## 6. Multiplayer

### Modelo

- Máximo de quatro jogadores.
- Host-authoritative: clientes solicitam ações; host valida e aplica mudanças ao estado oficial.
- Não confiar em cliente para quantidades, propriedade, alcance, cooldown, resultados de combate ou transferências de itens.
- Mensagens de rede devem ser validadas quanto a formato, autorização, estado atual e limites.
- Operações críticas devem ser idempotentes quando houver risco de repetição.

### Desconexão

- Personagem desconectado permanece no mundo em estado de sono/repouso com IA limitada.
- Reconexão restaura o mesmo personagem, evitando duplicação de inventário ou personagem.
- O comportamento de segurança durante desconexão precisa ser especificado antes da implementação.

### Saída do host

- A campanha pausa quando o host encerra a sessão.
- Não simular progresso enquanto a campanha está offline.
- Transferência manual de host é planejada; migração automática não faz parte do escopo inicial.

## 7. PvP e saque

Parâmetros abaixo são valores iniciais provisórios e devem ser configuráveis, não constantes espalhadas pelo código.

- PvP opcional e consentido por confronto individual (`single`).
- Expiração inicial do convite: 30 segundos.
- Perda de saque: limitada (`limited`), no máximo 3 unidades e 2 tipos de item por derrota, como valores iniciais.
- Proteção temporária após derrota (`temporary`): 120 segundos de tempo de jogo; o temporizador pausa quando a campanha está pausada.
- Estruturas não sofrem dano de PvP.
- Itens essenciais para missões, descobertas/evidências científicas únicas, itens reservados e itens marcados como não saqueáveis são excluídos do saque.
- Transferência de saque deve ser atômica e idempotente.
- O host valida consentimento, participantes, distância/estado, elegibilidade dos itens, limites, proteção e resultado do confronto.
- Falhas ou duplicação de mensagens não podem duplicar nem destruir itens.

## 8. Segurança e integridade

- Validar entrada do usuário e dados carregados.
- Nunca confiar em estado informado por cliente.
- Não incluir credenciais em arquivos versionados.
- Evitar execução de comandos externos desnecessários.
- Documentar qualquer addon e sua licença antes de incorporá-lo.
- Tratar arquivos de campanha como dados não confiáveis.

## 9. Plataforma e desempenho

PC e Android são alvos. Decisões de resolução, controles, UI, memória e renderização devem ser verificadas no hardware disponível. Não declarar suporte final a dispositivos sem teste. O protótipo deve medir performance antes de definir limites de mundo ou população.

## 10. Estado da especificação

Esta é uma base inicial. A arquitetura detalhada de rede, esquema final de save, fórmulas de combate, sistemas de sobrevivência e pipeline de exportação continuam pendentes. Não inventar esses detalhes durante a Fase 1.
