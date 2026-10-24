# 04 — Critérios de aceitação e validação

## Princípio

Critérios verificáveis devem acompanhar cada entrega. Não considerar “parece funcionar” como teste suficiente. Distinguir testes executados, testes planejados e testes impossíveis no ambiente atual.

## Fase 1 — critérios gerais

### BK-001 — baseline

- [x] AT-001: o repositório contém `project.godot` e os arquivos de configuração esperados. *(Validado: project.godot, .gitignore, .gitattributes presentes).*
- [x] AT-002: `git status` não mostra alterações inesperadas após o commit. *(Validado: working tree clean na baseline).*
- [x] AT-003: o projeto abre no Godot 4 instalado localmente. *(Validado: executável Godot 4.7.2 funcional no ambiente).*
- [x] AT-004: nenhum arquivo temporário foi incluído no commit inicial. *(Validado: histórico e pastas limpos).*
- [x] AT-005: a versão real do Godot é registrada quando confirmada; não presumir um patch específico. *(Validado: versão exata Godot 4.7.2.stable.official.ed1daf0bf).*

### BK-002 — estrutura e convenções

- [x] AT-006: cada pasta existente tem propósito documentado. *(Validado: seções detalhadas em docs/02_especificacao_tecnica.md).*
- [x] AT-007: regras de nomes e organização estão escritas. *(Validado: convenções GDScript, cenas, dados e ativos documentadas).*
- [x] AT-008: não há movimentação ampla de arquivos sem necessidade demonstrada. *(Validado: estrutura original preservada sem quebras).*
- [x] AT-009: arquivos vazios não são considerados parte efetiva do versionamento sem um arquivo justificável. *(Validado: arquivos .gitkeep adicionados nas pastas-raiz para persistência no Git).*

### BK-003 — IDs e modelos de dados

- [x] AT-010: cada categoria de entidade tem convenção de ID documentada. *(Validado: tabela de namespaces por domínio na Seção 4.2 de docs/02_especificacao_tecnica.md).*
- [x] AT-011: IDs não dependem de texto exibido, índices ou caminhos de cena. *(Validado: desacoplamento semântico estrito e display_name_key implementados).*
- [x] AT-012: alterações de nomes exibidos não exigem alteração de ID. *(Validado: regra de imutabilidade técnica e separação de localização).*
- [x] AT-013: exemplos estão identificados como exemplos até aprovação. *(Validado: catálogo da Seção 4.5 identificado explicitamente como provisório para validação).*
- [x] AT-014: há política para IDs removidos e saves antigos. *(Validado: regras de depreciação, id_migration_map e fallback seguro descritas na Seção 4.4).*

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
