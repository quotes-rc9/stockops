# 📝 Changelog — StockOps

## [2.45.1] — 2026-09-02

### 🐛 Correção real — carrinho perdia item ao buscar outro

Achado o bug de verdade: a lista de itens marcados só "lembrava" da marcação enquanto o item continuava visível na busca/aba atual — pesquisar outro item filtrava o primeiro pra fora da tela e ele desaparecia do carrinho de vez (não tinha onde guardar aquilo). Agora o carrinho é um estado à parte (`_smCarrinho`), independente do que está filtrado, e aparece um resumo fixo **"🛒 No carrinho"** acima da lista, sempre visível, com cada item marcado e um jeito de remover — assim dá pra marcar um item, buscar outro bem diferente, marcar ele também, e os dois continuam lá até enviar.

### 🔧 Funções novas / alteradas no JS

| Item | Descrição |
|---|---|
| `_smCarrinho` | Novo estado `{cod: qty}`, sobrevive a troca de aba/busca |
| `toggleSmCarrinho()` / `atualizarSmQtyCarrinho()` / `removerSmCarrinhoItem()` | Adicionam, ajustam quantidade e removem item do carrinho |
| `renderSmCarrinho()` | Desenha o resumo fixo do carrinho |
| `renderSmCatalogo()` | Não depende mais de ler checkboxes já renderizados — reflete o `_smCarrinho` |
| `enviarSolicitacaoMaterial()` | Lê direto do `_smCarrinho` em vez de checkboxes marcados na tela |

## [2.45.0] — 2026-09-02

### ✨ Nova funcionalidade — Registrar Troca de Tinta direto na tela de Estoque de Tintas

Quem tem a permissão `trocar_tinta` agora vê um botão **"🔄 Troquei"** ao lado de cada tinta com estoque no Setor Quotes (tela Estoque de Tintas). Ao clicar: escolhe em qual máquina instalou (a lista já vem filtrada pelo modelo certo — LH-100, LUS-120; pro Branco, escolhe também a posição 07/08; pro Primer, mostra as 6 máquinas), informa **número de série** e **validade** — mesmos campos que a planilha física do setor já usa.

Ao confirmar, tudo acontece junto, automaticamente:
1. Baixa **1 unidade do Setor Quotes** daquela tinta.
2. **Fecha o ciclo da tinta antiga** na máquina escolhida (marca `fim` = hoje) — ela entra pro histórico da máquina sem precisar de nenhum passo manual separado.
3. **Abre o novo ciclo** na máquina (início = hoje, série e validade informadas).
4. Registra a movimentação de saída, o histórico da máquina e a auditoria.

Liberado pra **Veronica, Guilherme Neri, Pedro e Anderson** (os mesmos 4 de Solicitar Material) — cada um registra a troca que ele mesmo fez fisicamente, sem precisar avisar por mensagem pra alguém digitar depois.

### 🔧 Funções novas / alteradas no JS

| Item | Descrição |
|---|---|
| `abrirTrocaTinta(modelo, corParam, produtoCod)` | Abre o modal já com a lista de máquinas certa (filtrada por modelo, ou as 6 pro Primer) |
| `confirmarTrocaTinta()` | Fecha o ciclo antigo, abre o novo, baixa o Setor Quotes, registra movimentação/histórico/auditoria |
| `_etLinhaHtml()` / `_etCardModelo()` / `_etCardPrimer()` | Passam a aceitar um contexto de troca — o botão só aparece na coluna Setor Quotes, com estoque > 0 e permissão `trocar_tinta` |
| `TODAS_PERMISSOES` | Nova entrada `trocar_tinta` |

### 🐛 Correção — 2 produtos com id do Supabase divergente do código

Achado durante essa implementação: os 2 produtos cadastrados via script nesta sessão (Duct guide, Waste Ink Tank Absorber) ficaram com o `id` do Supabase diferente do `cod` — o app sempre salva produto usando `cod` como id, então uma edição futura pelo sistema criaria uma linha duplicada em vez de atualizar. Corrigido diretamente no banco (sem perda de dado).

## [2.44.1] — 2026-09-02

### 🐛 Correção — checkboxes marcados continuavam marcados após enviar

Depois de enviar o carrinho, os itens continuavam com o checkbox marcado (a função que redesenha a lista preserva a seleção de propósito, pra não perder marcação ao trocar de aba/buscar — mas isso também "sobrevivia" ao próprio envio). Um segundo clique em "Enviar solicitação" duplicava a solicitação. Agora os checkboxes são desmarcados antes de redesenhar a lista pós-envio.

## [2.44.0] — 2026-09-02

### ✨ Solicitar Material agora funciona como carrinho

A tela nova (2.43.0) pedia só 1 item por vez. Agora é um catálogo com checkbox: marca quantos itens quiser (Peça, Insumo, Consumível misturados, sem precisar repetir o processo), com abas de categoria e busca por nome/código pra achar rápido. Cada item marcado tem sua própria quantidade editável ali mesmo na lista. Também dá pra digitar um item que não está cadastrado (nome + quantidade), que entra junto no mesmo envio. Uma observação só, que vale pra tudo que foi marcado. O botão mostra quantos itens estão selecionados e manda tudo de uma vez — vira uma solicitação pendente por item (mesmo fluxo de aprovação de sempre, o admin aprova um por um se quiser).

### 🔧 Funções novas / alteradas no JS

| Item | Descrição |
|---|---|
| `renderSmCatalogo()` / `filtrarSmCatalogo()` | Lista com checkbox, filtro por categoria e busca; mantém marcação ao trocar de aba |
| `adicionarSmItemLivre()` / `removerSmItemLivre()` | Itens digitados (fora do catálogo) entram numa lista à parte antes de enviar |
| `atualizarSmContagem()` | Atualiza o texto do botão com a contagem de itens selecionados |
| `enviarSolicitacaoMaterial()` | Reescrita: lê todos os checkboxes marcados + itens livres e cria uma solicitação por item numa tacada só |
| `filtrarSmProdutos()` / `onSmProdSelect()` | Removidas (substituídas pelo catálogo) |

## [2.43.1] — 2026-09-02

### 🐛 Correção — Botão "Enviar solicitação" desabilitado sem motivo

O botão novo da tela Solicitar Material usava a classe `.nav-btn.success`, a mesma dos botões "Registrar Entrada/Saída" — e por isso caía na regra que desabilita esses botões pra quem não tem `registrar_mov`. Resultado: quem só tinha `criar_solic` via um botão cinza, sem conseguir clicar. Troquei pra um estilo próprio (mesma cor verde, sem a classe compartilhada).

## [2.43.0] — 2026-09-02

### ✨ Nova funcionalidade — Solicitar Material (tela simples pra quem só pede)

Nova página "📝 Solicitar Material" pra usuários que só precisam pedir peça/insumo/consumível, sem aprovar nada — formulário direto na tela (sem modal): categoria, produto (com estoque atual visível), quantidade, observação. Embaixo, a lista "Minhas solicitações" mostra só os pedidos do próprio usuário, com status (Pendente/Aprovada/Rejeitada). Reaproveita o mesmo `SOLIC`/fluxo de aprovação que a tela de Solicitações do admin já usa — o admin aprova do jeito que sempre aprovou, só muda quem pede.

Liberado pra **Veronica, Guilherme Neri, Pedro e Anderson** (permissão `criar_solic`). O item só aparece no menu de quem tem `criar_solic` mas não `ver_solicitacoes` — quem já aprova (admin) continua vendo a tela cheia de Solicitações, não essa versão simplificada.

Corrigido também: `confirmarSolicitacao()` (usada pelo botão "Solicitar Entrada/Saída" das Ações Rápidas) checava o **cargo** (`podeEditar()`, só admin/operador) em vez da **permissão** `criar_solic` — na prática, um Visualizador com `criar_solic` liberado não conseguia mesmo assim enviar a solicitação. Corrigido pra checar a permissão certa.

Já confirmado (v2.42.0): eles veem os itens em trânsito no Dashboard sem nenhum valor.

### 🔧 Funções novas / alteradas no JS

| Item | Descrição |
|---|---|
| `renderSolicitarMaterial()` | Popula o formulário e a lista "Minhas solicitações" (filtrada pelo usuário atual) |
| `filtrarSmProdutos()` / `onSmProdSelect()` | Filtro por categoria e preview de estoque no formulário novo |
| `enviarSolicitacaoMaterial()` | Cria a solicitação (mesmo `SOLIC.push`/audit da tela admin), checando `criar_solic` |
| `confirmarSolicitacao()` | `podeEditar()` → `temPermissao('criar_solic')` |
| `PAGE_PERM_MAP['solicitar-material']` | Nova entrada, exige `criar_solic` |

## [2.42.0] — 2026-09-02

### ✨ Ajuste de permissão — Veronica pode ver itens em trânsito (sem valores)

A pedido: quem só tem `ver_dashboard` agora consegue abrir os detalhes de um pedido pelo painel "Pedidos em Trânsito" (produto, quantidade, fornecedor, data prevista) — antes disso exigia `ver_pedidos`, o que bloqueava até a visualização sem valor nenhum. Os valores continuam escondidos (`RV()`, já corrigido em 2.40.0/2.41.0).

Como a visualização abriu mais, reforcei as ações dentro do modal para não abrirem junto: os botões "✅ Chegou", "❌ Cancelar pedido", "✅ Marcar como Recebido" e "↩ Reabrir como Enviado" agora só aparecem pra quem pode editar (Admin/Operador), e as funções por trás deles (`marcarItemChegou`, `marcarRecebido`, `cancelarPedido`, `reabrirPedido`) ganharam checagem própria — mesmo padrão de defesa usado nos outros pontos revisados hoje.

### 🔧 Alterações no JS

| Item | Mudança |
|---|---|
| `abrirPedidoDet(id)` | Permite com `ver_pedidos` OU `ver_dashboard` (valores continuam ocultos por `RV()`) |
| Botões de ação no modal | Só renderizam se `podeEditar()` |
| `marcarItemChegou`, `marcarRecebido`, `cancelarPedido`, `reabrirPedido` | Bloqueiam no início se `!podeEditar()` |

## [2.41.0] — 2026-09-02

### 🐛 Correção de segurança — Varredura completa de valores no perfil restrito (Veronica)

Depois da correção do modal de pedido (2.40.0), foi pedido pra suspender de vez qualquer coisa relacionada a valor no perfil da Veronica. Fiz uma varredura em todo `R(` (versão sempre-visível) do arquivo e revisei cada um contra as páginas/ações que ela alcança hoje. Achado e corrigido:

1. **Rodapé da tabela de Estoque** — o "Total listado" (soma de estoque × custo dos itens filtrados) usava `R()` em vez de `RV()`, mesmo a página de Estoque sendo uma das que ela tem acesso.
2. **Histórico de preços de um produto** (badge "💲 Histórico" na tabela de Estoque) — a função `abrirHistoricoProduto()` não tinha checagem própria de permissão, só contava com o botão já estar escondido. Mesmo padrão de brecha do modal de pedido (2.40.0); agora tem o guard direto na função.
3. **Exportar backup** — `exportarBackup()` (gera um .json com todos os produtos, custos, movimentações e auditoria) também não tinha checagem própria, só o botão escondido. Agora exige `exportar_dados` também dentro da função.
4. Mais 2 pontos de consistência (não expostos hoje, páginas já bloqueadas): cards da Análise ABC e legenda do donut ABC no Dashboard — trocados pra `RV()`.

Confirmado: os pontos que sobraram com `R()` no arquivo (dica de custo ao registrar entrada/saída, carrinho de Novo Pedido, texto interno de auditoria) só são alcançáveis por quem já tem `registrar_mov`/`gerar_pedido`/`ver_auditoria` — permissões que a Veronica não tem — e as funções que os abrem (`openModal`, `registrarPedidoPendente`, etc.) já checam isso na entrada.

### 🔧 Alterações no JS

| Item | Mudança |
|---|---|
| `abrirHistoricoProduto(cod)` | Bloqueia no início se `!temPermissao('ver_valores')` |
| `exportarBackup()` | Bloqueia no início se `!temPermissao('exportar_dados')` |
| 3 lugares | `R(...)` → `RV(...)` (rodapé do Estoque, cards ABC, legenda do donut ABC) |

## [2.40.0] — 2026-09-02

### 🐛 Correção de segurança — Detalhes de pedido acessíveis pelo Dashboard sem permissão

Achado testando a conta da Veronica: o painel "Pedidos em Trânsito" do Dashboard (visível pra qualquer um com `ver_dashboard`) tinha um clique que chamava `abrirPedidoDet()` direto — a mesma função usada pela página de Compras — sem checar `ver_pedidos`. Isso deixava qualquer usuário sem acesso a Compras ver o modal completo de um pedido (fornecedor, itens, status, e o valor de cada item individual) só de ter algum pedido em trânsito.

Achado junto: dentro desse mesmo modal, o valor de cada item usava `R()` (sempre visível) em vez de `RV()` — mesmo com o resumo do topo já escondendo o total corretamente. Auditei os outros lugares que exportam/mostram custo de pedidos, validades e movimentações e encontrei mais 3 pontos com o mesmo problema (não expostos hoje porque as páginas já são bloqueadas, mas corrigidos por consistência).

**Correções:**
1. `abrirPedidoDet()` agora bloqueia no início se faltar `ver_pedidos` — a mesma trava que já protege a página de Compras, agora também no atalho do Dashboard.
2. `R()` → `RV()`: valor por item no modal de detalhes do pedido, export CSV do Histórico de Pedidos (detalhamento de itens), PDF de Validades, PDF de Movimentações.

### 🔧 Alterações no JS

| Item | Mudança |
|---|---|
| `abrirPedidoDet(id)` | Bloqueia no início se `!temPermissao('ver_pedidos')` |
| 4 lugares | `R(...)` → `RV(...)` em custo de itens (modal de pedido, CSV de pedidos, PDF de Validades, PDF de Movimentações) |

## [2.39.0] — 2026-09-02

### ✨ Nova funcionalidade — Clique no gráfico "Consumo real" mostra as saídas, não o estoque

Antes, clicar numa barra do gráfico "Consumo real" (Dashboard) levava pro Estoque filtrado por categoria — mas o gráfico mostra *saídas do mês*, então isso não respondia "o que saiu". Agora o clique leva pra Movimentações já filtrado por categoria + mês/ano daquela barra específica, mostrando exatamente os registros de saída que formaram aquele número. A tela de Movimentações ganhou um filtro ativo (pill "Mostrando: Saídas de X — Mês/Ano" com botão de limpar), reaproveitando o mesmo padrão visual já usado na Previsão de Troca de Tinta.

O clique na legenda (nome da categoria embaixo do gráfico) continua indo pro Estoque como antes — ali faz sentido, é uma visão de categoria sem recorte de mês.

### 🔧 Funções novas no JS

| Função | Descrição |
|---|---|
| `verSaidasCategoria(cat, ano, mes)` | Navega pra Movimentações e filtra por categoria + mês/ano — chamado pelas barras do gráfico |
| `limparMovFiltro()` | Limpa o filtro ativo em Movimentações |
| `_movFiltro` | Estado do filtro ativo (`{cat, ano, mes}` ou `null`) |

## [2.38.0] — 2026-09-02

### 🐛 Correção — Cache do Service Worker desalinhado (pode ter causado tela quebrada)

O `sw.js` ainda pré-cacheava `pages.css?v=20260814`, mas o `index.html` já pede `pages.css?v=20260831c` desde a versão 2.31.0 — a URL antiga nunca era limpa, então alguns dispositivos podiam ficar servindo uma combinação de HTML novo com CSS antigo (ou uma resposta parcial cacheada), o que explica relatos de tela em branco/HTML aparecendo como texto cru. `APP_VERSION` foi incrementado (invalida todo cache antigo nos próximos acessos) e a lista pré-cacheada foi corrigida pra bater com a versão real do CSS.

**Se a tela travar de novo:** feche e reabra o app (ou dê um refresh puxando pra baixo/F5). A troca de versão já força a limpeza do cache automaticamente no próximo carregamento.

### 🔧 Alterações

| Item | Mudança |
|---|---|
| `sw.js` `APP_VERSION` | `2.37.0` → `2.38.0` |
| `sw.js` `APP_SHELL` | `pages.css?v=20260814` → `pages.css?v=20260831c` (bate com o `index.html`) |

## [2.37.0] — 2026-08-31

### 🐛 Correção de segurança — Bloqueio real de páginas + valores expostos sem permissão

Achado testando a conta da Veronica: o botão "Gerar pedido de compra" (Ações rápidas do Dashboard) chama `showPage('compras')` direto, e o `showPage()` nunca checava permissão nenhuma — só confiava no botão do menu lateral estar escondido. Isso deixava qualquer usuário acessar o Histórico de Pedidos (com valores em R$) mesmo sem a permissão `ver_pedidos`.

