# 🏗 Arquitetura — StockOps

Documentação técnica do projeto para facilitar manutenção e evolução.

## 📐 Visão Geral

StockOps é uma **Single Page Application (SPA)** sem framework, escrita em JavaScript Vanilla. Toda a lógica está em um único arquivo HTML (~4700 linhas) que contém HTML + CSS + JS embutidos.

### Por quê arquivo único?
- ✅ Deploy super simples (1 arquivo no GitHub Pages)
- ✅ Sem build step necessário
- ✅ Funciona offline ao baixar
- ❌ Difícil de manter conforme cresce
- ❌ Sem hot reload em desenvolvimento

**Recomendação**: ao migrar pro Claude Code, considere refatorar em múltiplos arquivos (ver `PROXIMOS_PASSOS.md`).

## 🗂 Estrutura do código

O `index.html` está organizado em seções na seguinte ordem:

```
1. <head>
   - Meta tags
   - Google Fonts
   - jsPDF + autoTable
   - <style> (CSS embutido) ~700 linhas

2. <body>
   2.1. Tela de login
   2.2. Banner de alerta crítico
   2.3. Navbar
   2.4. Sidebar (menu lateral)
   2.5. Main (área principal com 12+ páginas):
        - Dashboard
        - Estoque completo
        - Validades
        - Alertas
        - Movimentações
        - Solicitações
        - Pedido de Compra
        - Histórico de Pedidos
        - Análise ABC
        - Previsão de Compra
        - Notificações
        - Auditoria
        - Relatórios
        - Gerenciar Usuários
   2.6. Modais (10+):
        - Modal de movimentação
        - Modal de edição de produto
        - Modal de solicitação
        - Modal de detalhes de pedido
        - Modal WhatsApp
        - Modal de usuário
        - Modal de confirmação
        - Etc.

3. <script> principal
   3.1. Variáveis globais (P, MOV, SOLIC, CART, PEDIDOS, etc)
   3.2. Constantes (HOJE, ROLE_LABELS, etc)
   3.3. Utilitários (R, N, parseDate, status, etc)
   3.4. Renderização (renderKPIs, renderEstoque, etc)
   3.5. Modais (openModal, closeModal, confirmar, etc)
   3.6. Navegação (showPage, kpiClick)
   3.7. Módulos:
        - Edição de produtos
        - Movimentações
        - Solicitações
        - Pedido manual / Carrinho
        - Notificações
        - WhatsApp
        - Preços Mimaki
        - Tema
        - Autenticação
        - Permissões
        - Gerenciamento de usuários
        - Histórico de Pedidos ⭐ NOVO
        - Auditoria
        - Relatórios
        - Exportação PDF ⭐ NOVO

4. <script type="module"> Firebase
   - Configuração
   - Funções de salvar/excluir
   - Listeners em tempo real
   - Carregamento inicial
```

## 🗃 Modelo de Dados

### Variáveis globais principais

```javascript
let P = [];         // Produtos
let MOV = [];       // Movimentações
let SOLIC = [];     // Solicitações
let CART = [];      // Carrinho atual (não persiste)
let PEDIDOS = [];   // Histórico de pedidos
let NOTIFS = [];    // Notificações
let AUDIT = [];     // Auditoria (em memória apenas - migrar pro Firebase)
let USUARIOS = [];  // Usuários cadastrados
let CURRENT_USER;   // Usuário logado atual
```

### Estrutura de Produto
```javascript
{
  cod: 'LUS120-BK',
  nome: 'Tinta Preta LUS120',
  cat: 'Insumo',           // Insumo | Peça | Consumível
  forn: 'MIMAKI Brasil',
  estoque: 2,
  min: 2,                  // estoque mínimo
  repo: 3,                 // ponto de reposição
  custo: 320,              // R$ por unidade
  consumo: 1.8,            // un/mês
  abc: 'A',                // A | B | C
  val: ['15/04/2026']      // datas de validade dos lotes
}
```

### Estrutura de Movimentação
```javascript
{
  cod: 'LUS120-BK',
  nome: 'Tinta Preta LUS120',
  tipo: 'ENTRADA',        // ENTRADA | SAÍDA
  qty: 5,
  custo: 320,
  resp: 'Thiago',
  obs: 'NF 12345',
  data: '05/05/2026 14:30',
  val: ['10/01/2027']      // só se tipo === ENTRADA
}
```

### Estrutura de Solicitação
```javascript
{
  id: 1,
  cod: 'LUS120-BK',        // ou 'LIVRE' se _solicModo === 'livre'
  nome: 'Tinta Preta LUS120',
  livre: false,
  tipo: 'ENTRADA',         // ENTRADA | SAÍDA
  qty: 5,
  resp: 'Thiago',
  obs: 'urgente',
  data: '05/05/2026 14:30',
  status: 'pendente'       // pendente | aprovado | rejeitado
}
```

### Estrutura de Pedido
```javascript
{
  id: 'ped_1234567890',
  num: 'PC-2605-1234',
  data: '05/05/2026 14:30',
  dataISO: '2026-05-05T17:30:00.000Z',
  solicitante: 'Thiago',
  itens: [
    { cod: 'LUS120-BK', nome: 'Tinta...', forn: 'MIMAKI', qty: 5, custo: 320, livre: false }
  ],
  total: 1600,
  fornecedores: ['MIMAKI Brasil', 'Local/Mercado'],
  obs: '',
  mensagemWpp: '...',
  status: 'enviado',       // enviado | recebido | cancelado
  criadoPor: 'Thiago',
  historicoStatus: [
    { status: 'enviado', data: '05/05/2026 14:30', por: 'Thiago' }
  ]
}
```

### Estrutura de Usuário
```javascript
{
  id: 'u_thais',
  nome: 'Thais Paiva',
  email: 'thais',          // login (pode ser email ou apelido)
  role: 'usuario',         // admin | usuario | viewer
  _hash: '1234',           // ⚠ texto puro, migrar para hash
  permissoes: ['ver_dashboard', 'ver_estoque', ...],
  criadoEm: '30/04/2026'
}
```

## 🔥 Firebase

### Configuração
```javascript
const firebaseConfig = {
  apiKey:            "AIzaSyBGuN6uieFgTmIa8mJwiRA3eqB70UPp0xM",
  authDomain:        "stockops-70ba6.firebaseapp.com",
  projectId:         "stockops-70ba6",
  storageBucket:     "stockops-70ba6.firebasestorage.app",
  messagingSenderId: "1059526294275",
  appId:             "1:1059526294275:web:8ac9135d6728c65c4c8736"
};
```

### Coleções Firestore

| Coleção          | ID do documento     | Descrição                  |
|------------------|---------------------|----------------------------|
| `produtos`       | código do produto   | Cada produto cadastrado    |
| `movimentacoes`  | `mov_{timestamp}`   | Cada movimentação          |
| `solicitacoes`   | `solic_{id}`        | Cada solicitação           |
| `pedidos`        | `ped_{timestamp}`   | Cada pedido de compra      |
| `config/usuarios`| `usuarios`          | Doc único com lista de users |

### Estratégias de sincronização

#### Padrão `onSnapshot` (tempo real)
```javascript
onSnapshot(collection(db, COL_PRODUTOS), (snap) => {
  if (snap.metadata.hasPendingWrites) return;  // ignora próprias escritas
  // ... atualiza array local
  renderAll();
});
```

#### Padrão "Optimistic UI with Reconciliation Guard"
```javascript
// 1. Atualiza local primeiro (UI rápida)
P = P.filter(x => x.cod !== codExcluir);
renderAll();

// 2. Marca como "recém-excluído"
window._excluidosRecentes.add(codExcluir);
setTimeout(() => window._excluidosRecentes.delete(codExcluir), 5000);

// 3. Sincroniza com Firebase
fbExcluirProduto(codExcluir).catch(err => {
  // Reverte se falhar
});

// 4. Listener filtra os "recém-excluídos" para evitar ressurreição
```

## 🎨 Sistema de Temas

3 temas implementados via CSS Variables:

```css
:root { /* tema escuro padrão */ }
[data-theme="light"] { ... }
[data-theme="corporate"] { ... }
```

Variáveis principais:
- `--bg`, `--s1` a `--s4` — cores de fundo (escala)
- `--b1` a `--b3` — bordas
- `--t1` a `--t4` — texto (escala)
- `--blue`, `--green`, `--yellow`, `--red`, etc — cores semânticas

Persistência em `localStorage`:
```javascript
localStorage.setItem('stockops-tema', tema);
```

## 🔐 Sistema de Permissões

18 permissões granulares:
- Visualização: `ver_dashboard`, `ver_estoque`, `ver_validades`, `ver_alertas`, etc
- Ações: `registrar_mov`, `criar_solic`, `aprovar_solic`, `editar_produtos`, `excluir_produtos`, etc
- Sistema: `ver_auditoria`, `gerenciar_usuarios`

Perfis padrão:
- **admin**: todas as permissões
- **usuario**: visualização + registrar mov + criar solic + gerar pedido
- **viewer**: apenas visualização do dashboard, estoque, validades e alertas

Verificação:
```javascript
function temPermissao(permId) {
  if (CURRENT_USER.role === 'admin') return true;
  return (CURRENT_USER.permissoes || []).includes(permId);
}
```

## 🎯 Padrões de Código

### Função de render
```javascript
function renderXXX() {
  // 1. Pegar dados filtrados
  const filtered = ...;

  // 2. Atualizar contadores no HTML
  $('xxx-count').textContent = filtered.length;

  // 3. Gerar HTML da lista/tabela
  $('xxx-tbody').innerHTML = filtered.map(item => `
    <tr>...</tr>
  `).join('');

  // 4. Aplicar permissões dinamicamente
  if (typeof aplicarPermissoes === 'function') aplicarPermissoes();
}
```

### Função de modal
```javascript
function openXXXModal() {
  if (!podeEditar()) { toast('Acesso negado', 'error'); return; }

  // Resetar campos
  $('field-1').value = '';

  // Abrir
  $('overlay-xxx').classList.add('open');
  setTimeout(() => $('field-1').focus(), 80);
}

function closeXXXModal() {
  $('overlay-xxx').classList.remove('open');
}

function salvarXXX() {
  // Validar
  if (!validar()) return;

  // Atualizar local
  XXX.push({...});

  // Sincronizar Firebase
  if (typeof fbSalvarXXX === 'function') fbSalvarXXX(item);

  // Auditoria
  registrarAudit('tipo', 'Ação', 'detalhe');

  // Re-renderizar
  closeXXXModal();
  renderAll();
  toast('Salvo!', 'success');
}
```

## 🐛 Bugs conhecidos / Limitações

1. **Auditoria não persiste** — Apenas em memória, perde ao recarregar
2. **Senhas em texto puro** — Migrar para Firebase Auth ou hash
3. **Mobile ruim** — Layout não otimizado para telas pequenas
4. **Sem testes** — Toda mudança precisa ser testada manualmente
5. **Arquivo único grande** — Difícil de manter

## 📚 Referências

- [Firebase Firestore Docs](https://firebase.google.com/docs/firestore)
- [jsPDF](https://github.com/parallax/jsPDF)
- [jspdf-autotable](https://github.com/simonbengtsson/jsPDF-AutoTable)
- [CSS Variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties)

---

**Última atualização**: 05/05/2026
