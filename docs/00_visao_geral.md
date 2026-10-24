# 00 — Visão geral do projeto

## Conceito

**Renascimento** é um jogo de sobrevivência, exploração e reconstrução científica em um mundo que precisa ser reconstruído a partir de recursos básicos. O jogador investiga o ambiente, coleta materiais, aprende propriedades, conduz experimentos, desbloqueia tecnologias, constrói estruturas e recupera pessoas para formar uma comunidade.

A referência de inspiração é a progressão de ciência aplicada e reconstrução civilizatória vista em obras como *Dr. Stone*. Renascimento deve ter identidade própria: mundo, personagens, narrativa, missões, nomes, visuais e diálogos originais.

## Visão do produto

Criar uma experiência em que o progresso seja consequência de observação, hipótese, experimentação, domínio de processos e organização de recursos — não apenas de subir níveis ou apertar um botão de desbloqueio.

## Pilares

1. **Ciência aplicada:** tecnologia exige conhecimento, materiais, ferramentas e etapas coerentes.
2. **Sobrevivência sistêmica:** explorar e fabricar têm custos de tempo, recursos e risco.
3. **Progressão legível:** o jogador entende por que uma tecnologia foi desbloqueada e quais pré-requisitos faltam.
4. **Reconstrução social:** NPCs recuperados contribuem com capacidades e tarefas.
5. **Cooperação opcional:** campanha para até quatro jogadores, sem obrigar PvP.
6. **Escopo controlado:** primeiro validar um pequeno ciclo jogável; ampliar conteúdo somente após testes.

## Plataforma e tecnologia

- Motor: Godot 4.x.
- Linguagem: GDScript.
- Plataformas-alvo: PC e Android.
- Perspectiva: 2D isométrica.
- Renderer: considerar Compatibility para ampliar compatibilidade, especialmente em dispositivos móveis; confirmar no projeto real antes de alterar configurações.
- Multiplayer: até 4 jogadores, host-authoritative.
- Controle de versão: Git, repositório remoto GitHub privado planejado.

## Primeiro ciclo jogável (visão de longo prazo)

Explorar → coletar → fabricar → examinar uma estátua petrificada → executar um experimento científico → desbloquear o processo de reviver → reviver um NPC → integrá-lo à comunidade → atribuir uma tarefa → salvar e carregar a campanha.

Esse ciclo é o alvo do primeiro protótipo funcional, mas não deve ser implementado antes da conclusão das tarefas de fundação e da aprovação do usuário.

## Primeiro protótipo — limite de escopo

- Um mapa pequeno, criado manualmente.
- Uma área de floresta, uma fonte de água, recursos limitados, uma ruína, uma estátua petrificada e um acampamento/bancada.
- Uma experiência científica principal.
- Um NPC recuperável e uma tarefa atribuível.
- Sem mundo procedural completo, grandes populações, dezenas de biomas ou cadeia industrial extensa nesta etapa.

## Critérios de sucesso iniciais

- Projeto abre no Godot sem erro de configuração.
- IDs e dados têm convenções documentadas e estáveis.
- O conteúdo pode crescer sem depender de nomes de nós ou caminhos frágeis.
- As tarefas têm critérios verificáveis.
- O histórico Git permite revisar e reverter alterações.
- As decisões de arquitetura não impedem PC/Android nem o multiplayer futuro.