**Duas correções:**
1. `showPage()` agora bloqueia de verdade — checa a permissão da página (`PAGE_PERM_MAP`, o mesmo mapa que já escondia o menu) antes de ativar a página ou chamar a função de render, e mostra um aviso caso a página seja bloqueada. `aplicarPermissoes()` passou a reusar esse mesmo mapa, eliminando a duplicação que causou o bug de colisão corrigido em 2.35.1.
2. Vários lugares mostravam custo/valor com `R()` (sempre visível) em vez de `RV()` (some se faltar `ver_valores`) — Histórico de Pedidos, PDF de Estoque Completo, PDF de Análise ABC, página de Validades, e o detalhe de "Custo unitário" na Previsão de Troca de Tinta (aba Por máquina, que a Veronica tem acesso). Todos migrados pra `RV()`.

Também: os botões "Gerar pedido de compra" e "Ver previsão de compra" nas Ações rápidas agora somem se o usuário não tiver a permissão da página, em vez de ficar ali sem fazer nada.

### 🔧 Alterações no JS

| Item | Mudança |
|---|---|
| `PAGE_PERM_MAP` | Novo — mapa global página→permissão, usado por `showPage()` e `aplicarPermissoes()` |
| `showPage(id, el)` | Bloqueia no início se a permissão da página não for atendida |
| ~12 lugares | `R(...)` → `RV(...)` em custo/valor/frete/total fora de fluxos de edição |

## [2.36.1] — 2026-08-31

### 🧹 Remoção — KPIs "Itens críticos"/"Itens em alerta"/"Vencendo em 30 dias" duplicados

Esses 3 KPIs ficaram redundantes com a Central de Atenção (2.35.0), que já mostra os mesmos números de um jeito clicável. Removidos do topo do Dashboard — sobraram os 3 que não duplicam nada: Unidades em estoque, Valor em estoque, Itens cadastrados.

## [2.36.0] — 2026-08-31

### ✨ Nova funcionalidade — Permissão por aba na Previsão de Troca de Tinta

Até agora, quem tinha acesso à página via `ver_previsao_tinta` via todas as 4 abas (Resumo, Pedido consolidado, Calendário de compra, Por máquina) de uma vez. Agora cada aba tem sua própria sub-permissão (`ver_pt_resumo`, `ver_pt_pedido`, `ver_pt_calendario`, `ver_pt_maquina`) — admin continua vendo tudo por padrão, e outros usuários só veem a(s) aba(s) explicitamente liberada(s) em Gerenciar Usuários. Se a aba ativa não estiver liberada, o sistema troca automaticamente pra primeira aba permitida.

Aplicado agora: a Vero (viewer) recebeu só `ver_pt_maquina` — vê apenas a aba "Por máquina", sem acesso ao Pedido consolidado (que mostra valores em R$) nem ao Resumo/Calendário.

### 🔧 Funções novas no JS

| Função | Descrição |
|---|---|
| `_ptAplicarPermissoesAbas()` | Esconde os botões de aba sem permissão e troca pra primeira aba permitida se a atual estiver bloqueada |
| `PT_TAB_PERM` | Mapa aba → id da sub-permissão |

## [2.35.1] — 2026-08-31

### 🐛 Correção — Permissão de "Previsão de Troca de Tinta" não aparecia no menu

Bug real encontrado testando a conta da Vero: mesmo com `ver_previsao_tinta` na lista de permissões dela, o item não aparecia na sidebar. Causa: `aplicarPermissoes()` decidia qual permissão checar comparando se o texto do `onclick` do botão *contém* o id da página (`onclick.includes(page)`) — como `"previsao-tinta"` contém `"previsao"`, o item de Previsão de Troca de Tinta caía na entrada errada do mapa (`page-previsao` → `ver_previsao`, da Previsão de Compra) e ficava escondido por uma permissão que não é a dela. Corrigido pra comparar o id entre aspas exatas (`'previsao-tinta'`), evitando esse tipo de colisão por prefixo — geral, não só pra esse caso.

## [2.35.0] — 2026-08-31

### ✨ Nova funcionalidade — Central de Atenção no Dashboard

Novo painel interativo no Dashboard, entre "Pedidos em Trânsito" e "Ações rápidas": 3 chips grandes e clicáveis (🔴 Críticos, 🟡 Alertas, 🟠 Vencendo em ≤30 dias) mostrando só o número — clicar num chip expande uma lista curta (até 8 itens + link "ver todos") logo abaixo, sem ocupar espaço até o usuário pedir. Substitui, de um jeito mais compacto e interativo, os painéis "Críticos e Alertas"/"Validades próximas" que tinham sido removidos (2.25.1) por ficarem grandes demais sempre abertos.

### 🔧 Funções novas no JS

| Função | Descrição |
|---|---|
| `renderAtencao()` | Monta os 3 chips e a lista filtrada da Central de Atenção |
| `toggleAtencaoFiltro(tipo)` | Alterna qual chip está expandido (clicar de novo fecha) |

## [2.34.0] — 2026-08-31

### 🎨 Melhoria — Layout do Dashboard sem espaço vazio

Desde que os painéis "Críticos e Alertas"/"Validades próximas" saíram (2.25.1), o Dashboard ficou com "Ações rápidas" e "Resumo por categoria" isolados numa coluna estreita à esquerda, com uma área enorme em branco ao lado — e os gráficos (Consumo real, Curva ABC) numa linha separada abaixo. Unificado numa linha só: Ações rápidas + Resumo por categoria (coluna fixa à esquerda) ao lado dos dois gráficos, ocupando a largura toda. Responsivo mantido (tablet: ações no topo, gráficos embaixo lado a lado; mobile: tudo empilhado).

## [2.33.1] — 2026-08-31

### 🐛 Correção — Primer vencido duplicava no Calendário de compra

A versão anterior (2.33.0) assumia que todo item "Comprar" tinha dias restantes negativos (atrasado por consumo). Mas o Primer vencido é urgente pela **validade**, não pelo consumo — ainda tem bastante % de tinta e dias positivos de estimativa. Isso fazia ele aparecer **duas vezes**: uma vez forçado no mês atual, outra no mês estatístico da previsão (ex: outubro). Corrigido: itens com status Comprar agora saem completamente do cálculo por mês estatístico e só existem no mês atual. O motivo específico (ex: "Primer venceu em 17/07/2025, há 411d") aparece no lugar da data prevista, em vez de um genérico "atrasado há Xd" que não fazia sentido pro caso do Primer.

## [2.33.0] — 2026-08-31

### ✨ Melhoria — Itens urgentes (🔴 Comprar) entram no mês atual do Calendário

Antes, o Calendário de compra só mostrava tintas dentro do prazo — o que já estava atrasado (como o Primer vencido, sem reserva) ficava de fora, só visível na aba Resumo. Agora esses itens entram no card do **mês atual**, no topo da lista, destacados com fundo vermelho e "⚠ atrasado há Xd" no lugar da data prevista (que estaria no passado). O total do mês passa a refletir esse gasto urgente também.

## [2.32.0] — 2026-08-31

### ⏪ Troca — Ordenação por urgência dos cards → ordenação de coluna dentro dos cards

A pedido do usuário: tira o toggle "Nome / Mais crítica primeiro" que reordenava os cards de máquina (2.31.0), e volta a ordenação por clique nas colunas (Tinta, Instalada, Média, Restante, Previsão) **dentro** de cada card — igual ao Pedido consolidado, aplicada a todas as máquinas ao mesmo tempo.

## [2.31.0] — 2026-08-31

### ✨ Melhoria — Ordenação por urgência na aba "Por máquina"

De volta a pedido do usuário, mas de um jeito diferente do que tinha sido revertido: em vez de reordenar as linhas *dentro* de cada card (o que quebrava o alinhamento entre máquinas), agora dá pra ordenar a **posição dos cards** — clique em "🔴 Mais crítica primeiro" pra ver, dentro de cada modelo (LH-100/LUS-120), a máquina com a tinta mais urgente (Comprar > Repor > Programar > Tranquilo, empate desempatado pelo menor Restante) primeiro. As linhas de cada card continuam na ordem fixa de sempre. Botão "Nome (M01→M06)" volta pra ordem padrão.

### 🔧 Funções novas no JS

| Função | Descrição |
|---|---|
| `togglePtMaqCardSort()` | Alterna entre ordem por nome e por urgência dos cards |
| `_ptMaqSeveridade(itens)` | Pior status + menor restante de um card, usado como critério de ordenação |

## [2.30.0] — 2026-08-31

### ✨ Dados — Setor Compras registrado + LUS-175 no Estoque Tintas

