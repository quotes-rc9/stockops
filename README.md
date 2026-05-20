# 📦 StockOps — Sistema de Gestão de Estoque

Sistema completo de gestão de estoque para empresa de **Impressão Digital**, com foco em insumos MIMAKI/Roland, peças de reposição e consumíveis.

## 🌐 Acesso ao sistema

- **Site em produção**: https://thiagodejesusconceicao300-del.github.io/stockops/
- **Repositório GitHub**: https://github.com/thiagodejesusconceicao300-del/stockops

## 🎯 Funcionalidades principais

### Gestão de Estoque
- ✅ Cadastro completo de produtos (88+ itens cadastrados)
- ✅ 3 categorias: Insumo, Peça, Consumível
- ✅ Controle de validade de lotes
- ✅ Status automático: Crítico / Alerta / OK
- ✅ Análise ABC do inventário
- ✅ Previsão de compra baseada em consumo
- ✅ Alertas de estoque mínimo

### Movimentações
- ✅ Registrar entradas e saídas
- ✅ Histórico completo de movimentações
- ✅ Sistema de solicitações (com aprovação por admin)
- ✅ Auditoria de todas as ações

### Pedidos de Compra
- ✅ Carrinho com autocomplete de produtos
- ✅ Itens "livres" (não cadastrados)
- ✅ Geração de mensagem WhatsApp formatada
- ✅ Histórico completo com status (Enviado/Recebido/Cancelado)
- ✅ Marcar pedidos como recebidos

### Sistema
- ✅ Login multi-usuário (admin/operador/visualizador)
- ✅ Permissões granulares (18 permissões diferentes)
- ✅ 3 temas: Escuro / Claro / Azul Corporativo
- ✅ Sincronização em tempo real via Firebase
- ✅ Exportação CSV e PDF em todas as páginas
- ✅ Notificações em tempo real
- ✅ Backup completo em JSON

## 🔧 Stack Tecnológico

- **Frontend**: HTML5 + CSS3 + JavaScript Vanilla (sem frameworks)
- **Backend**: Firebase Firestore (sincronização em tempo real)
- **Hospedagem**: GitHub Pages
- **Bibliotecas externas**:
  - Google Fonts (Inter, JetBrains Mono)
  - jsPDF + jspdf-autotable (exportação PDF)
  - Firebase v11.6.0

## 📁 Estrutura do Projeto

```
stockops/
├── index.html          ← Arquivo único com TUDO (HTML + CSS + JS)
└── README.md
```

> **Nota**: Atualmente o sistema é um **arquivo único** de ~4700 linhas. Uma melhoria recomendada é separar em múltiplos arquivos (ver `PROXIMOS_PASSOS.md`).

## 🚀 Como rodar localmente

### Opção 1: Abrir direto no navegador
1. Baixe o `index.html`
2. Dê duplo-clique no arquivo
3. ✅ Funciona offline (mas sem sincronização Firebase)

### Opção 2: Servidor local (recomendado)
```bash
# Com Python:
python3 -m http.server 8000

# Com Node.js:
npx serve .

# Acesse: http://localhost:8000
```

### Opção 3: VS Code com Live Server
1. Instale a extensão "Live Server"
2. Abra o `index.html`
3. Clique em "Go Live"

## 🔑 Usuários padrão

| Usuário (login) | Senha     | Perfil          |
|-----------------|-----------|-----------------|
| `admin`         | `admin123`| 👑 Administrador|
| `thais`         | `1234`    | 👤 Operador     |
| `alanadias`     | `1234`    | 👁 Visualizador |
| `bruno`         | `1234`    | 👤 Operador     |

> ⚠️ **Importante**: Senhas estão em texto puro no código por enquanto. Migrar para hash seguro é uma das próximas melhorias prioritárias.

## 🔥 Configuração Firebase

O projeto usa Firebase Firestore com a seguinte configuração (no fim do `index.html`):

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

### Coleções Firestore utilizadas:
- `produtos` — Cadastro de produtos (ID = código do produto)
- `movimentacoes` — Entradas e saídas
- `solicitacoes` — Solicitações de movimentação
- `pedidos` — Histórico de pedidos de compra
- `usuarios` (em `config/usuarios`) — Lista de usuários

## 📚 Documentação adicional

- 📄 `CHANGELOG.md` — Tudo que foi feito até agora
- 🎯 `PROXIMOS_PASSOS.md` — O que falta implementar
- 🛠 `ARQUITETURA.md` — Visão técnica do projeto

## 🤝 Contribuindo

Este projeto é privado. Para sugestões ou melhorias, contate o responsável.

---

**Última atualização**: 05/05/2026
**Versão**: 2.0
