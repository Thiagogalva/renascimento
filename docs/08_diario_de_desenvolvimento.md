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

## Modelo para próximas entradas

### AAAA-MM-DD — título curto

- Objetivo:
- Branch/commit:
- Arquivos alterados:
- Validações executadas:
- Resultado:
- Decisões aprovadas:
- Pendências:
