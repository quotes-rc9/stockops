# 🎯 Próximos Passos — StockOps

Esta é uma lista priorizada de melhorias e funcionalidades pendentes para evoluir o sistema.

## 🚨 Pendente da última sessão

### 1. Auditoria persistente no Firebase ⚠️ ALTA PRIORIDADE
**Problema atual**: A auditoria registra todas as ações, mas guarda apenas em memória. Ao recarregar a página, todo o histórico é perdido.

**O que fazer**:
1. Adicionar `const COL_AUDIT = 'auditoria';` nas constantes do Firebase
2. Criar função `window.fbSalvarAudit = async function(entry) {...}`
3. Modificar `registrarAudit()` para chamar `fbSalvarAudit` automaticamente
4. Adicionar carregamento de auditoria em `carregarDadosFirebase()`
5. Adicionar listener `onSnapshot(collection(db, COL_AUDIT))` para tempo real

**Implementação sugerida**:
```javascript
// Em registrarAudit, após o AUDIT.unshift:
const auditEntry = AUDIT[0];
if (typeof fbSalvarAudit === 'function') {
  fbSalvarAudit(auditEntry);
}

// fbSalvarAudit:
window.fbSalvarAudit = async function(entry) {
  try {
    await setDoc(doc(db, COL_AUDIT, 'audit_' + entry.id), entry);
  } catch(e) { console.error('Erro audit:', e); }
};
```

## 🔒 Segurança (CRÍTICO)

### 2. Hash de senhas
**Problema**: Senhas armazenadas em texto puro no localStorage e Firebase.

**Solução**: Migrar para Firebase Authentication ou implementar hash bcrypt/scrypt no client.

### 3. Regras de segurança Firebase
**Problema**: Firestore provavelmente está em modo aberto (qualquer um pode ler/escrever).

**Solução**: Configurar regras como:
```
match /produtos/{cod} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.token.role == 'admin';
}
```

### 4. Rate limiting
Implementar limite de tentativas de login (já parcialmente feito com `_loginBloqueado`).

## 🎨 UX e Acessibilidade

### 5. Modo responsivo / Mobile
**Problema atual**: Layout desktop forçado, ruim em celular/tablet.

**Solução**:
- Sidebar vira menu inferior em mobile
- Tabelas viram cards
- Botões maiores para toque
- Breakpoints: 1024px, 768px, 480px

### 6. PWA (Progressive Web App)
Tornar o sistema instalável como app nativo:
- `manifest.json` com ícones e cores
- Service Worker para cache offline
- Notificações push para alertas críticos

### 7. Atalhos de teclado
- `/` → focar busca
- `n` → novo produto
- `e` → registrar entrada
- `s` → registrar saída
- `Esc` → fechar modal

### 8. Modo offline real
Usar Firestore offline persistence + IndexedDB para funcionar sem internet.

## 🧹 Refatoração

### 9. Separar em múltiplos arquivos
**Problema atual**: 1 arquivo monolítico de ~4700 linhas dificulta manutenção.

**Estrutura sugerida**:
```
stockops/
├── index.html
├── css/
│   ├── theme.css
│   ├── components.css
│   └── pages.css
├── js/
│   ├── app.js              ← inicialização
│   ├── auth.js             ← login/logout
│   ├── permissions.js      ← controle de permissões
│   ├── modules/
│   │   ├── estoque.js
│   │   ├── movimentacoes.js
│   │   ├── solicitacoes.js
│   │   ├── pedidos.js
│   │   ├── historico.js
│   │   ├── auditoria.js
│   │   └── relatorios.js
│   ├── utils/
│   │   ├── pdf.js
│   │   ├── csv.js
│   │   └── format.js
│   └── firebase/
│       └── sync.js
└── data/
    └── produtos-iniciais.json
```

### 10. Build system
Adicionar Vite ou similar para:
- Bundling automático
- Hot reload em desenvolvimento
- Minificação para produção
- TypeScript opcional

### 11. Testes automatizados
- Vitest para testes unitários
- Playwright para E2E
- Foco inicial: lógica de status, cálculos ABC, validações

## 📊 Funcionalidades Novas

### 12. Dashboards customizáveis
- Widgets arrastáveis
- Salvar layout por usuário
- Filtros por período

### 13. Multi-empresa / Multi-filial
- Cadastrar várias unidades
- Estoque separado por filial
- Transferências entre filiais

### 14. Códigos de barras
- Scanner via câmera (HTML5 QR Scanner)
- Geração de etiquetas
- Busca rápida por código

### 15. Integração com fornecedores
- Email automático de pedidos (não só WhatsApp)
- Catálogo de fornecedores
- Comparativo de preços
- Histórico de cotações

### 16. Relatórios avançados
- Comparativo mês a mês
- Análise de tendências
- Sugestão de otimização de estoque
- Inventário cíclico

### 17. Integração com sistemas
- API REST para outros sistemas
- Webhook quando estoque crítico
- Integração com ERP (se houver)

### 18. Conferência de inventário
- Interface para contagem física
- Comparação com sistema
- Ajustes em lote

## 🐛 Pequenas melhorias / Polimento

### 19. Validação de formulários
- Datas no formato correto
- Campos obrigatórios destacados
- Mensagens de erro claras

### 20. Loading states
- Spinners em operações longas
- Skeleton screens
- Feedback visual em todas as ações

### 21. Confirmações visuais
- Animações sutis nos toasts
- Confetes ao concluir tarefas importantes
- Som opcional para alertas críticos

### 22. Histórico de versões
- Cada produto tem histórico de edições
- Quem mudou, o que e quando
- Possibilidade de reverter

### 23. Tags personalizadas
Além de "MIMAKI", permitir criar tags próprias:
- "Produto sazonal"
- "Compra em conjunto"
- "Cliente específico"
- Etc.

### 24. Modo escuro real automático
Detectar `prefers-color-scheme` do sistema operacional.

## 🚀 Migração para Claude Code

Ao migrar pro Claude Code, considere:

1. **Configurar Git workflow** com branches:
   - `main` → produção
   - `dev` → desenvolvimento
   - `feature/X` → novas features

2. **Adicionar `.gitignore`**:
   ```
   node_modules/
   .vscode/
   .DS_Store
   *.log
   ```

3. **Documentar variáveis de ambiente**:
   - Firebase config em `.env` (não comitar)

4. **Setup de CI/CD**:
   - GitHub Actions para deploy automático no GitHub Pages
   - Validação de código antes de merge

5. **Code review**:
   - Pull requests obrigatórios
   - Linter automático

## 💡 Ordem sugerida de implementação

**Sprint 1 (urgente)**:
1. Auditoria no Firebase (#1)
2. Hash de senhas (#2)
3. Regras Firebase (#3)

**Sprint 2 (qualidade)**:
4. Refatoração em múltiplos arquivos (#9)
5. Testes (#11)
6. Build system (#10)

**Sprint 3 (UX)**:
7. Mobile responsivo (#5)
8. PWA (#6)
9. Atalhos (#7)

**Sprint 4 (features)**:
10. Códigos de barras (#14)
11. Conferência de inventário (#18)
12. Email automático (#15)

---

**Última atualização**: 05/05/2026