Contagem física do **Setor Compras** registrada pra 18 tintas (LH-100, LUS-120 e LUS-175). A tela "Estoque Tintas" ganhou um 3º grupo, **LUS-175**, mostrando as 7 tintas desse modelo (Preta, Ciano, Ciano Claro, Magenta, Magenta Claro, Amarela, Branca) nos dois setores — os produtos já existiam cadastrados, mas nenhuma máquina LUS-175 está registrada em `MAQUINAS` ainda, então esse grupo fica com lista fixa (não vem de `TINTA_MAPA`) até a máquina ser cadastrada de verdade.

**Pendente**: a relação de máquina(s)/histórico de tintas da LUS-175 (o Thiago vai passar depois, como fez com as outras 6 máquinas) — só depois disso ela entra na Previsão de Troca de Tinta e no `TINTA_MAPA`.

### 🔧 Funções novas no JS

| Função | Descrição |
|---|---|
| `_etCardLUS175(campo)` | Card fixo da LUS-175 (não depende de `TINTA_MAPA`/máquina registrada) |
| `_ET_LUS175_PRODUTOS` | Lista dos 7 produtos LUS-175 com seus rótulos de cor |

## [2.29.1] — 2026-08-31

### ✏️ Correção de texto — Estoque Tintas

O rótulo "Setor Quotes (nas máquinas)" dava a entender que era a tinta já instalada na impressora — na verdade é a **reserva em estoque**, guardada junto das máquinas mas separada da tinta instalada (essa já é rastreada em outro lugar do sistema). Texto corrigido pra "reserva em estoque, junto das máquinas — não é a tinta instalada".

## [2.29.0] — 2026-08-31

### 🔄 Substituição — "Estoque Mínimo" virou "Estoque Tintas" (2 setores)

A tela e o menu "Estoque Mínimo de Tintas" (nível sugerido, capital liberável, diagnóstico por máquina) foram substituídos por **Estoque Tintas** — duas telas lado a lado, **Setor Quotes** (nas máquinas, reserva de mão) e **Setor Compras** (com o Thiago, pulmão), com a quantidade de cada tinta por modelo e cor em cada uma.

Motivo: o estoque de tinta MIMAKI passou a ser rastreado em 2 locais físicos separados — quando o Setor Quotes zera um item, a equipe pede reposição do Setor Compras. Os campos novos `estoqueQuotes`/`estoqueCompras` foram adicionados às 12 tintas MIMAKI (contagem do Setor Quotes já registrada; Setor Compras aparece como "não contado ainda" até a próxima atualização). O total antigo `estoque` continua existindo sem mudança, usado pelas outras telas (Dashboard, Estoque completo).

**Importante**: o motor de decisão da Previsão de Troca de Tinta (Comprar/Repor/Programar) ainda usa o `estoque` total — a próxima etapa é migrar essa checagem para usar só `estoqueQuotes`, já que é a reserva de fato disponível pra trocar na máquina.

**Permissão**: mantida `ver_analise_min` (mesmo id, só o rótulo mudou, pra não quebrar permissões já configuradas pra usuários existentes).

### 🔧 Funções novas / removidas no JS

| Função | Situação |
|---|---|
| `renderAnaliseMin()` | Reescrita — agora popula `#et-quotes-grid`/`#et-compras-grid` em vez da tabela antiga |
| `_etLinhasModelo`, `_etLinhaHtml`, `_etCardModelo`, `_etCardPrimer` | Novas |
| `calcularAnaliseTintas`, `_aminTier`, `_aminCalcGrupo`, `setAminJanela`, `sortAminBy`, `toggleAminFiltro`, `toggleAminAlerta`, `exportarAnaliseMinPDF` | Removidas (só eram usadas pela tela antiga) |

## [2.28.1] — 2026-08-31

### ⏪ Reversão — Ordenação na aba "Por máquina"

A ordenação adicionada na versão anterior fazia cada card de máquina reordenar suas próprias linhas de forma independente — como cada máquina tem valores diferentes, a mesma tinta (ex: Preta) parava de aparecer sempre na mesma posição entre os cards, dificultando comparar cor a cor entre as 6 máquinas. Revertido: a aba "Por máquina" volta pra ordem fixa (Preta, Ciano, Magenta, Amarela, Verniz, Primer, Branco-07, Branco-08), igual em todos os cards. A ordenação por maior/menor continua disponível — e é o lugar certo pra isso — na aba "Pedido consolidado", onde todas as colunas ficam visíveis.

## [2.28.0] — 2026-08-31

### ✨ Melhoria — Ordenação na aba "Por máquina"

As tabelas de cada máquina (aba Por máquina) agora têm cabeçalho clicável, igual ao Pedido consolidado — clique em Tinta, Instalada, Média, Restante ou Previsão pra ordenar do maior pro menor ou vice-versa (clique de novo pra inverter). A ordenação vale pra todas as máquinas ao mesmo tempo, com uma seta (▲/▼) indicando a coluna e direção ativas. Serve pra ver rápido, em cada máquina, quais tintas ainda têm folga e quais estão precisando de compra.

### 🔧 Funções novas no JS

| Função | Descrição |
|---|---|
| `sortPtMaquinaBy(campo)` | Alterna a ordenação (mesmo campo = inverte direção) e re-renderiza |
| `_ptMaqTh(campo, label, center)` | Gera o `<th>` clicável com a seta de direção ativa |

## [2.27.0] — 2026-08-31

### ✨ Nova funcionalidade — Checagem de validade do Primer instalado

O motor de decisão (Comprar/Repor/Programar/Tranquilo) agora também verifica a validade da unidade de **Primer já instalada** em cada máquina — antes só checava a validade da reserva no estoque. Como o Primer não tem a extensão de +1 ano das outras tintas, qualquer máquina rodando com Primer vencido cai automaticamente em 🔴 Comprar, com o motivo específico ("Primer vencido há Xd, sem extensão — trocar já"), independente do nível de tinta que ainda resta. Aparece com um ícone ⏰ na tabela do Pedido consolidado e nos cards de Por máquina.

Corrigido também um registro órfão: o produto Tinta Neutra PR 200 tinha estoque zerado mas 2 datas de validade presas no cadastro (mesma inconsistência já corrigida na Tinta Preta LH100).

### 🔧 Alterações no JS

| Função | Mudança |
|---|---|
| `calcularConsumoPorMaquina()` | Passa a incluir `validadeInstalada` (a validade impressa da unidade ativa) por cor |
| `_ptAvaliar(cor, effRestante, previsaoData, produto, validadeInstaladaStr)` | Novo parâmetro; checagem específica do Primer no topo da função, retorna `primerVencido:true` quando aplicável |
| `_renderPtPedido` / `_renderPtPorMaquina` | Novo aviso "⏰ Primer vencido — trocar já" quando `status.primerVencido` |

## [2.26.0] — 2026-08-31

### 🐛 Correção — CSS não atualizava pra quem já tinha acessado o sistema

O `pages.css` era carregado com `?v=20260814` fixo no HTML — como esse parâmetro nunca mudava, o navegador continuava usando a versão em cache mesmo depois de eu corrigir o CSS (confirmado ao vivo: o arquivo já estava certo no servidor, mas o navegador não buscava a versão nova). Atualizado pra `?v=20260831`. Daqui pra frente, toda vez que o CSS mudar, esse parâmetro precisa ser atualizado também — senão a correção não chega pra quem já usou o sistema antes.

### 🐛 Correção — Gráfico "Consumo real" do Dashboard não mostrava as barras

Bug de CSS pré-existente: `.bar-g` (o agrupador de barras de cada mês) não tinha altura definida, então as barras internas (`.b-bar`, com `height` em %) sempre colapsavam pra 0px — mesmo com dados reais de saída no período. Corrigido adicionando `height:100%` em `.bar-g`, herdando a altura de 90px do container. Confirmado ao vivo no site publicado antes de corrigir.

### 🧹 Simplificação — Detalhe da conferência física na Previsão de Troca de Tinta

O box verde "✓ Conferido fisicamente..." duplicava a mesma informação que já aparecia no "Histórico de conferências" logo abaixo (mesma data, mesmo %, mesma estimativa). Removido o box separado — agora só existe o histórico, com a leitura mais recente destacada (badge "ATUAL") e o botão de apagar a conferência movido pra dentro dele.

## [2.25.1] — 2026-08-31

### 🧹 Remoção — Painéis "Críticos e Alertas" e "Validades próximas" do Dashboard

Removidos os dois painéis de lista da linha do meio do Dashboard (a fileira de KPIs no topo — Itens críticos, Vencendo em 30 dias — continua igual). O painel "Ações rápidas" passou a ocupar sozinho a linha, sem colunas vazias ao lado.

## [2.25.0] — 2026-08-31

