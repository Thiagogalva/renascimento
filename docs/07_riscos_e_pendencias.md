# 07 — Riscos e pendências

## Riscos principais

| ID | Risco | Impacto | Mitigação |
|---|---|---|---|
| R-001 | Escopo crescer antes de validar o ciclo central | Alto | Manter o primeiro mapa e conteúdo pequenos; exigir aprovação para expansão |
| R-002 | Claude alterar muitos arquivos de uma vez | Alto | Tarefas pequenas, branches, diffs revisados e PRs |
| R-003 | IDs mudarem depois de usados em saves | Alto | Definir IDs estáveis e migração antes da persistência |
| R-004 | Multiplayer ser construído tarde sobre arquitetura incompatível | Alto | Planejar autoridade e fronteiras de estado desde cedo; implementar multiplayer somente após protótipo local validado |
| R-005 | Testes remotos não equivalerem ao Godot local | Médio/alto | Registrar limitações e executar teste final no Godot local |
| R-006 | Android introduzir limitações de UI/performance | Médio/alto | Planejar toque e UI responsiva cedo; testar em aparelho real |
| R-007 | Reprodução excessiva da obra de inspiração | Médio | Manter mundo, personagens, diálogos, visuais e missões originais |
| R-008 | Conteúdo científico virar simulação complexa ou instrução perigosa | Médio | Abstrair processos de risco e priorizar clareza lúdica |
| R-009 | Configuração remota GitHub ainda não concluída | Alto | Confirmar repositório, branch padrão, permissões e primeiro push antes de delegar alterações remotas |

## Pendências que não bloqueiam a Fase 1

- Confirmar versão exata do Godot 4.
- Confirmar configuração atual do renderer.
- Confirmar se o repositório privado do GitHub foi criado e se o primeiro push foi realizado.
- Definir controles finais e escala da UI.
- Definir tom narrativo e direção de arte.
- Definir regras completas de sobrevivência e combate PvE.
- Definir protocolo e transporte de rede.
- Definir formato definitivo de save e migrações.
- Definir comportamento de segurança para personagens desconectados.
- Definir especificação detalhada dos 25 testes MP-01..MP-25 antes do multiplayer.

## Regra de resolução

Não transformar uma pendência em decisão silenciosa. Se ela bloquear uma tarefa, apresentar alternativas breves, explicar impactos e aguardar o usuário.
