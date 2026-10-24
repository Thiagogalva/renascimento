# 03 — Backlog do projeto

## Como ler

- Prioridade P0: fundação necessária antes de gameplay.
- P1: protótipo jogável.
- P2: expansão depois de validar o protótipo.
- As tarefas estão em estado **Planejada** até serem verificadas e concluídas.
- Cada tarefa deve ser entregue em mudança pequena, com critérios de aceitação e revisão do diff.
- A ordem pode ser ajustada apenas com justificativa documentada.

## Fase 1 — Fundação do projeto (P0)

| ID | Tarefa | Resultado esperado | Dependências | Estado |
|---|---|---|---|---|
| BK-001 | Confirmar projeto, versionamento e baseline | Projeto Godot abre; Git funciona; estado inicial registrado | — | Concluída |
| BK-002 | Definir convenções e estrutura de diretórios | Pastas e convenções documentadas, sem reorganização desnecessária | BK-001 | Concluída |
| BK-003 | Definir IDs estáveis e modelos de dados conceituais | Padrão de IDs e catálogo inicial de entidades documentados | BK-002 | Concluída |
| BK-004 | Definir cenas-base, inputs e configurações | Mapa conceitual das cenas e ações de input para PC/Android | BK-002, BK-003 | Concluída |
| BK-005 | Planejar cena de teste isométrica | Critérios de uma cena mínima para validar câmera, grade e ordenação | BK-004 | Concluída |

**Limite:** a Fase 1 é de fundação e planejamento. Não criar ainda sistemas funcionais de gameplay. Se a tarefa exigir um script ou cena funcional, pedir autorização explícita antes de implementá-la.

## Fase 2 — Movimento e interação (P1)

| ID | Tarefa | Resultado esperado | Estado |
|---|---|---|---|
| BK-006 | Definir controles e movimento isométrico | Especificação de movimento, colisões e câmera | Concluída |
| BK-007 | Criar protótipo de movimentação | Personagem movimenta-se em área de teste | Concluída |
| BK-008 | Definir sistema de interação | Alcance, prioridade de alvo e feedback especificados | Concluída |
| BK-009 | Implementar interação básica | Jogador interage com objeto de teste | Concluída |
| BK-010 | Validar PC e controles de toque | Controles básicos testados nas duas plataformas | Planejada |

## Fase 3 — Inventário e fabricação (P1)

| ID | Tarefa | Resultado esperado |
|---|---|---|
| BK-011 | Definir modelo de item e pilha | Tipos, limites, peso/volume se aplicável e regras |
| BK-012 | Implementar inventário inicial | Adicionar, remover e mover itens com validação |
| BK-013 | Definir receitas | Entradas, estação, tempo e resultado modelados em dados |
| BK-014 | Implementar fabricação básica | Uma receita completa pode ser fabricada |
| BK-015 | Validar persistência e falhas do inventário | Sem duplicação/perda em operações válidas ou inválidas |

## Fase 4 — Ciência e tecnologia (P1)

| ID | Tarefa | Resultado esperado |
|---|---|---|
| BK-016 | Modelar conhecimento e tecnologia | IDs, pré-requisitos e desbloqueios documentados |
| BK-017 | Modelar experimentos | Materiais, ferramentas, condições e resultados |
| BK-018 | Implementar registro de descobertas | Descoberta é registrada de modo persistente |
| BK-019 | Implementar um experimento do protótipo | Um experimento pode ser preparado e concluído |
| BK-020 | Validar progressão científica | Pré-requisitos, falhas e desbloqueios testados |

## Fase 5 — Reviver e tarefas de NPC (P1)

| ID | Tarefa | Resultado esperado |
|---|---|---|
| BK-021 | Definir estados de estátua/NPC | Máquina de estados documentada |
| BK-022 | Modelar personagem recuperável | Dados de identidade, capacidades e estado |
| BK-023 | Implementar recuperação de um NPC | NPC do protótipo pode ser recuperado |
| BK-024 | Definir tarefas atribuíveis | Pré-requisitos, duração, entradas e saídas |
| BK-025 | Implementar uma tarefa simples | NPC executa uma tarefa limitada |
| BK-026 | Validar estados e salvamento do NPC | Sem duplicação ou estado impossível |

## Fase 6 — Persistência (P1)

