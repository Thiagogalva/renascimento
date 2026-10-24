# Instruções para Claude Code — Renascimento

## Papel

Atue como analista técnico, arquiteto de software e desenvolvedor Godot experiente. Trabalhe em incrementos pequenos, verificáveis e reversíveis. Priorize consistência com os documentos do projeto em vez de inventar requisitos.

## Leitura obrigatória

Antes de qualquer alteração:
1. Leia este arquivo por completo.
2. Leia `docs/00_visao_geral.md`, `docs/05_decisoes_de_projeto.md`, `docs/02_especificacao_tecnica.md` e a tarefa correspondente em `docs/03_backlog.md`.
3. Verifique a estrutura real do repositório, o estado do Git, a versão do Godot configurada e os arquivos já existentes.
4. Compare os documentos com o estado atual do projeto. Não presuma que um item de backlog já foi implementado.

## Restrições obrigatórias

- Não implemente código de gameplay até o usuário autorizar explicitamente essa etapa.
- A primeira atividade é revisar e preparar a documentação e a estrutura da Fase 1 (BK-001 a BK-005), não criar o jogo inteiro.
- Não reescreva nem remova arquivos existentes sem explicar a necessidade e obter autorização quando houver risco de perda.
- Não substitua decisões confirmadas por preferências próprias.
- Não introduza plugins, addons, dependências, serviços pagos, bibliotecas externas ou ferramentas de build sem explicar o motivo e pedir aprovação.
- Não inclua segredos, tokens, senhas ou credenciais no repositório.
- Não copie conteúdo protegido de Dr. Stone. Use apenas a referência de alto nível: progressão científica, experimentação, reconstrução e sobrevivência.
- Não declare que algo foi testado se não executou o teste. Registre limitações do ambiente remoto, principalmente quando não houver editor Godot ou export templates disponíveis.
- Evite mudanças amplas. Uma tarefa deve produzir uma alteração coerente, pequena e revisável.
- Não faça merge de pull requests, não publique releases e não altere configurações de acesso do GitHub sem autorização.

## Fluxo de trabalho esperado

Para cada tarefa:
1. Informe o objetivo e os arquivos que pretende alterar.
2. Liste pressupostos e dúvidas que possam mudar o resultado. Se uma decisão essencial estiver ausente, pare e pergunte; não invente.
3. Faça a menor alteração compatível com a tarefa autorizada.
4. Revise o diff e procure inconsistências, arquivos temporários, conteúdo duplicado e alterações fora do escopo.
5. Execute apenas validações realmente disponíveis e registre os comandos/resultados.
6. Atualize a documentação relacionada quando uma decisão ou comportamento mudar.
7. Entregue resumo, arquivos alterados, validações executadas, limitações e próximos passos.
8. Trabalhe em branch separada e abra pull request; não faça merge.

## Prioridade inicial

Trabalhe somente em BK-001 a BK-005, conforme `docs/06_plano_fase_1.md`. Os documentos podem ser refinados, mas não inicie movimentação, inventário, crafting, ciência jogável, NPCs, persistência funcional, combate ou multiplayer.

## Convenções

- IDs de backlog: `BK-NNN`.
- Regras de validação: `RV-NN`.
- Testes de aceitação: `AT-NN` para critérios gerais e `MP-NN` para multiplayer/PvP.
- Decisões: `DEC-NNN`.
- Requisitos: `REQ-NNN`.
- Use nomes de arquivos e identificadores estáveis, sem acentos em identificadores técnicos.
- Mantenha documentação em português brasileiro, salvo termos técnicos e nomes de APIs.
- Não crie um identificador novo se já existir um equivalente. Pesquise antes.
