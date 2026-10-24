# 05 — Registro de decisões do projeto

Use este arquivo como fonte principal para decisões confirmadas. Alterar uma decisão exige registrar o motivo, impacto, data e aprovação do usuário.

## DEC-001 — Motor e linguagem

**Estado:** Confirmada  
**Decisão:** Godot 4.x com GDScript.  
**Motivo:** stack escolhida para o desenvolvimento do jogo.

## DEC-002 — Plataformas

**Estado:** Confirmada  
**Decisão:** PC e Android são plataformas-alvo.  
**Implicação:** considerar controles por teclado/mouse e toque, interface adaptável e testes de exportação.

## DEC-003 — Perspectiva

**Estado:** Confirmada  
**Decisão:** jogo 2D isométrico.

## DEC-004 — Multiplayer

**Estado:** Confirmada  
**Decisão:** até quatro jogadores, campanha hospedada por um jogador e autoridade do host sobre o estado oficial.

## DEC-005 — Saída do host

**Estado:** Confirmada  
**Decisão:** a campanha pausa quando o host sai; não há simulação offline.

## DEC-006 — Desconexão de jogador

**Estado:** Confirmada em alto nível  
**Decisão:** personagem desconectado permanece no mundo em estado de sono/repouso com IA limitada; reconexão restaura o mesmo personagem.  
**Pendente:** especificar detalhes de segurança, interação e tempo limite antes de implementar.

## DEC-007 — PvP opcional e consentido

**Estado:** Confirmada  
**Decisão:** PvP é opcional e cada confronto exige consentimento específico (`single`), em vez de consentimento permanente.

## DEC-008 — Saque PvP limitado

**Estado:** Confirmada em alto nível  
**Decisão:** saque por derrota é limitado (`limited`); itens essenciais para missão, descobertas/evidências científicas únicas, itens reservados e itens marcados como não saqueáveis ficam excluídos.

**Parâmetros provisórios:**
- convite expira após 30 segundos;
- máximo de 3 unidades e 2 tipos de item por derrota;
- proteção pós-derrota por 120 segundos de tempo de jogo, pausada quando a campanha está pausada.

Os números são defaults iniciais configuráveis, não balanceamento definitivo.

## DEC-009 — Proteção de estruturas

**Estado:** Confirmada  
**Decisão:** estruturas não recebem dano de PvP.

## DEC-010 — Transferência de host

**Estado:** Confirmada para o escopo atual  
**Decisão:** transferência manual de host por arquivo de campanha válido; sem migração automática.

## DEC-011 — Escopo do primeiro protótipo

**Estado:** Confirmada  
**Decisão:** mapa pequeno manual, floresta, água, recursos, ruína, estátua petrificada, acampamento/bancada, um experimento, um NPC e uma tarefa.  
**Exclusões iniciais:** mundo procedural completo, grandes populações e indústria extensa.

## DEC-012 — Ciclo científico inicial

**Estado:** Confirmada como objetivo de protótipo  
**Decisão:** explorar → coletar → fabricar → examinar estátua → experimento → desbloquear processo de reviver → recuperar NPC → atribuir tarefa → salvar/carregar.

## DEC-013 — Git e fluxo remoto

**Estado:** Confirmada como direção de trabalho  
**Decisão:** usar Git e GitHub para versionamento e colaboração com Claude Code remoto. O projeto local conhecido está em `C:\Projetos\Renascimento`. O primeiro commit local é `7aa9d06`. A publicação remota deve ser confirmada separadamente.

## DEC-014 — Fase inicial sem gameplay

**Estado:** Confirmada  
**Decisão:** a Fase 1 (BK-001 a BK-005) é de fundação e planejamento. Não implementar mecânicas de gameplay até autorização explícita.

## DEC-015 — Renderer

**Estado:** Candidato, não decisão final  
**Decisão:** Compatibility deve ser avaliado para PC/Android. Conferir a configuração existente e validar antes de alterar.

## DEC-016 — Estimativa de desenvolvimento

**Estado:** Referência preliminar  
**Decisão:** estimativa macro anterior de 20–34 semanas solo é indicativa e deve ser reestimada após o protótipo.

## Processo de mudança

Para alterar uma decisão, registrar:
- ID da decisão;
- estado anterior e proposto;
- motivo;
- impacto em arquitetura, saves, rede, plataformas e backlog;
- migração necessária;
- aprovação explícita do usuário.
