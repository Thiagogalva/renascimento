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

## 4. IDs e dados

- IDs técnicos devem ser únicos, permanentes e sem acentos.
- Preferir identificadores semânticos em minúsculas, com namespace por tipo, por exemplo `item.flint`, `resource.fresh_water`, `tech.basic_pottery`, `npc.first_survivor`, `quest.revival_trial`.
- Os exemplos são ilustrativos; verificar colisões antes de adotá-los como IDs definitivos.
- Nome de exibição pode ser traduzido ou alterado sem alterar o ID.
- Nunca usar índice de array, nome de nó ou texto localizado como identidade persistente.
- Ao remover conteúdo já usado por saves, planejar migração/depreciação em vez de reciclar o ID.

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
