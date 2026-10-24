# 04 — Critérios de aceitação e validação

## Princípio

Critérios verificáveis devem acompanhar cada entrega. Não considerar “parece funcionar” como teste suficiente. Distinguir testes executados, testes planejados e testes impossíveis no ambiente atual.

## Fase 1 — critérios gerais

### BK-001 — baseline

- AT-001: o repositório contém `project.godot` e os arquivos de configuração esperados.
- AT-002: `git status` não mostra alterações inesperadas após o commit.
- AT-003: o projeto abre no Godot 4 instalado localmente.
- AT-004: nenhum arquivo temporário foi incluído no commit inicial.
- AT-005: a versão real do Godot é registrada quando confirmada; não presumir um patch específico.

### BK-002 — estrutura e convenções

- AT-006: cada pasta existente tem propósito documentado.
- AT-007: regras de nomes e organização estão escritas.
- AT-008: não há movimentação ampla de arquivos sem necessidade demonstrada.
- AT-009: arquivos vazios não são considerados parte efetiva do versionamento sem um arquivo justificável.

### BK-003 — IDs e modelos de dados

- AT-010: cada categoria de entidade tem convenção de ID documentada.
- AT-011: IDs não dependem de texto exibido, índices ou caminhos de cena.
- AT-012: alterações de nomes exibidos não exigem alteração de ID.
- AT-013: exemplos estão identificados como exemplos até aprovação.
- AT-014: há política para IDs removidos e saves antigos.

### BK-004 — cenas, inputs e configurações

- AT-015: mapa conceitual de cenas separa apresentação e regras.
- AT-016: ações de input planejadas cobrem teclado/mouse e toque.
- AT-017: nenhuma configuração é alterada sem comparação com o projeto existente.
- AT-018: necessidades de PC/Android e renderer candidato são documentadas.

### BK-005 — cena de teste isométrica

- AT-019: há critérios de validação para orientação da grade, câmera, ordenação visual e colisão.
- AT-020: o escopo da cena de teste é mínimo e não inclui sistemas de gameplay.
- AT-021: a implementação da cena funcional só começa após autorização explícita.

## Regras de validação — multiplayer/PvP (planejadas para fases futuras)

- RV-01: o host é autoridade para alterações do estado compartilhado.
- RV-02: o cliente não pode determinar unilateralmente quantidades, resultados ou propriedade.
- RV-03: cada confronto PvP exige consentimento específico válido.
- RV-04: convite de PvP expira após 30 segundos inicialmente, em parâmetro configurável.
- RV-05: o limite inicial de saque é 3 unidades e 2 tipos de item por derrota, configurável.
- RV-06: itens essenciais, evidências científicas únicas, itens reservados e itens não saqueáveis nunca entram no saque PvP.
- RV-07: transferências de saque são atômicas e idempotentes.
- RV-08: estruturas não sofrem dano de PvP.
- RV-09: proteção pós-derrota dura inicialmente 120 segundos de tempo de jogo e pausa com a campanha.
- RV-10: ao desconectar, o personagem é preservado e fica em estado de repouso/sono com IA limitada.
- RV-11: reconexão restaura o mesmo personagem sem duplicar entidade ou inventário.
- RV-12: encerramento do host pausa a campanha.
- RV-13: nenhuma progressão é simulada enquanto a campanha está offline.
- RV-14: transferência manual de host aceita somente arquivo de campanha válido.
- RV-15: falhas de rede não podem duplicar nem destruir itens em operações críticas.

## Testes de aceitação multiplayer (planejados)

Os casos MP-01 a MP-25 devem ser detalhados antes da implementação do multiplayer. Cobrirão pelo menos:
- ingresso de até quatro jogadores;
- autoridade do host;
- tentativa de ação inválida de cliente;
- desconexão e reconexão;
- encerramento/pausa do host;
- consentimento, expiração e cancelamento de PvP;
- limite e elegibilidade do saque;
- proteção pós-derrota;
- imunidade de estruturas a dano de PvP;
- mensagens repetidas e operações idempotentes;
- transferência manual de host;
- arquivo de campanha inválido ou de versão incompatível.

Não declarar MP-01..MP-25 aprovados sem testes reais. Criar os casos detalhados no backlog de multiplayer, antes de BK-033/BK-040/BK-041.
