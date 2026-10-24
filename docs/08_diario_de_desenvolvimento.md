# 08 — Diário de desenvolvimento

Registre fatos verificáveis. Não incluir tokens, senhas, dados privados ou suposições como se fossem fatos.

## 2026-10 — Fundação local

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
- **Resultado:** Protótipo funcional de movimentação e teste isométrico operando perfeitamente.
- **Decisões aprovadas:** DEC-001 (Godot 4), DEC-003 (2D isométrico) aplicadas diretamente.
- **Pendências:** Implementar sistema básico de interação (BK-008 e BK-009).

## Modelo para próximas entradas

### AAAA-MM-DD — título curto

- Objetivo:
- Branch/commit:
- Arquivos alterados:
- Validações executadas:
- Resultado:
- Decisões aprovadas:
- Pendências:
