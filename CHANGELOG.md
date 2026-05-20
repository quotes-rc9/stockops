# 📝 Changelog — StockOps

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
