# 01 — Documento de design do jogo (GDD inicial)

## 1. Experiência pretendida

O jogador começa com ferramentas e conhecimento limitados. Cada descoberta deve abrir possibilidades práticas e alterar o que pode construir, fabricar, investigar ou delegar. A experiência deve valorizar planejamento e descoberta, com uma sensação de reconstruir tecnologia a partir de princípios básicos.

## 2. Loop principal

1. Explorar o mundo e identificar locais, materiais e vestígios.
2. Coletar recursos com ferramentas e condições adequadas.
3. Observar e examinar recursos, objetos ou evidências.
4. Formular uma hipótese ou obter uma pista de conhecimento.
5. Preparar materiais, estação e condições para um experimento.
6. Executar o experimento e registrar o resultado.
7. Desbloquear uma técnica, receita, ferramenta ou etapa de produção.
8. Construir ou melhorar infraestrutura.
9. Recuperar NPCs e atribuir tarefas adequadas.
10. Preparar-se para novas regiões, materiais e desafios.

O loop deverá oferecer pistas e feedback. Falhar em um experimento deve, quando apropriado, ensinar algo ou consumir recursos de maneira compreensível, não gerar falha arbitrária.

## 3. Sistemas previstos

- Exploração e navegação em mapa isométrico.
- Interação com objetos, recursos e estruturas.
- Coleta e inventário.
- Receitas, fabricação e estações de trabalho.
- Conhecimento, experimentos e árvore/registro tecnológico.
- Construção e manutenção de estruturas.
- Estátuas petrificadas, processo de recuperação e estados de NPC.
- Atribuição e execução de tarefas por NPCs.
- Sobrevivência e riscos ambientais, a detalhar em etapa posterior.
- Salvamento/carregamento de campanha.
- Multiplayer cooperativo até quatro jogadores.
- Combate e PvP opcional com consentimento por confronto.
- Interface adaptada a PC e Android.

Esses sistemas são visão de produto; não significam autorização para implementá-los agora.

## 4. Ciência e progressão

A progressão deve ser modelada como dados, não como uma longa sequência de condições hardcoded. Cada tecnologia/experimento poderá definir:
- ID estável.
- Nome e descrição.
- Pré-requisitos de conhecimento.
- Materiais e quantidades.
- Ferramentas e estações necessárias.
- Condições de execução.
- Etapas e duração, se aplicável.
- Resultados, incluindo desbloqueios e subprodutos.
- Pistas e feedback de sucesso/falha.
- Referências a outras tecnologias.

A exatidão científica deve ser equilibrada com diversão, acessibilidade e segurança. Experimentos potencialmente perigosos podem ser abstraídos no jogo. O jogo não deve depender de instruções reais detalhadas para produzir substâncias ou dispositivos perigosos.

## 5. NPCs e reconstrução social

NPCs recuperados devem ter identidade de dados, estado, capacidades e tarefas possíveis. A primeira versão deve limitar-se a um NPC e uma tarefa simples. Não implementar simulação populacional ampla antes de medir custo e necessidade.

## 6. Multiplayer e PvP

- Até quatro jogadores.
- Campanha hospedada por um jogador.
- Host controla e valida o estado oficial da campanha.
- PvP opcional, com consentimento específico para cada confronto.
- Perda de saque em PvP limitada.
- Estruturas não recebem dano de PvP.
- Desconexão mantém o personagem no mundo em repouso/sono com IA limitada; reconexão deve restaurar o mesmo personagem.
- Ao sair o host, a campanha pausa. Não há simulação offline.
- Transferência manual de host usando um arquivo válido de campanha; sem migração automática de host nesta fase.

Ver `docs/02_especificacao_tecnica.md` e `docs/05_decisoes_de_projeto.md` para regras e parâmetros.

## 7. Escopo fora do primeiro protótipo

- Mundo procedural completo.
- Centenas de NPCs ativos.
- Economia e indústria em larga escala.
- PvP obrigatório ou saque irrestrito.
- Dano de PvP a construções.
- Migração automática de host.
- Conteúdo ou personagens copiados de obras existentes.

## 8. Questões de design em aberto

As seguintes questões devem ser resolvidas antes de afetarem arquitetura ou balanceamento:
- Modelo exato de fome, sede, fadiga, saúde e morte.
- Sistema de combate PvE.
- Estrutura narrativa e tom.
- Modelo de construção, posicionamento e remoção.
- Escala e geração do mundo após o protótipo.
- Modelo de sincronização e transporte de rede.
- Requisitos mínimos de hardware e qualidade gráfica.
- Monetização/distribuição, se houver.
