# 06 — Plano de execução da Fase 1 (BK-001 a BK-005)

## Objetivo

Deixar a base do projeto clara, versionada e pronta para iniciar a implementação posteriormente, sem criar mecânicas de jogo nesta fase.

## Estado conhecido antes da sessão remota

- Projeto local: `C:\Projetos\Renascimento`.
- Godot 4 foi instalado e o projeto abriu com sucesso segundo confirmação do usuário.
- Git instalado e repositório inicializado.
- Primeiro commit local: `7aa9d06 chore: initialize Renascimento Godot project`.
- Pastas existentes: `scenes/`, `scripts/`, `assets/`, `data/`, `docs/`, `tests/`.
- O estado do repositório GitHub remoto ainda precisa ser confirmado.
- A limpeza do arquivo estranho mencionado no terminal deve ser verificada por `git status`; não presumir que foi removido sem evidência.

## BK-001 — Confirmar baseline

**Ações**
1. Inspecionar `git status`, `git log -1 --oneline` e `project.godot`.
2. Verificar arquivos do projeto sem imprimir ou expor segredos.
3. Registrar versão do Godot somente se puder ser confirmada.
4. Conferir se os arquivos de documentação estão versionados.

**Saída:** baseline documentada e sem arquivos inesperados.

## BK-002 — Convenções e estrutura

**Ações**
1. Conferir a estrutura real de pastas.
2. Documentar o propósito de cada pasta.
3. Definir convenções para cenas, scripts, dados, assets e testes.
4. Não criar uma arquitetura excessivamente fragmentada.
5. Não mover arquivos sem justificativa e autorização se houver risco.

**Saída:** convenções em documento e estrutura consistente.

## BK-003 — IDs e modelos de dados conceituais

**Ações**
1. Propor namespace para IDs de itens, recursos, tecnologias, experimentos, NPCs, tarefas, estruturas, missões e campanhas.
2. Definir regras de unicidade e imutabilidade.
3. Separar ID técnico de nome exibido.
4. Definir campos conceituais mínimos para cada categoria.
5. Definir política de descontinuação e migração de IDs.
6. Identificar exemplos como provisórios até aprovação do usuário.

**Saída:** catálogo de modelos conceituais em documentação, sem scripts ou dados de gameplay implementados.

## BK-004 — Cenas, inputs e configurações

**Ações**
1. Propor mapa conceitual de cenas para inicialização, mundo de teste, jogador e UI.
2. Descrever responsabilidades sem criar as cenas funcionais ainda.
3. Listar ações de input abstratas, separadas de teclas específicas.
4. Mapear teclado/mouse e toque.
5. Inspecionar renderer e configurações existentes; não alterar sem justificativa.

**Saída:** plano de cenas e controles, sem implementar gameplay.

## BK-005 — Planejar cena de teste isométrica

**Ações**
1. Definir o que a cena deve comprovar: grade/orientação, câmera, ordenação visual e colisão.
2. Definir limites da cena e critérios de aceitação.
3. Identificar o que não será incluído: inventário, coleta, combate, crafting, ciência e multiplayer.
4. Preparar uma proposta de implementação e aguardar autorização antes de criar cena funcional.

**Saída:** especificação da cena de teste; sem código de jogo até autorização.

## Relatório de conclusão exigido

Ao final da Fase 1, apresentar:
- BK-001..BK-005 com estado individual;
- arquivos criados/alterados;
- decisões que precisam de resposta do usuário;
- comandos e verificações realmente executados;
- limitações do ambiente remoto;
- riscos remanescentes;
- recomendação para o próximo passo.

Não marcar uma tarefa como concluída apenas porque a documentação foi criada se ainda faltar algum critério de aceitação.