| ID | Tarefa | Resultado esperado |
|---|---|---|
| BK-027 | Aprovar esquema de save versionado | Campos, versão e migração especificados |
| BK-028 | Implementar gravação de campanha | Save íntegro é gravado |
| BK-029 | Implementar carregamento e validação | Save válido carrega; inválido é rejeitado com segurança |
| BK-030 | Testar ciclo save/load | Estado de mundo e progressão são restaurados |
| BK-031 | Documentar compatibilidade e backup | Política para saves antigos e falhas |

## Fase 7 — Multiplayer cooperativo (P1/P2)

| ID | Tarefa | Resultado esperado |
|---|---|---|
| BK-032 | Definir protocolo e autoridade | Ações, mensagens e validações documentadas |
| BK-033 | Implementar sessão mínima | Host e cliente entram numa sessão de teste |
| BK-034 | Sincronizar jogadores | Estado visível sem divergência crítica |
| BK-035 | Sincronizar ações de mundo | Ações compartilhadas validadas pelo host |
| BK-036 | Tratar desconexão/reconexão | Personagem preservado sem duplicação |
| BK-037 | Tratar encerramento e pausa do host | Campanha pausa; sem progresso offline |

## Fase 8 — Combate e PvP (P2)

| ID | Tarefa | Resultado esperado |
|---|---|---|
| BK-038 | Definir combate PvE | Regras e estados de combate documentados |
| BK-039 | Implementar combate básico de teste | Encontro de teste funcional |
| BK-040 | Implementar consentimento por confronto | Convite, aceite e expiração validados |
| BK-041 | Implementar limites de saque PvP | Regras de elegibilidade e limites aplicadas pelo host |
| BK-042 | Implementar proteção temporária | Proteção funciona e pausa com a campanha |
| BK-043 | Testar abuso e duplicação no PvP | Operações idempotentes; estruturas protegidas |

## Fase 9 — PC e Android (P1/P2)

| ID | Tarefa | Resultado esperado |
|---|---|---|
| BK-044 | Definir layout responsivo | Regras de escala e safe areas |
| BK-045 | Definir controles de toque | Mapeamento e zonas de toque |
| BK-046 | Avaliar desempenho no Android | Medições em dispositivo real |
| BK-047 | Configurar exportação Android | Exportação de teste documentada |
| BK-048 | Validar teclado, mouse e toque | Testes de entrada registrados |

## Fase 10 — Integração e transferência manual (P2)

| ID | Tarefa | Resultado esperado |
|---|---|---|
| BK-049 | Definir formato de transferência de campanha | Arquivo e validação documentados |
| BK-050 | Validar integridade da campanha transferida | Arquivo inválido não é aceito |
| BK-051 | Transferir host manualmente | Novo host continua de um save válido |
| BK-052 | Testar divergências de versão | Incompatibilidade é detectada e informada |
| BK-053 | Documentar recuperação e suporte | Procedimento para falhas e restauração |

## Expansão posterior (P2)

| ID | Tarefa | Resultado esperado |
|---|---|---|
| BK-054 | Planejar geração de mundo | Regras e limites definidos antes de implementar |
| BK-055 | Adicionar biomas | Biomas têm identidade e recursos próprios |
| BK-056 | Expandir cadeia científica | Novas tecnologias conectadas por pré-requisitos |
| BK-057 | Expandir elenco e tarefas de NPCs | Novos papéis sem simulação desnecessária |
| BK-058 | Expandir indústria | Produção encadeada e manutenção |
| BK-059 | Planejar economia e trocas | Modelo coerente com a comunidade |
| BK-060 | Avaliar descoberta de sessões de rede | Método escolhido após análise de plataforma |
| BK-061 | Avaliar população maior | Perfil de performance antes de aumentar escala |
| BK-062 | Balancear progressão e recursos | Testes de ritmo e gargalos documentados |

## Definição de concluído (aplica-se a todas as tarefas)

Uma tarefa só é concluída quando:
- os critérios de aceitação estão atendidos;
- alterações estão dentro do escopo;
- o diff foi revisado;
- validações executadas e resultados foram registrados;
- documentação relacionada foi atualizada;
- não existem arquivos temporários ou segredos adicionados;
- a alteração está pronta para revisão em pull request.

## Estimativa macro

Estimativa inicial histórica: aproximadamente 20–34 semanas de trabalho solo para um escopo considerável, sujeita a experiência, rede, exportação e mudanças de escopo. Não é promessa nem prazo contratual. Reestimar após o primeiro protótipo.