### ✨ Nova funcionalidade — Histórico de conferências do RasterLink por tinta

Cada conferência física registrada numa tinta agora fica guardada num histórico próprio (`conferenciaHistorico`), em vez de sobrescrever a anterior. O detalhe expandido de cada tinta na "Previsão de Troca de Tinta" mostra essa linha do tempo: "Dia DD/MM/AAAA — XX% (estimativa na hora: +Yd)", da mais recente pra mais antiga — dá pra acompanhar a evolução real do consumo de cada cor em cada máquina ao longo das semanas.

### 🔧 Alterações no JS

| Função | Mudança |
|---|---|
| `salvarConferenciaTinta(maqId, tintaIdx, dias, nota)` | Além de atualizar `t.conferencia` (a mais recente), agora também acrescenta a leitura em `t.conferenciaHistorico` (array, mais recente primeiro) |
| `_ptDetalheHtml(r)` | Nova seção "Histórico de conferências" no detalhe expandido, lida de `t.conferenciaHistorico` |

## [2.24.0] — 2026-08-28

### ✨ Melhoria — Motor de decisão único na Previsão de Troca de Tinta

A tela "Previsão de Troca de Tinta" passou a cruzar os 3 sinais que já existiam separados (média histórica/conferência física, validade das unidades em estoque com a regra de +1 ano — exceto o Primer — e quantidade em estoque) num veredito único por tinta, em 4 categorias: **🔴 Comprar** (sem reserva válida pra trocar agora, ou sem folga de tempo), **🟣 Repor** (já pode trocar mas a reserva precisa ser reposta, ou a reserva vai vencer antes de ser usada), **🟡 Programar** (dentro do prazo de reposição, reserva ok) e **🟢 Tranquilo**. Cada linha e cada card mostram o motivo específico da classificação, e o detalhe expandido de cada tinta agora abre com esse veredito destacado no topo.

Também: o **Calendário de compra** trocou a grade com todos os meses simultâneos por uma faixa de chips (todos os meses visíveis de uma vez, resumidos) + um painel de detalhe que mostra 1 mês por vez ao clicar — menos rolagem, mesma visão geral. E a aba **Por máquina** passou a mostrar, junto da previsão de cada tinta, uma barrinha com o nível real (%) da última conferência física registrada (direto do RasterLink6Plus), sem precisar abrir o detalhe da linha.

### 🔧 Funções novas/alteradas no JS

| Função | Descrição |
|---|---|
| `_ptAvaliar(cor, effRestante, previsaoData, produto)` | Substitui `_ptStatus` — motor único que cruza consumo + validade (+1 ano) + estoque, retorna `{key, cor, label, motivo}` |
| `_ptUsavelAte(validadeStr, cor)` | Data até quando uma unidade em estoque pode ser usada (validade + 1 ano, sem extensão pro Primer) |
| `_ptReservaValidaNaData(produto, cor, dataRef)` | Conta quantas unidades em estoque ainda estarão dentro do prazo de uso numa data futura |
| `_ptExtrairPct(nota)` | Extrai o percentual de uma nota de conferência física (ex: "RasterLink6Plus: 82%") |
| `selecionarPtMesCalendario(idx)` / `_renderPtCalendarioDetalhe()` | Novo modelo de Calendário de compra: faixa de chips + detalhe de 1 mês |

## [2.23.0] — 2026-08-25

### ✨ Nova funcionalidade — Previsão de Troca de Tinta

Nova página em Equipamentos, ao lado de Estoque Mínimo, que cruza a média histórica de troca de cada tinta em cada máquina especificamente (não a média agregada por modelo) com os dias que a tinta atual já está instalada, prevendo quando cada cor vai precisar de reposição — organizada em 4 abas: Resumo, Pedido consolidado, Calendário de compra e Por máquina.

Motivada pela mudança do padrão de estoque mínimo de "2 unidades em estoque" para "1 unidade de reserva + 1 já instalada na máquina" — menos folga, então a previsão precisa ser acompanhada de perto. Como a tinta aguenta rodar até +1 ano após a validade impressa (confirmado com o técnico, exceto o Primer, que não tem essa margem), uma previsão vencida não significa "acabou": o sistema sinaliza para comprar a reserva e conferir fisicamente o nível na máquina antes de trocar, distinguindo isso de quando já não há reserva nenhuma no estoque.

Inclui uma **conferência física**: ao verificar visualmente o nível de uma tinta na máquina, é possível registrar uma estimativa de quantos dias ainda dura — essa conferência sobrepõe a previsão estatística até ser apagada ou refeita, e fica registrada no histórico da máquina e na auditoria.

**Localização**: sidebar "🗓 Previsão de Troca de Tinta", dentro da seção Equipamentos (ao lado de Estoque Mínimo).

**Permissão**: `ver_previsao_tinta` (nova, só admin por padrão — mesmo critério de Estoque Mínimo).

### 🔧 Funções novas no JS

| Função | Descrição |
|---|---|
| `calcularPrevisaoTinta()` | Cruza `calcularConsumoPorMaquina()` + `TINTA_MAPA`/`TINTA_PRIMER` + estoque real (`P`), retorna 1 linha por máquina×cor instalada |
| `_tintaInfoPorModeloCor(modelo, cor)` | Modelo+cor → nome do produto e slot (Branco-07/08) |
| `_ptStatus(effRestante, estoque)` | Classificador único dos 5 status (crítico, pode trocar, programar, tranquilo, sem histórico) |
| `renderPrevisaoTinta()` | Entry point, popula as 4 abas |
| `switchPrevisaoTintaTab(tab)` | Alterna entre as 4 abas |
| `sortPtBy(campo)` / `filtrarPtStatus(status)` | Ordenação e filtro da tabela consolidada |
| `togglePtLinha(maqId, tintaIdx)` | Expande/recolhe o detalhe de estoque + conferência de uma linha |
| `salvarConferenciaTinta(maqId, tintaIdx, dias, nota)` | Registra a conferência física, sobrepõe a previsão estatística |
| `limparConferenciaTinta(maqId, tintaIdx)` | Remove a conferência registrada, volta pra média do sistema |

## [2.21.0] — 2026-08-19

### ✨ Nova funcionalidade — Diagnóstico por máquina no Estoque Mínimo

Depois de comparar 3 protótipos de tela, a tela "Estoque Mínimo de Tintas" ganhou 3 acréscimos:

1. **Seletor de janela de cálculo**: "Histórico completo" ou "Últimos 5 ciclos" — alterna a base de cálculo da cadência entre todo o histórico (desde jun/2024) ou só as trocas mais recentes, que refletem melhor o ritmo atual.
2. **Alerta de tinta parada**: banner vermelho (só aparece quando há algo a sinalizar) listando tintas atualmente instaladas muito além da média *daquela máquina específica* pra aquela cor (1,3× = atenção, 2× = crítico). Expansível, mostra máquina, dias atual, média da máquina e a razão.
3. **Consumo por máquina**: nova seção abaixo da tabela agregada, com um card por máquina mostrando cada cor com uma bolinha de status (verde/amarelo/vermelho) e os dias em uso — pra identificar padrões como uma máquina rodando bem menos que as outras do mesmo modelo.

A tabela agregada por modelo (decisão de compra) continua igual, só passou a respeitar a janela de cálculo escolhida — inclusive na exportação em PDF.

### 🔧 Funções novas/alteradas no JS

| Função | Descrição |
|---|---|
| `setAminJanela(j)` | Alterna entre histórico completo e últimos 5 ciclos, re-renderiza |
| `_aminCalcGrupo(...)` | Agora aceita janela e ordena ciclos por data pra pegar os N mais recentes |
| `calcularConsumoPorMaquina()` | Compara o pote atual de cada máquina/cor com a média histórica daquela máquina especificamente |
| `toggleAminAlerta()` | Expande/recolhe a lista de tintas paradas no banner |

## [2.20.0] — 2026-08-19

### ✨ Nova funcionalidade — Estoque Mínimo de Tintas

Nova página em Equipamentos que cruza o histórico real de troca de tintas das 6 máquinas Mimaki (módulo Máquinas) com o estoque atual, e recomenda se o mínimo de cada tinta deve continuar em 2 unidades ou pode cair para 1 — motivada pela confirmação do técnico de que a tinta aguenta uso até 1 ano após a validade impressa uma vez instalada, tornando seguro reduzir a reserva nas tintas de giro lento.

**Localização**: sidebar "🧪 Estoque Mínimo", dentro da seção Equipamentos (ao lado de Máquinas).

