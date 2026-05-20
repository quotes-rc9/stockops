# 🤖 Instruções para Claude Code

Este documento orienta como continuar o desenvolvimento do StockOps no Claude Code.

## 📥 Passo 1: Baixar o código atual

Como o `index.html` deste pacote pode estar desatualizado (as últimas modificações foram feitas direto no GitHub), **baixe a versão mais recente** assim:

### Opção A: Via navegador
1. Acesse: https://github.com/thiagodejesusconceicao300-del/stockops
2. Clique em **Code** → **Download ZIP**
3. Extraia o ZIP
4. **Substitua** o `index.html` deste pacote pelo do ZIP baixado

### Opção B: Via Git
```bash
git clone https://github.com/thiagodejesusconceicao300-del/stockops.git
cd stockops
```

## 🔧 Passo 2: Setup inicial no Claude Code

```bash
# 1. Iniciar Claude Code na pasta
cd stockops

# 2. Verificar versão do Node (recomendado 18+)
node --version

# 3. (Opcional) Inicializar package.json
npm init -y

# 4. (Opcional) Instalar live-server para desenvolvimento
npm install --save-dev live-server

# 5. Adicionar scripts no package.json:
#    "scripts": {
#      "dev": "live-server --port=8080",
#      "start": "python3 -m http.server 8000"
#    }
```

## 🎯 Passo 3: Primeiras tarefas recomendadas

Em ordem de prioridade:

### 🚨 Prioridade 1: Auditoria no Firebase
**Status**: Estava sendo feito quando paramos, mas não foi finalizado.

**Prompt sugerido**:
```
Preciso fazer a auditoria do StockOps persistir no Firebase ao invés de só na memória.

Atualmente:
- A função registrarAudit() existe e adiciona entradas no array AUDIT
- Mas AUDIT só existe em memória, perde ao recarregar a página

O que preciso:
1. Adicionar const COL_AUDIT = 'auditoria' nas constantes Firebase
2. Criar window.fbSalvarAudit(entry) que salva cada entrada no Firestore
3. Modificar registrarAudit() para chamar fbSalvarAudit automaticamente
4. Carregar auditoria do Firebase em carregarDadosFirebase()
5. Adicionar listener onSnapshot para sincronização em tempo real

Por favor implemente isso mantendo o padrão usado nos outros módulos do código.
```

### 🔒 Prioridade 2: Segurança
**Prompt sugerido**:
```
O StockOps tem 2 problemas críticos de segurança:

1. Senhas armazenadas em texto puro (campo _hash dos usuários)
2. Firestore provavelmente em modo aberto (sem regras)

Por favor:
1. Migrar autenticação para Firebase Authentication (email/password)
2. Criar regras de segurança Firestore que validem auth e role do usuário
3. Garantir que apenas admin pode escrever em coleções sensíveis

Mantenha compatibilidade com os usuários atuais (precisamos migrar dados).
```

### 🧹 Prioridade 3: Refatoração
**Prompt sugerido**:
```
O index.html do StockOps tem ~4700 linhas e está difícil de manter.
Quero refatorar em múltiplos arquivos seguindo a estrutura sugerida em ARQUITETURA.md.

Por favor:
1. Separar CSS em arquivos por contexto (theme.css, components.css, pages.css)
2. Separar JS em módulos ES6 organizados por funcionalidade
3. Manter funcionando exatamente igual (zero regressão)
4. Adicionar Vite como build tool com hot reload
5. Configurar deploy automático no GitHub Pages via GitHub Actions

Mantenha o sistema 100% funcional durante e após a refatoração.
```

## 🛠 Comandos úteis

### Testar o site localmente
```bash
# Opção 1: Python
python3 -m http.server 8000

# Opção 2: Node.js
npx live-server

# Opção 3: PHP
php -S localhost:8000
```

### Git workflow recomendado
```bash
# Sempre criar branch para nova feature
git checkout -b feature/auditoria-firebase

# Após terminar
git add .
git commit -m "feat: auditoria persistente no Firebase"
git push origin feature/auditoria-firebase

# Criar Pull Request no GitHub
# Após merge, atualizar main local
git checkout main
git pull
```

## 📋 Checklist antes de cada commit

- [ ] Testou login com admin / admin123
- [ ] Testou cadastro de produto
- [ ] Testou registro de entrada
- [ ] Testou geração de pedido WhatsApp
- [ ] Testou exportação PDF
- [ ] Verificou Console (F12) — sem erros vermelhos
- [ ] Mensagem de commit descritiva
- [ ] Não commitou senhas/tokens

## 🐛 Como debugar

### Problema: Login não funciona
1. F12 → Console → ver erros vermelhos
2. Verificar se Firebase está conectado (deve mostrar "☁ Sincronizado")
3. Tentar com usuário padrão: `admin` / `admin123`

### Problema: Mudança não aparece
1. Ctrl+Shift+R (limpa cache)
2. Aba anônima
3. Verificar se commit foi feito no GitHub
4. Aguardar GitHub Pages republicar (~1-2 min)

### Problema: Bug de "ressurreição" volta
Verificar se `window._excluidosRecentes` ainda existe e está sendo usado corretamente em:
- `deletarProduto()`
- `onSnapshot(collection(db, COL_PRODUTOS), ...)`

## 📞 Contato

Se tiver dúvidas sobre a estrutura ou histórico, consulte:
- `README.md` — Visão geral
- `CHANGELOG.md` — Histórico de alterações
- `ARQUITETURA.md` — Detalhes técnicos
- `PROXIMOS_PASSOS.md` — Roadmap

---

Boa sorte no Claude Code! 🚀