**Lógica de cálculo**:
```javascript
mediaDias      = média de dias entre instalação e troca (ciclos finalizados, por cor/máquina)
slotsSimultaneos = máquinas usando aquela tinta × posições por máquina (Branco = 2, demais = 1)
cadenciaLoja   = mediaDias / slotsSimultaneos
```
- Cadência < 30 dias → 🔴 Alto giro, mantém mínimo 2
- Cadência entre 30 e 60 dias → 🟡 Atenção, mantém mínimo 2 por ora
- Cadência ≥ 60 dias → 🟢 Giro lento, sugere mínimo 1

Primer (PR-200) é tratado à parte: produto único compartilhado pelas 6 máquinas, sem separar por modelo LH-100/LUS-120.

**Layout**: banner explicando a fórmula e a regra de validade +1 ano, 4 cards de resumo (alto giro / atenção / giro lento / capital liberável estimado em R$), tabela ordenável com máquina, cor, produto, slots simultâneos, média de dias/ciclo, cadência, estoque atual, mínimo atual, mínimo sugerido e justificativa.

**Permissão**: `ver_analise_min` (nova, só admin por padrão — mesmo critério de Análise ABC e Previsão de Compra).

**Exportação**: PDF via `exportarAnaliseMinPDF()`, mesmo padrão visual das outras análises.

Só análise/recomendação — não altera o mínimo automaticamente, o ajuste continua manual na tela de Estoque.

### 🔧 Funções novas no JS

| Função | Descrição |
|---|---|
| `calcularAnaliseTintas()` | Cálculo puro: cruza `MAQUINAS` + `P` + `TINTA_MAPA`, retorna uma linha por tinta |
| `renderAnaliseMin()` | Renderiza os 4 cards de resumo + tabela |
| `sortAminBy(campo)` | Ordenação da tabela |
| `exportarAnaliseMinPDF()` | Exporta PDF |
| `_aminTier(cadencia)` | Classifica a cadência em alto giro / atenção / giro lento |
| `_aminCalcGrupo(...)` | Agrega ciclos e máquinas usando por grupo de tinta |

---

## [2.6.0] — 2026-05-11

### ✨ Nova funcionalidade — Pedido Automático

Página dedicada que identifica automaticamente itens em estoque crítico ou alerta e gera um pedido de compra pronto, agrupado por fornecedor.

**Localização**: novo item na sidebar "🤖 Pedido Automático" (com badge mostrando contagem em tempo real).

**Lógica de detecção**:
- Itens com `status === 'Crítico'` ou `status === 'Alerta'` (usa a função `status()` existente)
- Filtros: por categoria, por fornecedor, por urgência (Crítico/Alerta/Todos)

**Lógica de sugestão de quantidade**:
```javascript
sug = max(1, (max(repo, min) - estoque) + ceil(consumo))
```
Traz o estoque ao ponto de reposição + buffer de ~1 mês de consumo.

**KPIs no topo**:
- Itens críticos (vermelho)
- Itens em alerta (amarelo)
- Total de fornecedores
- Total estimado em R$ dos itens selecionados

**Ações em massa**:
- ☑ Marcar todos / ☐ Desmarcar todos
- ⬇ **Exportar Excel/CSV** — com BOM UTF-8 + separador `;` (abre direto no Excel pt-BR)
- 📄 **Exportar PDF** — agrupado por fornecedor via jsPDF/autoTable
- 🛒 **Enviar p/ Carrinho** — joga os itens selecionados no carrinho do Pedido de Compra manual
- 💬 **WhatsApp** — copia mensagem formatada com total e abre `wa.me/`

**Layout**:
- Tabela agrupada por fornecedor com subtotal por grupo
- Cada linha: checkbox, código, nome, categoria, status (badge colorido), estoque atual, min/repo, qtd sugerida (editável inline), custo unitário, subtotal
- Críticos aparecem antes dos alertas dentro de cada fornecedor
- Estado de seleção (incluído/excluído + qtd customizada) persiste durante a sessão em `window._autoState`

**Integrações**:
- `_atualizarBadgeAuto()` chamada em `renderAll()` → badge da sidebar sempre atualizado
- `showPage('auto')` → renderiza automaticamente
- Hook em `renderAll()` quando `currentPage === 'auto'`
- Permissão `ver_pedidos` (mesma do Pedido de Compra manual)

**Auditoria**: exportações (CSV/PDF) e envio WhatsApp são registrados em `AUDIT`.

### 🔧 Funções novas no JS

| Função | Descrição |
|---|---|
| `renderAutoPedido()` | Renderiza a página completa |
| `_autoQtdSugerida(p)` | Calcula qtd sugerida |
| `_autoItensCandidatos()` | Lista itens críticos/alerta filtrados |
| `_autoItensSelecionados()` | Lista os marcados pelo usuário |
| `_atualizarBadgeAuto()` | Atualiza badge da sidebar |
| `autoToggle(cod, incluido)` | Marca/desmarca um item |
| `autoSetQty(cod, qty)` | Edita a quantidade sugerida |
| `autoMarcarTodos(bool)` | Marca/desmarca todos visíveis |
| `autoEnviarParaCarrinho()` | Move itens pro carrinho do Pedido manual |
| `autoExportarCSV()` | Exporta CSV/Excel |
| `autoExportarPDF()` | Exporta PDF agrupado |
| `autoEnviarWhatsApp()` | Copia mensagem + abre WhatsApp |

### ✅ Validação

Testado via Chrome MCP — 0 erros no console, página renderizou corretamente com 69 itens identificados em 5 fornecedores totalizando R$ 80.450,33 em compras sugeridas.

---

## [2.5.0] — 2026-05-08

Sessão de polimento UX e nova funcionalidade de auditoria por produto.

### ✨ Novas funcionalidades

#### Modo escuro automático
Sistema agora respeita `prefers-color-scheme` do SO quando o usuário não escolheu tema manualmente.

**Mudanças**:
- `setTheme(tema, persistir = true)` — novo parâmetro para distinguir escolha do usuário (persiste) vs. detecção automática (não persiste)
- `carregarTema()` agora usa `window.matchMedia('(prefers-color-scheme: light)')` como fallback
- Listener reage a mudanças do SO em tempo real (apenas se o usuário não fez escolha manual)
- Suprime o toast de "Tema X aplicado" durante boot (era ruído)

#### Loading state durante boot Firebase
Tela de loading dedicada exibida até o carregamento inicial completar, com mensagens granulares.

**Arquivos afetados**:
- `index.html`: novo overlay `<div id="boot-loading">` logo após `<body>`
- `css/pages.css`: estilos `.boot-loading`, `.boot-loading-card`, spinner animado
- Firebase block: `_setBootMsg()` chamado em cada etapa (Produtos → Movimentações → Solicitações → Pedidos → Auditoria → Usuários)

**Comportamentos**:
- Fade-out automático após `carregarDadosFirebase()` concluir
- Timeout de segurança de 15s — libera o app mesmo se Firebase travar (degrada para localStorage)

#### Validação visual de formulários
Campos obrigatórios agora ficam destacados em vermelho quando o usuário tenta salvar com erro.

**Implementação**:
- Nova função utilitária `_invalido(elId, msg)` — marca campo, foca, toasta e retorna `false`
- Listener global auto-limpa a classe `.error` quando usuário começa a corrigir o campo
- CSS `.fi2.error` (border vermelha + glow) e `.fi.error`
- Aplicado em `salvarUsuario()` (5 validações) e `confirmar()` modal de Entrada/Saída (3 validações)

#### Histórico de versões por produto
Cada edição de produto agora é rastreada com diff completo dos campos alterados.

**Estrutura de dados**:
```javascript
produto.historico = [
  {
    tsMs: 1715190000000,
    ts: '08/05/2026 14:30',
    user: 'Thiago',
    diff: {
      estoque: { antes: 5, depois: 8 },
      custo: { antes: 320, depois: 350 }
    }
  },
  ...
]
```

**Características**:
- Diff calculado automaticamente em `salvarProduto()` — só registra campos que efetivamente mudaram
- Validades comparadas via `JSON.stringify` (lista) — exibidas como "N lotes" em vez de JSON
- Limite de 50 edições por produto (FIFO) para evitar docs gigantes no Firestore
- Sincronizado automaticamente via `fbSalvarProduto` existente

**UI nova**:
- Botão "📜 Histórico (N)" no rodapé do modal de edição (só aparece quando há histórico)
- Modal dedicado `overlay-hist-prod` com listagem cronológica reversa
- Cada entrada mostra: nome do usuário, timestamp, e tabela visual de "antes → depois" por campo
- Cores: campo antigo vermelho/riscado, novo verde

### 🔧 Detalhes técnicos

- `setTheme` refatorado para aceitar `persistir` — antes sempre salvava em localStorage
- Auto-clear de `.error` ouve eventos `input` E `change` (para selects)
- `_CAMPO_LABELS` mapeia campos técnicos (`cod`, `forn`) para labels amigáveis ("Código", "Fornecedor")

---

## [2.4.0] — 2026-05-08

Sessão de manutenibilidade: extração de CSS para arquivos externos.

### 🧹 Refatoração

#### CSS extraído para 3 arquivos externos
O `<style>` inline (≈ 36 KB / 522 linhas) foi separado em 3 arquivos seguindo a estrutura sugerida em `PROXIMOS_PASSOS.md` (#9).

**Arquivos novos**:
- `css/theme.css` — variáveis CSS, 3 temas (escuro/claro/azul corporativo), seletor de tema, base reset, scrollbar, badges Mimaki
- `css/components.css` — UI reutilizável: nav buttons, painéis (panel/ph), inputs (.fi, .fi2, qty/cost), tabelas, badges/categoria/ABC, modais, toast, btn-edit/del/aprovar/rejeitar/wpp/export, perm-checkboxes, autocomplete dropdown, animações compartilhadas (`@keyframes blink`, `pulse-badge`, `mIn`, `spin`)
- `css/pages.css` — layout (`.app`, `.body`, `.nav`, `.main`), sidebar, dashboard (KPIs, charts, alerts), solicitações, pedido manual/cart, notificações (sino + painel + página), banner de alerta, user-badge, auditoria, relatórios, user-cards, login screen, **toda a seção responsiva (≤ 1024px / 768px / 480px)**

**Mudanças no `index.html`**:
- `<style>...522 linhas...</style>` substituído por 3 `<link rel="stylesheet">`
- Tamanho do `index.html`: **270 KB → 233 KB** (-14%)
- Service worker (`sw.js`) atualizado para cachear os 3 novos arquivos no `APP_SHELL`

**Padrões mantidos**:
- Ordem de carregamento: theme → components → pages (cascata correta)
- Zero mudança visual / comportamental
- Continua sem build step — funciona direto no GitHub Pages

### 🛠 Incidente técnico desta sessão

A primeira tentativa de extração usou `Get-Content -Raw` do PowerShell 5.1 sem encoding explícito, causando dupla decodificação UTF-8 e corrompendo 10.436 caracteres Unicode altos (`─`, `═`, `►`, `—`) no `index.html`. Foi necessário re-baixar a versão limpa do GitHub e re-aplicar TODAS as mudanças desta sessão (v2.2.0, v2.3.0, v2.4.0) usando exclusivamente o Edit tool e a API .NET `[System.IO.File]::ReadAllText` com encoding explícito.

**Lição registrada**: nunca usar `Get-Content -Raw` em arquivos UTF-8 com caracteres Unicode altos. Preferir Edit tool ou `[System.IO.File]::ReadAllText($path, [System.Text.UTF8Encoding]::new($false))`.

---

## [2.3.0] — 2026-05-08

Sessão de UX: PWA, mobile responsivo e atalhos de teclado.

### ✨ Novas funcionalidades

#### PWA (Progressive Web App)
Sistema agora é instalável como app nativo no celular/desktop.

**Arquivos novos**:
- `manifest.json` — metadados, ícones SVG inline, theme color, display standalone
- `sw.js` — service worker com estratégia network-first + fallback de cache

**Mudanças no `index.html`**:
- `<link rel="manifest">` + meta tags PWA (theme-color, apple-mobile-web-app-*)
- `apple-touch-icon` SVG inline
- Registro do service worker em `init` (só em http(s)://, file:// é ignorado)

**Características**:
- App shell cacheado: `index.html`, `manifest.json`
- Firebase NÃO é cacheado (deixa o SDK lidar com offline persistence nativa)
- CDNs (jspdf, fonts) cacheados em primeiro acesso
- `APP_VERSION` no SW invalida cache antigo a cada release

#### Mobile responsivo
Layout agora se adapta a tablets, celulares e smartphones pequenos.

**Breakpoints**:
- ≤ 1024px (tablet): sidebar mais estreita, KPIs em 3 colunas, mid-row em 2 colunas
- ≤ 768px (mobile): sidebar vira drawer com botão hambúrguer + backdrop, KPIs em 2 colunas, mid-row em 1 coluna, modais quase fullscreen, inputs maiores para toque
- ≤ 480px (smartphone pequeno): KPIs em 1 coluna, badge "Ao vivo" e clock escondidos

**Mudanças**:
- Botão hambúrguer (☰) no header — só aparece ≤ 768px
- Backdrop semi-transparente quando sidebar aberta no mobile
- Funções `toggleMobileMenu()` / `closeMobileMenu()` no JS
- Fecha automático ao clicar em qualquer item do menu
- `viewport` meta atualizado com `viewport-fit=cover` (suporte a notch)

**Aditivo**: nenhuma media query mexe no layout desktop — zero regressão.

#### Atalhos de teclado
Novo bloco `setupKeyboardShortcuts()` com:
- `/` — foca busca (vai pra Estoque se não estiver lá)
- `n` — novo produto (cadastro rápido)
- `e` — registrar entrada
- `s` — registrar saída
- `Esc` — fecha qualquer modal aberto
- `?` — mostra dica com lista de atalhos no toast

**Regras**:
- Só ativos depois do login (verifica `CURRENT_USER` + login-screen oculto)
- Ignora atalhos quando user está digitando em input/textarea/select
- Verifica `podeEditar()` antes de abrir modais (respeita permissões)
- Modificadores (Ctrl/Meta/Alt) desabilitam atalhos para não conflitar

### 🔧 Detalhes técnicos

- Ícones do PWA são SVG inline em data URI — zero arquivos externos para gerenciar
- `mobile-only` / `desktop-only` classes utilitárias adicionadas
- Sidebar continua scrollável em desktop; no mobile vira `position:fixed` deslizante

---

## [2.2.0] — 2026-05-08

Sessão de hardening: persistência de auditoria, hash de senhas e regras Firestore.

### ✨ Novas funcionalidades

#### Auditoria persistente no Firebase
A auditoria agora sobrevive a reload — antes só existia em memória.

**Mudanças**:
- Nova coleção Firestore `auditoria` (constante `COL_AUDIT`)
- Função `window.fbSalvarAudit(entry)` salva cada ação registrada
- `registrarAudit()` agora chama `fbSalvarAudit` automaticamente
- Cada entrada ganha campo `tsMs` (timestamp absoluto) usado como parte do docId estável: `audit_{tsMs}_{id}`
- Listener `onSnapshot(collection(db, COL_AUDIT))` sincroniza em tempo real entre dispositivos
- Carregamento inicial em `carregarDadosFirebase()` reconcilia `_auditId` com o maior id existente para evitar colisões
- Limite de 500 entradas em memória mantido; Firebase guarda histórico completo

#### Limpeza segura da auditoria
- Nova função `window.fbLimparAuditoria()` deleta todos os docs da coleção em paralelo
- `limparAuditoria()` agora pede confirmação dupla e usa o padrão "Optimistic UI with Reconciliation Guard" (`window._auditExcluidosRecentes`) para evitar ressurreição durante a janela de propagação Firestore
- Admin-only (segue `podeAprovar()`)

#### Hash de senhas (SHA-256 + salt por usuário)
Senhas não são mais armazenadas em texto puro.

**Esquema**:
- Formato versionado: `s:<saltHex16bytes>$h:<sha256Hex>`
- Salt único por usuário gerado via `crypto.getRandomValues`
- Hashing via Web Crypto API nativa (`crypto.subtle.digest`)

**Funções utilitárias**:
- `_sha256Hex(text)` — hash SHA-256 hexadecimal
- `_gerarSalt()` — 16 bytes aleatórios
- `_hashSenha(senha, salt?)` — produz hash no formato versionado
- `_isHashLegado(hash)` — detecta hashes em texto puro
- `_verifySenha(senha, hashGuardado)` — verifica em ambos os formatos

**Migração transparente**:
- No primeiro login, `tentarLogin()` aceita hash legado (texto puro) E substitui por SHA-256+salt
- `salvarUsuariosLS()` propaga para Firebase via `fbSalvarUsuarios()`
- Próximos logins usam apenas o formato novo
- Sem quebra para usuários existentes (`admin`, `thais`, `alanadias`, `bruno`)

**Refatoração**:
- `tentarLogin()` agora é `async`
- `salvarUsuario()` (criação/edição) agora é `async`
- Todos os `onclick`/`onkeydown` continuam funcionando (ignoram retorno Promise)

**Limitações reconhecidas**:
- Hash client-side é mais fraco que bcrypt server-side
- Atacante com acesso ao Firestore + apiKey pode rodar GPU brute-force em senhas curtas
- Passo intermediário pragmático antes da migração para Firebase Auth

#### Regras de segurança Firestore (`firestore.rules`)
Novo arquivo na raiz do projeto com regras intermediárias.

**O que validam**:
- Estrutura de produtos (campos obrigatórios, categoria como enum, estoque ≥ 0)
- Estrutura de movimentações (tipo enum ENTRADA/SAÍDA, qty > 0)
- Estrutura de solicitações e pedidos (status como enum)
- **Auditoria imutável**: `allow update: if false` — entradas não podem ser alteradas
- Default deny: qualquer caminho não previsto é negado

**Limitações reconhecidas** (documentadas no próprio arquivo):
- App ainda não usa Firebase Auth, então `request.auth != null` quebraria tudo
- Qualquer pessoa com a apiKey pública lê todas as coleções
- Caminho documentado para migração a regras estritas quando vier Firebase Auth

**Deploy**: manual via Firebase Console ou `firebase deploy --only firestore:rules` (instruções no topo do arquivo).

### 🔧 Padrões reaproveitados

- "Optimistic UI with Reconciliation Guard" estendido para auditoria (mesmo padrão de produtos)
- Campo `_docId` salvo no doc Firestore mas removido ao ler (não vaza para a UI)
- Filtro `if (snap.metadata.hasPendingWrites) return` em todos os listeners

---

## [2.1.0] — 2026-05-05

Sessão de aprimoramentos: correções de bugs críticos + novas funcionalidades.

### 🐛 Correções de bugs

#### Bug "Produto Ressuscitando"
**Problema**: Ao excluir um produto (ex: Acetona), ele desaparecia mas voltava a aparecer na lista após alguns segundos.

**Causa raiz**: O listener `onSnapshot` em tempo real do Firebase recarregava a lista ANTES da exclusão ser confirmada no servidor, causando a "ressurreição" do produto.

**Solução implementada**:
- Adicionado `Set _excluidosRecentes` que mantém os códigos recém-excluídos por 5 segundos
- Listener filtra produtos no Set antes de re-renderizar
- Padrão: Optimistic UI with Reconciliation Guard

```javascript
window._excluidosRecentes = window._excluidosRecentes || new Set();
// Ao excluir, marca o código por 5s
window._excluidosRecentes.add(codExcluir);
setTimeout(() => window._excluidosRecentes.delete(codExcluir), 5000);
```

#### Bug "Carrinho não Adiciona"
**Problema**: Ao clicar em "+ Adicionar" no carrinho de pedidos, nada acontecia.

**Causa raiz**: A função `addToCart` tentava ler o campo `cart-custo` que não existia no HTML, causando erro silencioso de JavaScript que interrompia a função.

**Solução**: Removidas as referências ao `cart-custo`, custo agora é lido diretamente do produto cadastrado.

#### Bug "Item Cadastrado vira Livre"
**Problema**: Ao selecionar um produto no autocomplete, ele era adicionado como "item livre" (não cadastrado), perdendo dados do estoque.

**Causa raiz**: A função `selectCartProduct` também tentava escrever em `cart-custo` (inexistente), interrompendo a função antes de marcar `dataset.selectedCod`.

**Solução**: Reordenada a lógica para marcar `selectedCod` primeiro. Adicionado fallback para fornecedor "Outro" quando não encontrado.

#### Bug "Nº do Pedido não aparece no WhatsApp"
**Problema**: O campo "Nº do Pedido (opcional)" era preenchido mas não aparecia na mensagem.

**Causa raiz**: A função `_buildWppMsg` não lia o campo do formulário.

**Solução**: Adicionada leitura de `cart-num` e geração automática se vazio. Salvo em `window._ultimoNumPedido` para reuso.

#### Bug "Histórico não Aparecia"
**Problema**: Item "Histórico de Pedidos" sumia do menu lateral mesmo estando no código.

**Causa raiz**: A função `aplicarPermissoes` escondia itens não mapeados em `sidebarMap`.

**Solução**: Adicionado `'page-historico': 'ver_pedidos'` no mapa de permissões.

#### Bug "Sistema Quebrado pós-migração"
**Problema**: Após adicionar o módulo de Histórico, login parava de funcionar com erros `Cannot access X before initialization`.

**Causa raiz**: O bloco do módulo Histórico foi colado no início do arquivo, antes das declarações de variáveis globais. A função `renderHistBadge()` era chamada por `renderAll()` antes de `let PEDIDOS = []` ser executado.

**Solução**:
1. Movidas as declarações `let PEDIDOS = []` e `let _pedDetId = null` para o topo do arquivo (junto com outras variáveis globais como MOV, SOLIC, CART)
2. Movido o módulo de funções de Histórico para depois das outras funções (antes do bloco INICIALIZAÇÃO FINAL)
3. Removidas declarações duplicadas

### ✨ Novas funcionalidades

#### Histórico de Pedidos de Compra
Sistema completo de rastreamento de pedidos enviados via WhatsApp.

**Características**:
- Salvamento automático ao clicar em "Copiar e Enviar via WhatsApp"
- 3 status: 📤 Enviado / ✅ Recebido / ❌ Cancelado
- Página dedicada com filtros (status, solicitante, busca por nº)
- Modal de detalhes com itens, observações e histórico de status
- Botões de ação: Marcar Recebido, Cancelar, Reabrir
- Exportação CSV e PDF
- Sincronização Firebase em tempo real
- Carrinho limpa automaticamente após enviar
- Geração automática de número de pedido se não preenchido

**Estrutura de dados**:
```javascript
{
  id: 'ped_1234567890',
  num: 'PC-2605-1234',
  data: '05/05/2026 14:30',
  dataISO: '2026-05-05T17:30:00.000Z',
  solicitante: 'Thiago',
  itens: [...],
  total: 5173.70,
  fornecedores: ['MIMAKI Brasil', 'Local/Mercado'],
  status: 'enviado',
  historicoStatus: [...]
}
```

#### Aviso Explicativo no Modal de Entrada/Saída
Adicionado aviso visual no topo dos modais para evitar confusão entre "Editar Produto" e "Registrar Entrada".

- **Verde** no modal de Entrada: "Esta tela SOMA ao estoque atual..."
- **Vermelho** no modal de Saída: "Esta tela SUBTRAI do estoque atual..."

#### Edição de Código por Admin
Apenas usuários com perfil **admin** podem editar o código de um produto existente.

**Características**:
- Para outros perfis: campo `readonly` (mantém comportamento anterior)
- Para admin: campo editável com aviso amarelo
- Ao mudar o código:
  - Verifica se o novo código já existe (evita duplicação)
  - Apaga o documento antigo no Firebase
  - Atualiza referências em todas as movimentações
  - Registra na auditoria com formato "código antigo → código novo"

#### Exportação PDF em Todas as Páginas
Adicionada biblioteca jsPDF + autoTable e botões "📄 PDF" em:

- Estoque Completo
- Validades
- Alertas
- Movimentações
- Solicitações
- Histórico de Pedidos
- Análise ABC
- Previsão de Compra
- Auditoria

**Características do PDF**:
- Cabeçalho com logo STOCKOPS azul
- Data/hora de geração
- Nome do usuário que gerou
- Tabela com cores alternadas (zebra)
- Numeração de páginas
- Orientação paisagem (mais espaço para tabelas)
- Nome do arquivo automático com data ISO

### 🔧 Melhorias

- Função `fbExcluirProduto` agora tem feedback visual de "saving" e propagação correta de erros
- Listener `onSnapshot` melhor protegido contra eventos próprios (`hasPendingWrites`)
- Permissões aplicadas dinamicamente após cada render de página

### 📦 Dependências adicionadas

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>
```

### 🗂 Estrutura Firebase atualizada

Novas coleções:
- `pedidos` — Histórico de pedidos de compra (ID = pedido.id, ex: `ped_1234567890`)

---

## [2.0.0] — Anterior

Versão inicial com funcionalidades básicas:
- Sistema de login com 4 usuários padrão
- 3 temas (escuro, claro, azul corporativo)
- Dashboard com 6 KPIs clicáveis
- Estoque completo com filtros
- Validades, Alertas, Movimentações
- Solicitações com aprovação
- Pedidos de Compra (manual com WhatsApp)
- Análise ABC, Previsão de Compra
- Notificações
- Auditoria
- Relatórios automáticos
- Gerenciamento de usuários com permissões
- Firebase em tempo real
- Backup JSON
- Tags Mimaki (preço atualizado)
